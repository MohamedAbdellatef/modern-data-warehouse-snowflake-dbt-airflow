{% snapshot snap_customers %}
{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='customer_id',
        strategy='check',
        check_cols=['loyalty_tier','is_vip_flag','country_code','city','email_optin_flag']
    )
}}
select * from {{ ref('stg_customers') }}
{% endsnapshot %}