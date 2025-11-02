{{ config(materialized='view') }}

select
  f.store_month_key,
  f.month_key,
  f.store_key,
  s.store_id, s.store_code, s.store_name, s.city, s.country_code,
  d.year, d.month_number, d.month_name,
  f.target_amount_aed,
  f.actual_amount_aed,
  f.variance_aed,
  f.variance_pct
from {{ ref('fact_store_target_monthly') }} f
left join {{ ref('dim_store') }} s on s.store_key = f.store_key and s.is_current
left join {{ ref('dim_date') }}  d on d.date_key   = f.month_key
