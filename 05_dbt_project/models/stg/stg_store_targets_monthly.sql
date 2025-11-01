{{ config(materialized='table') }}

with src as (
  select
    try_to_number({{ strip('store_id') }})              as store_id,
    {{ safe_date('target_month') }}                     as target_month,
    try_to_decimal({{ strip('target_amount_AED') }},18,2) as target_amount_aed,
    {{ strip('source_system') }}                        as source_system,
    current_date()                                      as load_date
  from {{ source('raw','finance_store_targets_monthly') }}
)

select * from src
