# Snowflake RAW Layer Setup

## Purpose
This folder contains scripts to initialize Snowflake compute, schemas, storage integration, and ingestion stages.

### 1️⃣ `01_create_warehouse.sql`
Defines the compute resource (warehouse).

### 2️⃣ `02_create_db_schema.sql`
Creates database and schemas (RAW, STG, CORE, MART).

### 3️⃣ `03_storage_integration.sql`
Creates a single secure integration between Snowflake and Azure Data Lake.

### 4️⃣ `04_create_stages.sql`
Defines one stage per ADLS container (CRM, OMS, PSP, ERP, Finance).

### 5️⃣ `05_create_raw_tables.sql`
Creates RAW layer tables corresponding to each source.

### 6️⃣ `06_copy_into_raw.sql`
Loads CSV data from each stage into Snowflake RAW tables.

### Result
This pipeline securely ingests data from Azure Data Lake Gen2 → Snowflake RAW → dbt STG/CORE/MARTS.
