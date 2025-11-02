{{ config(materialized='table') }}

with base as (
  select
    f.customer_key,
    date_trunc('month', f.order_local_ts) as month_start,
    sum(f.order_net_aed)                  as total_net_amount_aed,
    count(*)                              as orders_count_month
  from {{ ref('fact_order') }} f
  group by 1,2
),
flags as (
  select
    customer_key, month_start,
    (orders_count_month > 0)::boolean         as is_active_customer_flag,
    (orders_count_month > 1)::boolean         as is_repeat_customer_flag
  from base
)
select
  {{ dbt_utils.generate_surrogate_key(['customer_key','month_start']) }} as customer_month_key,
  customer_key,
  {{ dbt_utils.generate_surrogate_key(['to_char(month_start, \'YYYY-MM-01\')']) }} as month_key,
  month_start,
  total_net_amount_aed,
  orders_count_month,
  is_active_customer_flag,
  is_repeat_customer_flag,
  current_date() as snapshot_as_of
from base
join flags using (customer_key, month_start)
