-- Azure ADLS Gen2 storage integration.
-- Replace <TENANT_ID> and validate the allowed locations match your containers.
-- Safe to rerun.

use role ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION ADLS_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '<TENANT_ID>'
    STORAGE_ALLOWED_LOCATIONS = (
        'azure://datafromsources.blob.core.windows.net/crm/',
        'azure://datafromsources.blob.core.windows.net/oms/',
        'azure://datafromsources.blob.core.windows.net/psp/',
        'azure://datafromsources.blob.core.windows.net/erp/',
        'azure://datafromsources.blob.core.windows.net/finance/',
        'azure://datafromsources.blob.core.windows.net/gov/',
        'azure://datafromsources.blob.core.windows.net/pos/',
        'azure://datafromsources.blob.core.windows.net/pim/'
    )
    comment = 'ADLS Gen2 integration used by RAW stages';

-- After running, execute:
--   DESC INTEGRATION ADLS_INT;
-- Copy the CLIENT_ID shown and grant your service principal
-- "Storage Blob Data Reader" on the storage account (scope: This resource).