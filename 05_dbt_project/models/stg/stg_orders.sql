{{ config(materialized='table') }}

with src as (
    select
        {{ strip('order_number') }}                        as order_number,
        {{ strip('customer_id_nat') }}                     as customer_id_nat,
        {{ strip('store_id') }}::number                    as store_id,
        {{ norm_code('channel') }}                         as channel_code,   -- POS/WEB/MARKETPLACE
        {{ norm_code('final_status') }}                    as final_status,   -- COMPLETED/FULFILLED/CANCELLED
        {{ safe_ts('order_local_ts') }}                    as order_local_ts,
        {{ safe_ts('order_utc_ts') }}                      as order_utc_ts,
        {{ norm_code('order_flag') }}                      as order_flag_code, -- TEST/INTERNAL/FRAUD or null
        {{ strip('source_system') }}                       as source_system,
        to_date(ingestion_date)                            as load_date
    from {{ source('raw','oms_orders') }}
)

select * from src
