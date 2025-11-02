{{ config(materialized='view') }}

with src as (
  select
    f.store_key,
    f.month_key,
    d.full_date as month_start,
    f.target_amount_aed,
    f.actual_amount_aed
  from {{ ref('fact_store_target_monthly') }} f
  join {{ ref('dim_date') }} d on d.date_key = f.month_key
),
with_growth as (
  select
    s.*,
    lag(actual_amount_aed) over (partition by store_key order by month_start) as prev_actual
  from src s
),
scored as (
  select
    store_key,
    month_key,
    month_start,
    target_amount_aed,
    actual_amount_aed,
    case when target_amount_aed = 0 then null else actual_amount_aed / target_amount_aed end as attainment_ratio,
    case when prev_actual is null or prev_actual = 0 then null
         else (actual_amount_aed - prev_actual)/prev_actual end as mom_growth_pct,
    -- Weighted score (70% target attainment, 30% MoM growth), clipped to [-1, +2] then normalized to 0..1
    greatest(-1, least(2, 0.7*coalesce(actual_amount_aed/nullif(target_amount_aed,0),0) + 0.3*coalesce(
      case when prev_actual is null or prev_actual=0 then 0 else (actual_amount_aed - prev_actual)/prev_actual end, 0))) as raw_score
  from with_growth
)
select
  s.store_key,
  {{ dbt_utils.generate_surrogate_key(['s.month_start']) }} as month_key,
  s.month_start,
  st.store_id, st.store_code, st.store_name, st.city, st.country_code,
  s.target_amount_aed,
  s.actual_amount_aed,
  s.attainment_ratio,
  s.mom_growth_pct,
  (s.raw_score + 1)/3 as performance_index -- 0..1
from scored s
left join {{ ref('dim_store') }} st on st.store_key = s.store_key and st.is_current
