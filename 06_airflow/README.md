# Airflow Orchestration — retail_pipeline

DAG: `retail_pipeline`  
Purpose: Orchestrate the **daily GulfMart pipeline**:

ADLS → Snowflake RAW → dbt (STG / CORE / MARTS) → Slack alert on failure.

---

## Location

- DAG file: `06_airflow/dags/retail_pipeline.py`
- Snowflake SQL: `04_snowflake/06_copy_into_raw.sql`
- dbt project mounted in the Airflow container at:

  ```text
  /opt/airflow/dags/05_dbt_project
