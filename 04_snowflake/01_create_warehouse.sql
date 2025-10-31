-- Create two warehouses: one for ingestion (COPY), one for dbt work, one for BI queries.
-- Safe to rerun.

use role ACCOUNTADMIN;

create warehouse if not exists WH_INGEST
    with warehouse_size = 'XSMALL'
    auto_suspend  = 60
    auto_resume   = true
    initially_suspended = true
    comment = 'ETL/ELT ingestion warehouse';

create warehouse if not exists WH_DBT
    with warehouse_size = 'XSMALL'
    auto_suspend  = 60
    auto_resume   = true
    initially_suspended = true
    comment = 'dbt transforms, tests';

create warehouse if not exists WH_BI
    with warehouse_size = 'XSMALL'
    auto_suspend  = 60
    auto_resume   = true
    initially_suspended = true
    comment = 'Business Intelligence queries';

--  create a dedicated dbt role
create role if not exists DBT_ROLE;
grant role DBT_ROLE to user MOHAMED;  -- change user if needed

-- Give DBT_ROLE the ability to use the dbt warehouse
grant usage on warehouse WH_DBT to role DBT_ROLE;
grant usage on warehouse WH_INGEST to role DBT_ROLE;  -- if you want dbt to ingest too

-- create a dedicated BI role
create role if not exists BI_ROLE;
grant role BI_ROLE to user MOHAMED;  -- change user if needed

-- Give BI_ROLE the ability to use the BI warehouse
grant usage on warehouse WH_BI to role BI_ROLE;
