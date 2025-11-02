{{ config(materialized='view') }}

with base as (
  select month_key,
         sum(case when is_repeat_customer_flag then 1 else 0 end) as repeat_customers,
         count(*)                                                 as total_active_customers
  from {{ ref('fact_customer_monthly_activity') }}
  group by 1
)
select
  b.month_key,
  d.full_date as month_start,
  b.repeat_customers,
  b.total_active_customers,
  case when total_active_customers=0 then null
       else repeat_customers::float / total_active_customers end as repeat_rate_pct
from base b
left join {{ ref('dim_date') }} d on d.date_key = b.month_key
