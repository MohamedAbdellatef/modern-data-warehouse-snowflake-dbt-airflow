{{ config(materialized='table') }}

with src as (
    select
        {{ strip('payment_id') }}                         as payment_id,
        {{ strip('order_number') }}                       as order_number,
        try_to_number({{ strip('store_id') }})            as store_id,
        {{ norm_code('payment_type') }}                   as payment_type,
        {{ norm_code('payment_status') }}                 as payment_status,
        {{ norm_code('payment_method') }}                 as payment_method,
        try_to_decimal({{ strip('amount_native') }},18,2) as amount_native,
        coalesce(try_to_decimal({{ strip('fee_native') }},18,2),0) as fee_native,
        {{ norm_code('currency_code') }}                  as currency_code,
        {{ safe_ts('payment_local_ts') }}                 as payment_local_ts,
        {{ safe_ts('payment_utc_ts') }}                   as payment_utc_ts,
        {{ strip('source_system') }}                      as source_system,
        to_date(ingestion_date)                           as load_date
    from {{ source('raw','psp_payments') }}
)

select * from src
