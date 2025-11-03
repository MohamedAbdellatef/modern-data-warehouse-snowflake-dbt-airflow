# Modern Retail Analytics Warehouse (Snowflake + dbt + Airflow)

End-to-end modern data warehouse for a fictional retailer **GulfMart**:

- **Ingestion** → RAW Snowflake tables (OMS, CRM, PSP, PIM, Finance, FX, VAT)
- **Transform** → `dbt` (staging → core dims/facts → marts)
- **Orchestrate** → Airflow DAG `retail_pipeline`
- **Operate** → SLOs, data contracts, cost monitoring, lineage & runbooks
- **Consume** → BI dashboards on top of curated marts (Power BI / Looker / Tableau)


---

## 1. Architecture

**Layers**

1. **01_data_lake** – Logical landing zone for CSV/external files (documentation only).
2. **04_snowflake** – Warehouse objects, roles, warehouses & storage design.
3. **05_dbt_project** – All transformations:
   - `stg` models (raw → clean, typed, tested).
   - `core` models:
     - Slowly-changing **dimensions** (customer, store, product, date, currency, channel, payment).
     - **facts**: `fact_order_line`, `fact_order`, `fact_customer_monthly_activity`, `fact_store_target_monthly`.
   - `marts`:
     - Sales, customers, returns, payments, targets vs actuals.
4. **06_airflow** – DAG `retail_pipeline` that runs dbt daily.
5. **07_bi** – BI models / dashboard definitions (documentation, not tool-specific).
6. **08_ops** – Data contracts, checks, monitors, SLOs, cost queries, runbooks.
7. **09_ci_cd** – GitHub Actions workflow + notes for automated testing.
8. **10_docs** – Extra design docs / exported diagrams.

Core design artifacts live under `03_design`:

- **Bus matrix** for the three business processes.
- **Grain cards** for each fact.
- **Dim/fact ERD** for the core warehouse.

---

## 2. Business Processes & Facts

### 2.1 Order to Cash

- **Facts**
  - `CORE.fact_order_line` – 1 row per `order_number × line_number`.
  - `CORE.fact_order` – 1 row per `order_number`.
- **Conformed dimensions**
  - `dim_customer`, `dim_store`, `dim_product`, `dim_channel`, `dim_currency`, `dim_date`, `dim_payment`.

Example KPIs:
- Gross / net sales ex-VAT in AED.
- Orders, lines, quantity.
- AOV, channel mix, store performance.

### 2.2 Customer Activity

- **Fact**
  - `CORE.fact_customer_monthly_activity` – 1 row per `customer × calendar_month`.
- Flags & metrics:
  - `is_active_customer_flag`, `is_repeat_customer_flag`,
  - orders count, net amount AED per month.

### 2.3 Store Target vs Actual

- **Fact**
  - `CORE.fact_store_target_monthly` – 1 row per `store × calendar_month`.
- Joins with `fact_order` to compute:
  - Target vs actual net sales, variance amount, variance %.

Marts in `05_dbt_project/models/marts` map directly to QNF cards:
- Monthly orders by store, net sales by country, AOV, channel mix,
- active customers, repeat rate, refund rate, store performance index,
- target vs actual revenue gap.

---

## 3. Repo Layout

```text
.
├── 00_overview/          # Problem statement, high-level architecture
├── 01_data_lake/         # Ingestion assumptions, file layout
├── 02_business/          # Business processes & KPIs (qnf, process docs)
├── 03_design/            # Bus matrix, grain cards, ERD diagrams
├── 04_snowflake/         # DDLs, roles, warehouses, storage notes
├── 05_dbt_project/       # dbt project (models, tests, macros, snapshots)
│   ├── models/
│   │   ├── stg/          # staging models from RAW
│   │   ├── core/
│   │   │   ├── dim/      # dim_* models
│   │   │   └── facts/    # fact_* models
│   │   └── marts/        # metric-ready marts
│   ├── snapshots/        # SCD snapshots: customers, products, stores
│   ├── macros/           # helper macros (e.g. casting helpers)
│   └── schema.yml        # tests & contracts
├── 06_airflow/
│   ├── dags/
│   │   └── retail_pipeline.py  # main DAG
│   └── README.md
├── 07_bi/                # dashboard specs / mockups
├── 08_ops/               # ops: contracts, cost, checks, monitors, SLO, runbooks
├── 09_ci_cd/
│   └── README.md         # describes CI workflow (dbt build on PRs)
├── 10_docs/              # extra docs (optional)
├── .github/workflows/
│   └── dbt_ci.yml        # CI: dbt build + tests
├── .pre-commit-config.yaml
├── LICENSE
└── README.md             # this file
```
