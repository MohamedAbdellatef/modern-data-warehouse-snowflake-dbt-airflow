-- One stage per container + a reusable CSV file format.
-- Safe to rerun.

use role SYSADMIN;
use database GULFMART;

create or replace file format GULFMART.RAW.RAW_COMMON_CSV
  type = CSV
  field_delimiter = ',' 
  field_optionally_enclosed_by = '"'
  skip_header = 1
  empty_field_as_null = true
  null_if = ('', 'NULL');

CREATE OR REPLACE STAGE GULFMART.RAW.CRM_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/crm/'

CREATE OR REPLACE STAGE GULFMART.RAW.OMS_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/oms/'

CREATE OR REPLACE STAGE GULFMART.RAW.PSP_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/psp/'


CREATE OR REPLACE STAGE GULFMART.RAW.ERP_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/erp/'


CREATE OR REPLACE STAGE GULFMART.RAW.FINANCE_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/finance/'


CREATE OR REPLACE STAGE GULFMART.RAW.GOV_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/gov/'


CREATE OR REPLACE STAGE GULFMART.RAW.POS_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/pos/'


CREATE OR REPLACE STAGE GULFMART.RAW.PIM_STAGE
  STORAGE_INTEGRATION = ADLS_INT
  URL = 'azure://datafromsources.blob.core.windows.net/pim/'

