{% snapshot snap_stores %}
{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='store_id',
        strategy='check',
        check_cols=['store_name','city','country_code','currency_code','store_type','timezone']
    )
}}
select * from {{ ref('stg_stores') }}
{% endsnapshot %}