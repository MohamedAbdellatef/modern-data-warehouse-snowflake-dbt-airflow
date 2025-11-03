# Snowflake bootstrap (GULFMART)

This folder contains idempotent SQL to stand up Snowflake for the project.

## Order of execution

1. **01_create_warehouse.sql**  
   - Creates `WH_INGEST` + `WH_DBT` + `WH_BI` and a `DBT_ROLE` + `BI_ROLE`.

2. **02_create_db_schema.sql**  
   - Creates `GULFMART` DB and schemas `RAW, STG, CORE, MART`.  
   - Grants basic privileges to `DBT_ROLE`.

3. **03_storage_integration.sql**  
   - Creates `ADLS_INT`.  
   - After running, execute `DESC INTEGRATION ADLS_INT` → copy `CLIENT_ID` to Azure AD and grant **Storage Blob Data Reader** on the storage account.

4. **04_create_stages.sql**  
   - One stage per ADLS container + a reusable `RAW_COMMON_CSV` file format.

5. **05_create_raw_tables.sql**  
   - Creates RAW tables (light-typed, mostly `VARCHAR`) with `ingestion_date` default and `source_file` column.

6. **06_copy_into_raw.sql**  
   - Loads from ADLS → RAW using query-based COPY to capture.  
   - No transformations are applied here; cleaning happens in dbt/STG.

## Notes  
- Re-running COPY is safe; de-duplication is handled later in STG using keys & tests.

