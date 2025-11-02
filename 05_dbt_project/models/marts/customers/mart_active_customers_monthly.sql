{{ config(materialized='view') }}

select
  f.customer_month_key,
  f.customer_key,
  f.month_key,
  d.full_date as month_start,
  c.customer_id,
  f.orders_count_month,
  f.total_net_amount_aed,
  f.is_active_customer_flag
from {{ ref('fact_customer_monthly_activity') }} f
left join {{ ref('dim_customer') }} c on c.customer_key = f.customer_key and c.is_current
left join {{ ref('dim_date') }} d on d.date_key = f.month_key
