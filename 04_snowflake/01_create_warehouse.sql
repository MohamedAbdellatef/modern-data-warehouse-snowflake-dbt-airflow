-- 01_create_warehouse.sql
-- Create three warehouses (ingest, dbt, BI) and roles.
-- Safe to rerun.

USE ROLE ACCOUNTADMIN;

-- Warehouses
CREATE WAREHOUSE IF NOT EXISTS WH_INGEST
    WITH WAREHOUSE_SIZE      = 'XSMALL'
         AUTO_SUSPEND        = 60
         AUTO_RESUME         = TRUE
         INITIALLY_SUSPENDED = TRUE
         COMMENT             = 'ETL/ELT ingestion warehouse';

CREATE WAREHOUSE IF NOT EXISTS WH_DBT
    WITH WAREHOUSE_SIZE      = 'XSMALL'
         AUTO_SUSPEND        = 60
         AUTO_RESUME         = TRUE
         INITIALLY_SUSPENDED = TRUE
         COMMENT             = 'dbt transforms, tests';

CREATE WAREHOUSE IF NOT EXISTS WH_BI
    WITH WAREHOUSE_SIZE      = 'XSMALL'
         AUTO_SUSPEND        = 60
         AUTO_RESUME         = TRUE
         INITIALLY_SUSPENDED = TRUE
         COMMENT             = 'Business Intelligence queries';

-- Roles
CREATE ROLE IF NOT EXISTS DBT_ROLE;
CREATE ROLE IF NOT EXISTS BI_ROLE;

-- NOTE:
-- Replace <USERNAME> with your own Snowflake user, then uncomment if you want
-- to grant these roles directly to a user.
-- GRANT ROLE DBT_ROLE TO USER <USERNAME>;
-- GRANT ROLE BI_ROLE  TO USER <USERNAME>;

-- Warehouses usage
GRANT USAGE ON WAREHOUSE WH_DBT    TO ROLE DBT_ROLE;
GRANT USAGE ON WAREHOUSE WH_INGEST TO ROLE DBT_ROLE;  -- if dbt can also ingest
GRANT USAGE ON WAREHOUSE WH_BI     TO ROLE BI_ROLE;
