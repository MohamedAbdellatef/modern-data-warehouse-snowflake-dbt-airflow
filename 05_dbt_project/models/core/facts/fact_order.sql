{{ config(materialized='incremental', unique_key='order_number') }}

with o as ( select * from {{ ref('stg_orders') }}
  {% if is_incremental() %}
    where load_date >= (select coalesce(max(load_date), '1900-01-01') from {{ this }})
  {% endif %}
),
line_agg as (
  select
    order_number,
    sum(quantity)                  as items_count,
    sum(gross_amount)              as order_gross_native,
    sum(vat_amount)                as order_vat_native,
    sum(net_amount)                as order_net_native,
    any_value(currency_code)       as currency_code,
    cast(min(order_local_ts) as timestamp_ltz) as order_local_ts
  from {{ ref('stg_order_items') }}
  group by 1
),
fx as (
  select fx_date, currency_code, conversion_rate_to_aed
  from {{ ref('stg_fx_rates_daily') }}
  where _to_ccy = 'AED'
),
d_store as (select store_key, store_id, effective_from, coalesce(effective_to,'2999-12-31') as effective_to from {{ ref('dim_store') }}),
d_cust  as (select customer_key, customer_id, effective_from, coalesce(effective_to,'2999-12-31') as effective_to from {{ ref('dim_customer') }}),
d_chan  as (select channel_key, channel_code from {{ ref('dim_channel') }}),
d_curr  as (select currency_key, currency_code from {{ ref('dim_currency') }}),

joined as (
  select
    o.order_number,
    st.store_key,
    cu.customer_key,
    ch.channel_key,
    cur.currency_key,
    la.items_count,
    la.order_gross_native,
    la.order_vat_native,
    la.order_net_native,
    (la.order_net_native * fx.conversion_rate_to_aed) as order_net_aed,
    o.final_status,
    o.order_local_ts,
    o.load_date
  from o
  left join line_agg la on la.order_number = o.order_number
  left join fx on fx.currency_code = la.currency_code and fx.fx_date = cast(o.order_local_ts as date)
  left join d_store st
    on st.store_id = o.store_id
   and o.order_local_ts >= st.effective_from and o.order_local_ts < st.effective_to
  left join d_cust cu
    on cu.customer_id = o.customer_id_nat
   and o.order_local_ts >= cu.effective_from and o.order_local_ts < cu.effective_to
  left join d_chan ch on ch.channel_code = o.channel_code
  left join d_curr cur on cur.currency_code = la.currency_code
)

select
  {{ dbt_utils.generate_surrogate_key(['order_number']) }} as order_key,
  order_number,
  store_key, customer_key, channel_key, currency_key,
  items_count, order_gross_native, order_vat_native, order_net_native, order_net_aed,
  final_status, order_local_ts, load_date
from joined
