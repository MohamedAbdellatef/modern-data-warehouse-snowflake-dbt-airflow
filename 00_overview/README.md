# Modern Data Warehouse — Snowflake + dbt + Airflow

**Goal.** End-to-end retail analytics (UAE/KSA): orders, revenue ex-VAT, AOV, targets vs actuals.

**Stack.** ADLS Gen2 → Snowflake (RAW→STG→CORE→MART) → dbt → Airflow → Power BI.

## Quickstart
1. Run SQL in `04_snowflake/` from `00_context.sql` → `08_verify_raw.sql`.
2. `cd 05_dbt_project && dbt deps && dbt build`.
3. Explore marts in `GULFMART.MART` (Power BI model under `07_bi/`).

## Repo Map
See `repo_map.md` for a guided index.