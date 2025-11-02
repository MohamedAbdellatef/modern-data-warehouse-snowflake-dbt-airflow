{{ config(materialized='view') }}

with base as (
  select
    st.country_code,
    date_trunc('month', f.order_local_ts)::date as month_start,
    f.order_net_aed
  from {{ ref('fact_order') }} f
  join {{ ref('dim_store') }} st
    on st.store_key = f.store_key and st.is_current
  where f.final_status in ('COMPLETED','FULFILLED')
)
select
  country_code,
  month_start,
  {{ dbt_utils.generate_surrogate_key(['month_start']) }} as month_key,
  sum(order_net_aed) as net_amount_aed
from base
group by 1,2
