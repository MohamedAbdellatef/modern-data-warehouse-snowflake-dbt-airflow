{{ config(
  materialized='incremental',
  incremental_strategy='merge',
  unique_key=['order_number', 'line_number'],
  on_schema_change='append_new_columns',
  cluster_by=['order_local_ts', 'store_key']
) }}

with src as (

    select
        -- natural grain
        i.order_number,
        cast(i.line_number as number(38,0))                as line_number,

        -- foreign keys (all VARCHAR hashes from dims)
        coalesce(s.store_key,    'UNKNOWN')                as store_key,
        coalesce(c.customer_key, 'UNKNOWN')                as customer_key,
        coalesce(d.date_key,     'UNKNOWN')                as date_key,
        coalesce(cur.currency_key, 'UNKNOWN')              as currency_key,
        coalesce(ch.channel_key, 'UNKNOWN')                as channel_key,
        coalesce(p.product_key,  'UNKNOWN')                as product_key,

        -- measures (native currency)
        cast(i.quantity        as number(18,3))            as quantity,
        cast(i.unit_price      as number(18,2))            as unit_price,
        cast(i.discount_amount as number(18,2))            as discount_amount,
        cast(i.gross_amount    as number(18,2))            as gross_amount,
        cast(i.vat_amount      as number(18,2))            as vat_amount,
        cast(i.net_amount      as number(18,2))            as net_amount,

        -- AED measure
        cast(i.net_amount * fx.conversion_rate_to_aed
             as number(18,2))                              as net_amount_aed,

        -- time & audit
        cast(i.order_local_ts as timestamp_ltz)            as order_local_ts,
        i.load_date

    from {{ ref('stg_order_items') }} i
    join {{ ref('stg_orders') }} o
      on o.order_number = i.order_number
     and o.store_id     = i.store_id

    left join {{ ref('dim_store') }}    s
      on s.store_id = i.store_id
     and s.is_current

    left join {{ ref('dim_customer') }} c
      on c.customer_id = o.customer_id_nat
     and c.is_current

    left join {{ ref('dim_channel') }}  ch
      on ch.channel_code = o.channel_code

    left join {{ ref('dim_product') }}  p
      on p.sku = i.sku
     and p.is_current

    left join {{ ref('dim_date') }}     d
      on d.full_date = cast(i.order_local_ts as date)

    left join {{ ref('dim_currency') }} cur
      on cur.currency_code = i.currency_code

    left join {{ ref('stg_fx_rates_daily') }} fx
      on fx.currency_code = i.currency_code
     and fx.fx_date       = cast(i.order_local_ts as date)
     and fx._to_ccy       = 'AED'
)

select *
from src
{% if is_incremental() %}
where load_date >= dateadd(day,-2,current_date)
{% endif %}
