{{ config(materialized='table') }}

WITH src AS (
    SELECT
        {{ strip('customer_id_nat') }}            AS customer_id,
        {{ strip('loyalty_tier') }}               AS loyalty_tier,
        {{ safe_bool('is_vip_flag') }}            AS is_vip_flag,
        {{ norm_code('source_system') }}          AS source_system,
        {{ safe_ts('registration_ts') }}          AS registration_ts,
        {{ safe_ts('first_purchase_ts') }}        AS first_purchase_ts,
        {{ norm_code('country_code') }}           AS country_code,
        initcap(trim(city))                       AS city,
        {{ safe_bool('email_optin_flag') }}       AS email_optin_flag,
        {{ safe_date('birth_date') }}             AS birth_date,

        -- audit from RAW
        ingestion_date::timestamp_ntz             AS ingestion_date
    FROM {{ source('raw','crm_customers') }}
)

SELECT * FROM src
