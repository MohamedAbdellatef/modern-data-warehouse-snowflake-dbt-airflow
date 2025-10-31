WITH source AS (
    SELECT * FROM {{ source('raw', 'crm_customers') }}
)
SELECT * FROM source