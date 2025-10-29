# gulfmart_daily_ingestion DAG

This DAG represents the production ingestion flow:
1. Source systems land daily CSV snapshots into Azure Data Lake Storage Gen2 (I am using my real ADLS account with an actual container).
2. Snowflake has an external stage that points to that ADLS container.
3. Airflow triggers Snowflake `COPY INTO` to load that day's partition (`load_date={{ ds }}`) into the RAW schema.
4. After RAW is loaded, downstream steps (dbt STG → CORE → MARTS) can run for transformation and KPI serving.

This pattern (ADLS landing → Snowflake RAW → dbt) is commonly used in retail / payments / e-commerce data teams in KSA and UAE.
