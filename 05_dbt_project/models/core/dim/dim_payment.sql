{{ config(materialized='table') }}

with src as (
    select 
        payment_method,
        payment_type,
        payment_status,
        count(*) as record_count  -- Optional: Keep track of duplicate counts
    from {{ ref('stg_payments') }}
    group by 
        payment_method,
        payment_type,
        payment_status
),
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['payment_method','payment_type','payment_status']) }} as payment_key,
        payment_method, 
        payment_type, 
        payment_status,
        (payment_type='REFUND')::boolean as is_refund_flag
    from src
)
select * from final
