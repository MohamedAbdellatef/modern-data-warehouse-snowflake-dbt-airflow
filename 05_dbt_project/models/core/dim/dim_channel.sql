{{ config(materialized='table',schema='CORE') }}

with src as (
    select distinct channel_code from {{ ref('stg_orders') }}
),
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['channel_code']) }} as channel_key,
        channel_code,
        case channel_code
            when 'WEB' then 'Online Web'
            when 'MARKETPLACE' then 'Marketplace'
            when 'POS' then 'Physical Store'
        else 'Unknown'
        end as channel_name,
        (channel_code in ('WEB','MARKETPLACE'))::boolean as is_digital_flag
    from src
)
select * from final
