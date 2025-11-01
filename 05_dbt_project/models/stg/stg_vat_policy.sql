{{ config(materialized='table') }}

with src as (
    select
        {{ norm_code('country_code') }}                 as country_code,
        try_to_decimal({{ strip('vat_rate') }},5,2)     as vat_rate,
        try_to_date(effective_from)                     as effective_from,
        {{ strip('source_system') }}                    as source_system,
        ingestion_date::timestamp_ntz                   as ingestion_date,
        current_date()                                  as load_date
    from {{ source('raw','gov_vat_policy') }}
)

select * from src
