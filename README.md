# modern-data-warehouse-snowflake-dbt-airflow
## 🏗️ High-Level Architecture
![Data Architecture](05_docs/06_architecture_design/modern_dwh_architecture.gif)

## 📂 Project Structure
```
modern-data-warehouse-snowflake-dbt-airflow/
│
├── README.md                          # full project overview
├── LICENSE
├── .gitignore
│
├── 01_airflow_dags/                   # orchestration layer
│   ├── retail_pipeline.py             # main DAG: sense_snowpipe → dbt_run → dbt_test → slack alert
│   ├── sensors/
│   │   └── sense_snowpipe.py          # optional sensor to check Snowpipe COPY_HISTORY
│   ├── operators/
│   │   └── dbt_operator.py            # custom wrapper for dbt commands
│   └── configs/
│       └── airflow_variables.json     # connections, schedules, Slack webhook, etc.
│
├── 02_adls_raw_data/                  # simulated ADLS Gen2 landing zone (for demo)
│   ├── orders/year=2025/month=01/day=01/orders_20250101.parquet
│   ├── customers/year=2025/month=01/day=01/customers_20250101.parquet
│   ├── stores/...
│   └── products/...
│
├── 03_snowflake/                      # DDL + Snowpipe + RBAC
│   ├── scripts/
│   │   ├── create_database.sql
│   │   ├── create_warehouses.sql
│   │   ├── create_stages_snowpipe.sql
│   │   └── grants_rbac.sql
│   ├── snowpipe/
│   │   ├── orders_pipe.json
│   │   ├── customers_pipe.json
│   │   └── ...
│   └── stage_definitions/
│       └── adls_external_stage.sql
│
├── 04_dbt_project/                    # transformation + data modeling layer
│   ├── dbt_project.yml
│   ├── profiles.yml.example
│   │
│   ├── models/
│   │   ├── raw/                       # references to Snowpipe external tables
│   │   │   └── sources.yml
│   │   │
│   │   ├── stg/                       # staging: type casting, dedup, normalization
│   │   │   ├── stg_orders.sql
│   │   │   ├── stg_customers.sql
│   │   │   └── stg_stores.sql
│   │   │
│   │   ├── core/                      # ⭐ dimensional modeling lives here ⭐
│   │   │   ├── dim_customer.sql       # dimension table (SCD2)
│   │   │   ├── dim_store.sql          # dimension table
│   │   │   ├── fact_order.sql         # transactional fact
│   │   │   ├── fact_customer_month.sql# periodic snapshot fact
│   │   │   └── snapshots/
│   │   │       └── dim_customer_snapshot.sql
│   │   │
│   │   ├── marts/                     # business marts / KPI layer
│   │   │   ├── sales_monthly_by_store.sql
│   │   │   ├── revenue_by_country.sql
│   │   │   └── customer_retention_monthly.sql
│   │   │
│   │   └── tests/                     # dbt generic + custom tests
│   │       ├── schema_tests.yml
│   │       ├── test_vat_rules.sql
│   │       └── test_timezone_alignment.sql
│   │
│   ├── macros/
│   │   ├── incremental_helpers.sql
│   │   └── scd2_macros.sql
│   │
│   ├── seeds/
│   │   ├── currency_fx_rates.csv
│   │   └── dim_date.csv
│   │
│   └── analyses/
│       └── audit_row_counts.sql
│
├── 05_docs/                           # documentation & diagrams
│   ├── architecture_diagram.png
│   ├── star_schema_orders.png
│   ├── layer_explanations.md
│   ├── data_quality_policy.md
│   ├── lineage_screenshot.png
│   └── runbook_airflow_dbt.md
│
├── 06_powerbi_or_tableau/             
│   ├── dashboards/
│   │   ├── sales_overview.pbix
│   │   └── store_performance.twb
│   └── datasets/
│       └── marts_export.csv
│
└── 07_data_modeling_docs/             
    ├── QNF_templates/
    │   ├── R1_Monthly_Orders_by_Store.md
    │   ├── R2_Orders_by_Payment_Method.md
    │   └── ...
    ├── grain_cards/
    │   ├── fact_order_grain_card.md
    │   └── fact_customer_month_grain_card.md
    └── star_schemas/
        ├── orders_star.drawio
        └── customers_star.drawio
```
