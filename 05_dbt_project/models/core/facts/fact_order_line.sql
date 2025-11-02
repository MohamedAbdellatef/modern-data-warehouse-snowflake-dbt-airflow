{{ config(
  materialized='incremental',
  unique_key='order_number||\'-\'||line_number',
  incremental_strategy='merge',
  on_schema_change='sync_all_columns',
  cluster_by=['order_local_ts','store_key']
) }}

with src as (
  select
    i.order_number,
    i.line_number,
    coalesce(cast(s.store_key as varchar(32)), 'UNKNOWN') as store_key, -- Ensure consistent data type
    coalesce(cast(c.customer_key as varchar(32)), 'UNKNOWN') as customer_key, -- Ensure consistent data type
    ch.channel_key,
    coalesce(cast(p.product_key as varchar(32)), 'UNKNOWN') as product_key, -- Ensure consistent data type
    i.quantity,
    i.unit_price,
    i.gross_amount,
    i.vat_amount,
    i.net_amount,
    i.currency_code,
    i.order_local_ts,
    i.load_date
  from {{ ref('stg_order_items') }} i
  left join {{ ref('stg_orders') }} o
    on o.order_number = i.order_number and o.store_id = i.store_id
  left join {{ ref('dim_store') }}   s on s.store_id = i.store_id and s.is_current
  left join {{ ref('dim_customer') }} c on c.customer_id = o.customer_id_nat and c.is_current
  left join {{ ref('dim_channel') }}  ch on ch.channel_code = o.channel_code
  left join {{ ref('dim_product') }}  p on p.sku = i.sku and p.is_current
)
select * from src
{% if is_incremental() %}
where load_date >= dateadd(day,-2,current_date)
{% endif %}
