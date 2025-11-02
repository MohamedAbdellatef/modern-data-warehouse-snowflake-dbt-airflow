{{ config(materialized='table') }}

with s as (select * from {{ ref('snap_stores') }}),

base as (
  select
    {{ dbt_utils.generate_surrogate_key(['store_id','dbt_valid_from']) }} as store_key,
    store_id, store_code, store_name, city, country_code, currency_code, timezone, store_type,
    dbt_valid_from as effective_from,
    dbt_valid_to   as effective_to,
    case when dbt_valid_to is null then true else false end as is_current
  from s
),

unknown as (
  select
    cast('UNKNOWN' as string)      as store_key, -- Updated to match the string type
    cast(-1 as number)             as store_id,
    'UNKNOWN'                      as store_code,
    'Unknown Store'                as store_name,
    null                           as city,
    null                           as country_code,
    'AED'                          as currency_code,
    'UTC'                          as timezone,
    'UNKNOWN'                      as store_type,
    to_timestamp_ntz('1900-01-01') as effective_from,
    null                           as effective_to,
    true                           as is_current
)

select * from base
union all
select * from unknown
