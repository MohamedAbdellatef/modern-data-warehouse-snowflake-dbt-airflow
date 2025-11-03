-- 04_create_stages.sql
-- One external stage per ADLS container + a reusable CSV file format.
-- Safe to rerun.

USE ROLE SYSADMIN;
USE DATABASE GULFMART;

-- Shared CSV file format for RAW loads
CREATE OR REPLACE FILE FORMAT GULFMART.RAW.RAW_COMMON_CSV
  TYPE                       = CSV
  FIELD_DELIMITER            = ','
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER                = 1
  EMPTY_FIELD_AS_NULL        = TRUE
  NULL_IF                    = ('', 'NULL');

-- Stages (each maps to a container)
CREATE OR REPLACE STAGE GULFMART.RAW.CRM_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/crm/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.OMS_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/oms/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.PSP_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/psp/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.ERP_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/erp/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.FINANCE_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/finance/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.GOV_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/gov/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.POS_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/pos/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;

CREATE OR REPLACE STAGE GULFMART.RAW.PIM_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL                 = 'azure://datafromsources.blob.core.windows.net/pim/'
  FILE_FORMAT         = GULFMART.RAW.RAW_COMMON_CSV;
