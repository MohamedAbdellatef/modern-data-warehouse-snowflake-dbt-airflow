-- Database & schemas + grants. Safe to rerun.

use role SYSADMIN;

-- Create the main database
CREATE OR REPLACE DATABASE GULFMART;
grant usage on database GULFMART to role DBT_ROLE;

-- Create schemas for each layer
CREATE OR REPLACE SCHEMA GULFMART.RAW;
CREATE OR REPLACE SCHEMA GULFMART.STG;
CREATE OR REPLACE SCHEMA GULFMART.CORE;
CREATE OR REPLACE SCHEMA GULFMART.MART;

-- Basic privileges for DBT_ROLE
grant usage on schema GULFMART.RAW  to role DBT_ROLE;
grant usage on schema GULFMART.STG  to role DBT_ROLE;
grant usage on schema GULFMART.CORE to role DBT_ROLE;
grant usage on schema GULFMART.MART to role DBT_ROLE;

grant create table on schema GULFMART.STG  to role DBT_ROLE;
grant create view  on schema GULFMART.STG  to role DBT_ROLE;
grant create table on schema GULFMART.CORE to role DBT_ROLE;
grant create view  on schema GULFMART.CORE to role DBT_ROLE;
grant create table on schema GULFMART.MART to role DBT_ROLE;
grant create view  on schema GULFMART.MART to role DBT_ROLE;