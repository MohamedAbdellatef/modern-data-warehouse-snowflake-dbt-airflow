{{ config(
  materialized='incremental',
  unique_key='order_number',
  incremental_strategy='merge',
  on_schema_change='sync_all_columns',
  cluster_by=['order_local_ts','store_key']
) }}

with orders as (select * from {{ ref('stg_orders') }}),
items  as (select * from {{ ref('stg_order_items') }}),

base as (
  select
    o.order_number,
    coalesce(cast(s.store_key as varchar(32)), 'UNKNOWN') as store_key, 
    coalesce(cast(c.customer_key as varchar(32)), 'UNKNOWN') as customer_key,
    ch.channel_key,
    o.final_status,
    o.order_local_ts,
    sum(i.net_amount)    as order_net_native,
    sum(i.gross_amount)  as order_gross_native,
    sum(i.vat_amount)    as order_vat_native,
    count(*)             as items_count,
    max(i.currency_code) as currency_code
  from orders o
  join items i
    on i.order_number = o.order_number and i.store_id = o.store_id
  left join {{ ref('dim_store') }}   s on s.store_id = o.store_id and s.is_current
  left join {{ ref('dim_customer') }} c on c.customer_id = o.customer_id_nat and c.is_current
  left join {{ ref('dim_channel') }}  ch on ch.channel_code = o.channel_code
  group by 1,2,3,4,5,6
)
select b.*, (b.order_net_native * fx.conversion_rate_to_aed) as order_net_aed
from base b
left join {{ ref('stg_fx_rates_daily') }} fx
  on fx.currency_code = b.currency_code
 and fx.fx_date = cast(b.order_local_ts as date)
 and fx._to_ccy = 'AED'
{% if is_incremental() %}
where b.order_local_ts >= dateadd(day,-2,current_date)
{% endif %}
