# Runbook — Retail Daily Pipeline

**DAG**: `retail_pipeline`  
**Schedule**: `0 6 * * *` (06:00 Asia/Riyadh, daily)  
**SLA**: Finish by 06:30 Asia/Riyadh  
**Owners**: Data Engineering (on-call)

## 1. Purpose

End-to-end load:

- RAW → STG (dbt)
- STG → CORE (dims/facts)
- CORE → MARTS (business KPIs)

Key outputs:

- GMV ex-VAT AED
- Orders / AOV
- Channel mix, refunds
- Store targets vs actuals

## 2. Inputs

- `RAW.OMS_*` tables (orders, items, payments, returns)
- `RAW.CRM_CUSTOMERS`, `RAW.PIM_PRODUCTS`, `RAW.POS_STORES`
- Seeds / configs:
  - FX rates
  - VAT policy
  - Store monthly targets

## 3. Normal happy-path run

1. Airflow kicks off `retail_pipeline` at 06:00.
2. Tasks:
   - `ingest_raw` (optional) – external tables / Snowpipe.
   - `dbt_run` – `dbt run --select stg+ core+ marts+`.
   - `dbt_test` – `dbt test`.
   - `elementary_report` (optional) – data quality HTML.
3. DAG finishes < 06:30.

## 4. How to re-run today

From the Airflow box:

```bash
# Dry-run a single task
airflow tasks test retail_pipeline dbt_run {{ ds }}

# Or run dbt manually
cd 05_dbt_project
dbt build --selector nightly --fail-fast
