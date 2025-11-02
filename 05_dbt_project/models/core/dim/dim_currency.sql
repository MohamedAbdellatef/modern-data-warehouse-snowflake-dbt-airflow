{{ config(materialized='table') }}

with src as (
    select    
        distinct currency_code
    from {{ ref('stg_fx_rates_daily') }}
    where currency_code is not null
)
select
    {{ dbt_utils.generate_surrogate_key(['currency_code']) }} as currency_key,
    currency_code,
    case currency_code  when 'AED' then 'UAE Dirham'
                        when 'SAR' then 'Saudi Riyal'
                        else currency_code end as currency_name,
    true::boolean as is_active_flag
from src
