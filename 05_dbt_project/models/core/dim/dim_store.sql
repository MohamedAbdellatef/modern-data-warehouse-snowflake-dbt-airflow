{{ config(materialized='table') }}

with s as (
  select * from {{ ref('snap_stores') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['store_id','dbt_valid_from']) }} as store_key,
    store_id,
    store_code,
    store_name,
    city,
    country_code,
    currency_code,
    store_type,
    timezone,
    dbt_valid_from as effective_from,
    dbt_valid_to   as effective_to,
    (dbt_valid_to is null) as is_current,
    load_date
from s