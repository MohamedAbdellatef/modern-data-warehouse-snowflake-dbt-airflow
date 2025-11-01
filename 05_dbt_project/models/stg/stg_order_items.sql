{{ config(materialized='table', tags=['stg']) }}

with src as (
    select
        {{ strip('order_number') }}                                as order_number,
        try_to_number({{ strip('line_number') }})                  as line_number,
        try_to_number({{ strip('store_id') }})                     as store_id,

        {{ norm_code('sku') }}                                     as sku,

        try_to_decimal({{ strip('quantity') }}, 18, 3)             as quantity,
        try_to_decimal({{ strip('unit_price') }}, 18, 2)           as unit_price,
        coalesce(try_to_decimal({{ strip('discount_amount') }}, 18, 2), 0) as discount_amount,
        try_to_decimal({{ strip('gross_amount') }}, 18, 2)         as gross_amount,
        try_to_decimal({{ strip('vat_amount') }}, 18, 2)           as vat_amount,
        try_to_decimal({{ strip('net_amount') }}, 18, 2)           as net_amount,

        {{ norm_code('currency_code') }}                           as currency_code,
        {{ norm_code('country') }}                                 as country_code,
        initcap(trim(category))                                     as category,

        {{ safe_ts('order_local_ts') }}                            as order_local_ts,
        {{ safe_ts('order_utc_ts') }}                              as order_utc_ts,

        {{ norm_code('source_system') }}                           as source_system,
        to_date(ingestion_date)                                    as load_date
    from {{ source('raw','oms_order_items') }}
)

select * from src
