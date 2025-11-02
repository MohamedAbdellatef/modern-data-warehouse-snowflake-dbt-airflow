{{ config(materialized='view') }}

with base as (
  select
    date_trunc('month', f.order_local_ts)::date as month_start,
    f.channel_key,
    f.order_number,
    f.order_net_aed
  from {{ ref('fact_order') }} f
  where f.final_status in ('COMPLETED','FULFILLED')
),
agg as (
  select
    month_start,
    channel_key,
    count(distinct order_number) as orders_count,
    sum(order_net_aed)           as net_amount_aed
  from base
  group by 1,2
),
tot as (
  select
    month_start,
    sum(orders_count)     as orders_total,
    sum(net_amount_aed)   as amount_total
  from agg
  group by 1
)
select
  a.month_start,
  {{ dbt_utils.generate_surrogate_key(['a.month_start']) }} as month_key,
  c.channel_code, c.channel_name, c.is_digital_flag,
  a.orders_count,
  a.net_amount_aed,
  case when t.orders_total=0 then 0 else a.orders_count::float / t.orders_total end as orders_share_pct,
  case when t.amount_total=0 then 0 else a.net_amount_aed / t.amount_total end    as revenue_share_pct
from agg a
join tot t using (month_start)
left join {{ ref('dim_channel') }} c on c.channel_key = a.channel_key
