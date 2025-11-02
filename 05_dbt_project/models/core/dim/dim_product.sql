{{ config(materialized='table') }}

with s as ( select * from {{ ref('snap_products') }} )
select
    {{ dbt_utils.generate_surrogate_key(['sku','dbt_valid_from']) }} as product_key,
    sku, product_name, category, brand, vat_class,
    (dbt_valid_to is null)::boolean as is_current,
    dbt_valid_from as effective_from,
    dbt_valid_to   as effective_to,
    load_date
from s
