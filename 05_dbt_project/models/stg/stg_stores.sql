{{ config(materialized='table', tags=['stg']) }}

with src as (
    select
        try_to_number({{ strip('store_id') }})         as store_id,
        {{ norm_code('store_code') }}                  as store_code,
        initcap(trim(store_name))                      as store_name,
        initcap(trim(city))                            as city,
        {{ norm_code('country') }}                     as country_code,
        {{ norm_code('currency_code') }}               as currency_code,
        trim(timezone)                                 as timezone,
        {{ norm_code('store_type') }}                  as store_type,
        {{ safe_date('open_date') }}                   as open_date,
        {{ strip('source_system') }}                   as source_system,
        current_date()                                 as load_date
    from {{ source('raw','pos_stores') }}
)

select * from src
