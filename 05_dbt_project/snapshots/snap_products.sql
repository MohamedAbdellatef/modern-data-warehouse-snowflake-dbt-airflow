{% snapshot snap_products %}
{{
    config(
    target_schema='SNAPSHOTS',
    unique_key='sku',
    strategy='check',
    check_cols=['product_name','category','brand','vat_class']
    )
}}
select * from {{ ref('stg_products') }}
{% endsnapshot %}