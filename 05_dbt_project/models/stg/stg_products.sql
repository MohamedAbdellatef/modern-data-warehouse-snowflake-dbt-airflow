{{ config(materialized='table', tags=['stg']) }}

with src as (
    select
        {{ norm_code('sku') }}                     as sku,
        initcap(trim(product_name))                as product_name,
        initcap(trim(category))                    as category,
        initcap(trim(brand))                       as brand,
        {{ norm_code('vat_class') }}               as vat_class,
        {{ strip('source_system') }}               as source_system,
        current_date()                             as load_date
    from {{ source('raw','pim_products') }}
)

select * from src

