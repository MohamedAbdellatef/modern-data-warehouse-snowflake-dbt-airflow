{{ config(materialized='view') }}

with base as (
  select
    f.order_number,
    f.store_key,
    date_trunc('month', f.order_local_ts)::date as month_start,
    f.order_net_aed,
    f.items_count
  from {{ ref('fact_order') }} f
  where f.final_status in ('COMPLETED','FULFILLED')
),
agg as (
  select
    store_key,
    month_start,
    count(distinct order_number)                as orders_count,
    sum(items_count)                            as items_count,
    sum(order_net_aed)                          as net_amount_aed
  from base
  where store_key IS NOT NULL -- Exclude rows with NULL store_key
  group by 1,2
)
select
  a.*,
  {{ dbt_utils.generate_surrogate_key(['month_start']) }}                 as month_key,
  s.store_id, COALESCE(s.store_code, 'UNKNOWN') AS store_code, s.store_name, s.city, s.country_code,
  d.year, d.month_number, d.month_name
from agg a
left join {{ ref('dim_store') }} s on s.store_key = a.store_key
left join {{ ref('dim_date') }}  d on d.full_date = a.month_start
