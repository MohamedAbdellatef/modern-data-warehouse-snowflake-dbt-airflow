{{ config(materialized='table') }}

WITH src AS (
    SELECT 
        CAST(fx_date AS DATE)                  AS fx_date,
        {{norm_code('from_ccy')}}              AS currency_code,
        TRY_CAST(rate_to_aed AS DECIMAL(18,6)) AS conversion_rate_to_aed,
        {{strip('source_system')}}             AS source_system,
        CAST(ingestion_date AS DATE)           AS load_date,
        {{norm_code('to_ccy')}}                AS _to_ccy
    FROM {{ source('raw','fx_rates_daily') }}
)

SELECT * FROM src
