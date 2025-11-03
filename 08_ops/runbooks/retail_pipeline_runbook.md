# Runbook — Retail Daily Pipeline

**DAG**: `retail_pipeline`  
**Schedule**: 06:00 Asia/Riyadh (daily)  
**SLA**: Finish by 06:30 Asia/Riyadh  
**Owners**: Data Eng (on-call)  

## Purpose
Load raw → dbt (stg → core → marts). Produce trusted metrics (GMV ex-VAT AED, Orders, AOV, Targets vs Actual).

## Inputs
- ADLS/Snowpipe external tables (RAW.OMS.*)
- Seeds: FX rates, VAT policy, Store targets

## Outputs
- CORE dims/facts, MARTS marts
- Elementary DQ HTML report (artifact)
- dbt docs (artifact / Pages)

## How to re-run today
```bash
# from repo root (Airflow box)
airflow tasks test retail_pipeline dbt_run {{ ds }}
# or run dbt directly
cd 05_dbt_project && dbt build --select state:modified+ --fail-fast
