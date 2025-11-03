# Airflow Orchestration

DAG: `retail_pipeline`  
Purpose: Run the GulfMart dbt project (stg → core → marts) every morning.

## Location

- DAG file: `airflow/dags/retail_pipeline.py`
- dbt project mounted in the Airflow container at `/opt/airflow/dags/05_dbt_project`

## Schedule

- `0 6 * * *` (06:00 every day, Airflow timezone should be `Asia/Riyadh`)

## Tasks

1. `dbt_deps` — install dbt packages
2. `dbt_build` — `dbt build` for `models/stg`, `models/core`, `models/marts`
3. `dbt_docs` — `dbt docs generate`

## Alerts

- Slack failure alerts using connection **`slack_default`**
- Message format documented in `08_ops/alerts/slack_alerts.md`
