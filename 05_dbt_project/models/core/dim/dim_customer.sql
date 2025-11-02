{{ config(materialized='table') }}

with s as (
    select 
        *
    from {{ ref('snap_customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['customer_id','dbt_valid_from']) }} as customer_key,
    customer_id,
    loyalty_tier, is_vip_flag, source_system,
    registration_ts, first_purchase_ts, country_code, city, email_optin_flag, birth_date,
    (dbt_valid_to is null)::boolean as is_current,
    dbt_valid_from  as effective_from,
    dbt_valid_to    as effective_to,
    ingestion_date  as load_date
from s