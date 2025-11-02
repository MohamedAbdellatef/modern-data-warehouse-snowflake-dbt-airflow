{{ config(materialized='incremental', unique_key='order_number||\'-\'||line_number') }}

with src as (
  select * from {{ ref('stg_order_items') }}
  {% if is_incremental() %}
    where load_date >= (select max(load_date) from {{ this }})
  {% endif %}
),

d_store as (
  select store_key, store_id, effective_from, coalesce(effective_to, '2999-12-31') as effective_to
  from {{ ref('dim_store') }}
),
d_prod as ( select product_key, sku, effective_from, coalesce(effective_to,'2999-12-31') as effective_to
            from {{ ref('dim_product') }} ),
d_chan as ( select channel_key, channel_code from {{ ref('dim_channel') }} ),
d_curr as ( select currency_key, currency_code from {{ ref('dim_currency') }} ),

customer_lookup as (
  select o.order_number, c.customer_key, c.effective_from, coalesce(c.effective_to, '2999-12-31') as effective_to
  from {{ ref('stg_orders') }} o
  join {{ ref('dim_customer') }} c
    on o.customer_id_nat = c.customer_id
),

joined as (
  select
    s.order_number, s.line_number,
    st.store_key,
    cust.customer_key,
    prod.product_key,
    ch.channel_key,
    cur.currency_key,
    s.quantity, s.unit_price, s.gross_amount, s.vat_amount, s.net_amount, s.discount_amount,
    s.order_local_ts, s.order_utc_ts,
    s.load_date
  from src s
  -- time-valid store (SCD2)
  left join d_store st
    on st.store_id = s.store_id
   and s.order_local_ts >= st.effective_from and s.order_local_ts < st.effective_to
  -- time-valid product (SCD2)
  left join d_prod prod
    on prod.sku = s.sku
   and s.order_local_ts >= prod.effective_from and s.order_local_ts < prod.effective_to
  -- channel from code on items (falls back from orders if needed later)
  left join d_chan ch on ch.channel_code = s.category::varchar  -- if you keep channel on items replace with s.channel_code
  -- currency
  left join d_curr cur on cur.currency_code = s.currency_code
  -- customer (from orders)
  left join customer_lookup cust
    on cust.order_number = s.order_number
   and s.order_local_ts >= cust.effective_from and s.order_local_ts < cust.effective_to
),

final as (
  select
    {{ dbt_utils.generate_surrogate_key(['order_number','line_number']) }} as order_line_key,
    order_number, line_number,
    store_key, customer_key, product_key, channel_key, currency_key,
    quantity, unit_price, gross_amount, vat_amount, net_amount, discount_amount,
    order_local_ts, order_utc_ts,
    load_date
  from joined
)

select * from final
