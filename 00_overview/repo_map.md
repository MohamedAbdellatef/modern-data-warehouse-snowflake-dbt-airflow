High-level guide to the folders in this project.

- `01_data_lake/` — ADLS layout (manifest + sample CSVs)
- `02_business/` — Business processes + QNF requirements
- `03_design/` — Grain cards + ERDs + S2T mapping
- `04_snowflake/` — Idempotent SQL to create warehouses, DB/schemas, stages, RAW tables, and COPY into RAW
- `05_dbt_project/` — dbt project (sources → stg → core dims/facts → marts)
- `06_airflow/` — Airflow DAG (`retail_pipeline.py`) orchestrating COPY + dbt + alerts
- `07_bi/` — Power BI notes, PBIX file (if included), and screenshots
- `08_ops/` — Roles/grants, cost notes, monitoring, runbooks, SLOs
- `09_ci_cd/` — CI/CD pipeline configs (e.g. `.github/workflows/dbt_ci.yml`)
- `10_docs/` — Extra documentation, validations, changelog
