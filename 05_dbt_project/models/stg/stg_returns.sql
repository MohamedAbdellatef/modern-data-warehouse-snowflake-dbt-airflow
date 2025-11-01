{{ config(materialized='table') }}

with src as (
    select
        {{ strip('return_id') }}                              as return_id,
        {{ strip('order_number') }}                           as order_number,
        try_to_number({{ strip('line_number') }})             as line_number,
        try_to_number({{ strip('store_id') }})                as store_id,
        try_to_decimal({{ strip('quantity_returned') }},18,3) as quantity_returned,
        coalesce(try_to_decimal({{ strip('refund_net_native') }},18,2),0) as refund_amount_native,
        {{ norm_code('currency_code') }}                      as currency_code,
        {{ norm_code('return_reason_code') }}                 as return_reason_code,
        {{ safe_ts('return_local_ts') }}                      as return_local_ts,
        {{ safe_ts('return_utc_ts') }}                        as return_utc_ts,
        {{ strip('source_system') }}                          as source_system,
        to_date(ingestion_date)                               as load_date
    from {{ source('raw','oms_returns') }}
)

select * from src
