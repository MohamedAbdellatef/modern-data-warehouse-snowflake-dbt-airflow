# Modern Retail Data Warehouse — Snowflake + dbt + Airflow

End-to-end **retail analytics** project (UAE / KSA) for orders, revenue ex-VAT, AOV, and store performance.

- **Domain:** GulfMart omni-channel retail (simulated data from CSV files)
- **Stack:** ADLS Gen2 → Snowflake (RAW → STG → CORE → MARTS) → dbt → Airflow → Power BI

> This repo is designed as a **portfolio project** for junior data engineering roles (UAE, KSA, Germany, remote).

---

## Architecture & Context

Start with:

1. `00_overview/architecture_diagram.png` – modern data warehouse architecture.
2. `00_overview/business_context.md` – business problem, KPIs, and technical vision.
3. `00_overview/repo_map.md` – guided index of the repo.

---

## Quickstart (local lab)

**Prerequisites**

- Snowflake account (trial is fine)
- Python + `dbt-snowflake`
- Access to run Airflow locally (optional but recommended)

**Steps**

1. **Provision Snowflake RAW**

   ```bash
   # In Snowflake
   -- run scripts in order
   04_snowflake/01_create_warehouse.sql
   04_snowflake/02_create_db_schema.sql
   04_snowflake/03_storage_integration.sql
   04_snowflake/04_create_stages.sql
   04_snowflake/05_create_raw_tables.sql
   04_snowflake/06_copy_into_raw.sql
