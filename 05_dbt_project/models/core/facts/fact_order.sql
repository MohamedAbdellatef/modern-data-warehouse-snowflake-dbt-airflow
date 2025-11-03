{{ config(
  materialized='incremental',
  unique_key='order_number',
  incremental_strategy='merge',
  on_schema_change='append_new_columns',
  cluster_by=['order_local_ts', 'store_key']
) }}

with orders as (
  select * from {{ ref('stg_orders') }}
),

items as (
  select * from {{ ref('stg_order_items') }}
),

agg as (

  select
    o.order_number,

    -- foreign keys (all VARCHAR hashes from dims)
    coalesce(s.store_key,    'UNKNOWN')  as store_key,
    coalesce(c.customer_key, 'UNKNOWN')  as customer_key,
    coalesce(ch.channel_key, 'UNKNOWN')  as channel_key,
    coalesce(d.date_key,     'UNKNOWN')  as date_key,

    -- timestamps
    cast(o.order_local_ts as timestamp_ltz) as order_local_ts,
    cast(o.order_utc_ts   as timestamp_ltz) as order_utc_ts,

    o.order_flag_code,
    o.final_status,

    -- helper for FX
    cast(o.order_local_ts as date)       as order_date,
    max(i.currency_code)                 as currency_code,

    -- counts
    count(distinct i.sku)                as items_count,
    count(distinct i.line_number)        as lines_count,

    -- native currency amounts
    cast(sum(i.gross_amount) as number(18,2)) as order_gross_native,
    cast(sum(i.net_amount)   as number(18,2)) as order_net_native,

    max(o.load_date)                     as load_date

  from orders o
  join items i
    on i.order_number = o.order_number
   and i.store_id     = o.store_id

  left join {{ ref('dim_store') }}    s
    on s.store_id = o.store_id
   and s.is_current

  left join {{ ref('dim_customer') }} c
    on c.customer_id = o.customer_id_nat
   and c.is_current

  left join {{ ref('dim_channel') }}  ch
    on ch.channel_code = o.channel_code

  left join {{ ref('dim_date') }}     d
    on d.full_date = cast(o.order_local_ts as date)

  group by
    o.order_number,
    coalesce(s.store_key,    'UNKNOWN'),
    coalesce(c.customer_key, 'UNKNOWN'),
    coalesce(ch.channel_key, 'UNKNOWN'),
    coalesce(d.date_key,     'UNKNOWN'),
    cast(o.order_local_ts as timestamp_ltz),
    cast(o.order_utc_ts   as timestamp_ltz),
    o.order_flag_code,
    o.final_status,
    cast(o.order_local_ts as date)
),

final as (

  select
    a.order_number,

    a.customer_key,
    a.store_key,
    a.channel_key,
    coalesce(cur.currency_key, 'UNKNOWN')          as currency_key,
    a.date_key,

    -- no payment fact grain yet ⇒ placeholder, still VARCHAR
    cast(null as varchar)                          as payment_key,

    a.order_local_ts,
    a.order_utc_ts,

    a.items_count,
    a.lines_count,

    a.order_gross_native,
    a.order_net_native,
    cast(a.order_net_native * fx.conversion_rate_to_aed
         as number(18,2))                          as order_net_aed,

    a.order_flag_code,
    a.final_status,
    a.load_date

  from agg a
  left join {{ ref('dim_currency') }} cur
    on cur.currency_code = a.currency_code

  left join {{ ref('stg_fx_rates_daily') }} fx
    on fx.currency_code = a.currency_code
   and fx.fx_date       = a.order_date
   and fx._to_ccy       = 'AED'
)

select *
from final
{% if is_incremental() %}
where load_date >= dateadd(day,-2,current_date)
{% endif %}
