# Snowflake Bootstrap — GULFMART

Idempotent SQL scripts to stand up Snowflake for the **GulfMart** modern data warehouse.

## Order of execution

1. **01_create_warehouse.sql**  
   Creates 3 warehouses (`WH_INGEST`, `WH_DBT`, `WH_BI`) and roles (`DBT_ROLE`, `BI_ROLE`).

2. **02_create_db_schema.sql**  
   Creates the `GULFMART` database and schemas `RAW`, `STG`, `CORE`, `MART`.  
   Grants:
   - `DBT_ROLE` → full access to STG/CORE/MART + read-only RAW  
   - `BI_ROLE` → read-only MART

3. **03_storage_integration.sql**  
   Creates `ADLS_INT` storage integration for the ADLS Gen2 account.  
   After running, execute:

   ```sql
   DESC INTEGRATION ADLS_INT;
