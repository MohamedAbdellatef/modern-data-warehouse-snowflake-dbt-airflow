{{ config(materialized='view') }}

with refunds as (
  select
    date_trunc('month', r.return_local_ts)::date as month_start,
    r.refund_amount_native,
    r.currency_code
  from {{ ref('stg_returns') }} r
),
fx as (
  select fx_date, currency_code, conversion_rate_to_aed
  from {{ ref('stg_fx_rates_daily') }}
  where _to_ccy = 'AED'
),
refunds_aed as (
  select
    month_start,
    sum(refund_amount_native * fx.conversion_rate_to_aed) as refund_amount_aed
  from refunds r
  left join fx
    on fx.currency_code = r.currency_code
   and fx.fx_date = r.month_start
  group by 1
),
orders_month as (
  select
    date_trunc('month', f.order_local_ts)::date as month_start,
    sum(f.order_net_aed)                        as order_net_aed
  from {{ ref('fact_order') }} f
  where f.final_status in ('COMPLETED','FULFILLED')
  group by 1
)
select
  o.month_start,
  {{ dbt_utils.generate_surrogate_key(['o.month_start']) }} as month_key,
  o.order_net_aed,
  coalesce(r.refund_amount_aed,0) as refund_amount_aed,
  case when o.order_net_aed = 0 then null
       else r.refund_amount_aed / o.order_net_aed
  end as refund_rate_pct
from orders_month o
left join refunds_aed r using (month_start)
