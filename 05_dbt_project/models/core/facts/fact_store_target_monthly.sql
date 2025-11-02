{{ config(materialized='table') }}

with tgt as (
  select store_id, target_month, target_amount_aed
  from {{ ref('stg_store_targets_monthly') }}
),
d_store as (
  select store_key, store_id from {{ ref('dim_store') }} where is_current
),
sales as (
  select
    store_key,
    date_trunc('month', order_local_ts) as month_start,
    sum(order_net_aed)                  as actual_amount_aed
  from {{ ref('fact_order') }}
  group by 1,2
),
final as (
  select
    {{ dbt_utils.generate_surrogate_key(['s.store_key','to_char(target_month, \'YYYY-MM-01\')']) }} as store_month_key,
    s.store_key as store_key,
    {{ dbt_utils.generate_surrogate_key(['to_char(target_month, \'YYYY-MM-01\')']) }} as month_key,
    target_month                                   as month_start,
    tgt.target_amount_aed,
    coalesce(a.actual_amount_aed,0)                as actual_amount_aed,
    (coalesce(a.actual_amount_aed,0) - tgt.target_amount_aed) as variance_aed,
    case when tgt.target_amount_aed = 0 then null
         else round((coalesce(a.actual_amount_aed,0) - tgt.target_amount_aed)/tgt.target_amount_aed, 4)
    end as variance_pct
  from tgt
  join d_store s on s.store_id = tgt.store_id
  left join sales a on a.store_key = s.store_key and a.month_start = tgt.target_month
)
select * from final
