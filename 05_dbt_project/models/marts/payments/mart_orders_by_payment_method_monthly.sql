{{ config(materialized='view') }}

with pay as (
  select
    p.order_number,
    p.payment_method,
    p.payment_type,
    p.payment_status,
    p.amount_native,
    p.currency_code,
    o.order_local_ts
  from {{ ref('stg_payments') }} p
  join {{ ref('stg_orders') }}   o using (order_number, store_id)
  where p.payment_status = 'COMPLETED' and p.payment_type = 'CAPTURE'
),
fx as (
  select fx_date, currency_code, conversion_rate_to_aed
  from {{ ref('stg_fx_rates_daily') }}
  where _to_ccy = 'AED'
)
select
  date_trunc('month', pay.order_local_ts)::date             as month_start,
  {{ dbt_utils.generate_surrogate_key(['date_trunc(\'month\', pay.order_local_ts)::date']) }} as month_key,
  pay.payment_method,
  count(distinct pay.order_number)                          as orders_count,
  sum(pay.amount_native * fx.conversion_rate_to_aed)        as captured_amount_aed
from pay
left join fx
  on fx.currency_code = pay.currency_code
 and fx.fx_date = cast(pay.order_local_ts as date)
group by 1,2,3
