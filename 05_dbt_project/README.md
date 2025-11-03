# GulfMart Modern Data Warehouse (Snowflake + dbt + Airflow)

## Overview

This project builds an end-to-end analytics stack for GulfMart:

- **Data warehouse**: Snowflake
- **Transformation**: dbt (staging → core → marts)
- **Orchestration**: Airflow
- **CI/CD**: GitHub Actions running dbt on Snowflake

The main business domain is **Order to Cash**, **Customer Activity**, and **Store Target vs Actual**.

---

## Architecture

### Layers

- **RAW**: CSV files loaded into Snowflake raw tables (OMS, PSP, ERP-like sources).
- **STG** (`models/stg`):
  - Normalized, typed models for each source:
    - `stg_orders`, `stg_order_items`, `stg_payments`, `stg_returns`
    - `stg_customers`, `stg_products`, `stg_stores`
    - `stg_fx_rates_daily`, `stg_store_targets_monthly`, `stg_vat_policy`
- **SNAPSHOTS** (`snapshots/`):
  - Slowly changing dimensions:
    - `snap_customers`, `snap_products`, `snap_stores`
- **CORE** (`models/core`):
  - Dimensions:
    - `dim_date`, `dim_store`, `dim_customer`, `dim_product`,
      `dim_channel`, `dim_currency`, `dim_payment`
  - Facts:
    - `fact_order_line` – order line grain
    - `fact_order` – order header grain
- **MARTS** (`models/marts`):
  - Business-ready marts & KPIs:
    - `mart_monthly_orders_by_store`
    - `mart_net_sales_by_country_monthly`
    - `mart_aov_monthly`
    - `mart_refund_rate_amount_monthly`
    - `mart_channel_mix_monthly`
    - `mart_active_customers_monthly`
    - `mart_repeat_purchase_rate_monthly`
    - `mart_store_target_vs_actual_monthly`
    - `mart_store_performance_index`

---

## How to run dbt locally

From project root (`05_dbt_project`):

```bash
# Install dependencies
pip install dbt-snowflake

# Check connection
dbt debug --target dev

# Run snapshots
dbt snapshot

# Run all models
dbt run

# Run tests
dbt test

# Build only marts
dbt run -s models/marts/*
