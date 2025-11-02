{{ config(materialized='view') }}

with base as (
  select
    date_trunc('month', f.order_local_ts)::date as month_start,
    f.order_number,
    f.order_net_aed
  from {{ ref('fact_order') }} f
  where f.final_status in ('COMPLETED','FULFILLED')
),
agg as (
  select
    month_start,
    count(distinct order_number) as orders_count,
    sum(order_net_aed)           as net_amount_aed
  from base
  group by 1
)
select
  month_start,
  {{ dbt_utils.generate_surrogate_key(['month_start']) }} as month_key,
  orders_count,
  net_amount_aed,
  case when orders_count=0 then null else net_amount_aed / orders_count end as aov_aed
from agg
