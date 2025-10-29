CREATE OR REPLACE STORAGE INTEGRATION ADLS_INT
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = AZURE
    ENABLED = TRUE
    AZURE_TENANT_ID = '664517c8-7c40-415c-91b5-6bb35cea08f3'
    STORAGE_ALLOWED_LOCATIONS = (
        'azure://datafromsources.blob.core.windows.net/crm/',
        'azure://datafromsources.blob.core.windows.net/oms/',
        'azure://datafromsources.blob.core.windows.net/psp/',
        'azure://datafromsources.blob.core.windows.net/erp/',
        'azure://datafromsources.blob.core.windows.net/finance/',
        'azure://datafromsources.blob.core.windows.net/gov/',
        'azure://datafromsources.blob.core.windows.net/pos/',
        'azure://datafromsources.blob.core.windows.net/pim/'
    );