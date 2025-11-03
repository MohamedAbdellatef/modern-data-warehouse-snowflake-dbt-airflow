# Business Context — GulfMart Retail Data Warehouse

## 1. Company Overview

GulfMart Retail Group is a mid-size omni-channel retailer in **UAE 🇦🇪** and **KSA 🇸🇦**  
(~80 stores across Riyadh, Jeddah, Dammam, Dubai, Abu Dhabi, Sharjah; channels: stores + marketplace).

- **HQ:** Dubai  
- **Currencies:** AED / SAR  
- **VAT:** UAE 5%, KSA 15%  
- **Fiscal:** Gregorian, monthly close T+2  
- **Time policy:**  
  - Operational facts at **store-local time**  
  - HQ roll-ups at **Asia/Riyadh (UTC+3)**

---

## 2. Business Problem

Disparate POS, e-commerce, CRM, and inventory systems cause slow, inconsistent reporting.

| Challenge                          | Impact                        |
| ---------------------------------- | ----------------------------- |
| Fragmented sources                 | No single source of truth     |
| Inconsistent VAT/currency handling | Finance numbers don’t match   |
| Manual Excel pipelines             | BI refresh takes days         |
| No slowly changing history         | Customer/product changes lost |

---

## 3. Warehouse Objectives

Deliver a **single trusted source of truth** for Sales/Revenue (ex-VAT) and Customer analytics across UAE & KSA.

**Goals**

1. **Unify** sales, customer, and store data.
2. **Automate** a daily refresh **T+1 @ 06:00 Asia/Riyadh (03:00 UTC)**.
3. **Standardize** VAT and currency rules; provide optional FX consolidation.
4. **Model** using **Kimball** (RAW → STG → CORE → MARTS).
5. **Enable** Power BI dashboards for Operations, Finance, and Marketing.

---

## 4. Stakeholders & Use Cases

| Dept          | Example Questions                                     | Consumes                   |
| ------------- | ----------------------------------------------------- | -------------------------- |
| Operations    | Which stores underperform month-to-month?             | `sales_monthly_by_store`   |
| Finance       | What is **net revenue (ex-VAT)** by country/currency? | `revenue_by_country`       |
| Marketing/CRM | Top 10 customers by AED spend this quarter?           | `dim_customer`, sales mart |
| BI            | Can dashboards refresh daily without manual steps?    | MARTS                      |
| Data Eng      | Are loads auditable and replayable?                   | RAW + STG, lineage tests   |

---

## 5. Technical Vision

| Layer             | Tech                               | Purpose                                       |
| ----------------- | ---------------------------------- | --------------------------------------------- |
| Ingestion         | Airflow + COPY/Snowpipe            | Land to ADLS → load to Snowflake RAW          |
| Storage           | ADLS Gen2 + **Snowflake RAW**      | Immutable, lineaged copy                      |
| Transform         | **dbt on Snowflake**               | STG (clean), CORE (facts/dims), MARTS (stars) |
| Orchestration     | Airflow                            | Schedule dbt + tests                          |
| Quality & Lineage | dbt tests + docs                   | not_null, unique, relationships, freshness    |
| Analytics         | Power BI / Tableau (simulated)     | Business consumption                          |

### Governance & Security

- **Roles:** `INGESTOR`, `TRANSFORMER`, `BI_READER` (least privilege).
- **Warehouses:** `WH_INGEST`, `WH_DBT`, `WH_BI` (auto-suspend).
- **Policies:** masking for PII, row access for country scoping, object tags for classification.

---

## 6. Dataset & Assumptions

This is a **portfolio project**, not real production data.

- **Sources:** CSV files that simulate POS, e-commerce, and reference data.
- **Landing:** Files are extracted via **Airflow** and landed in **Azure Data Lake Storage Gen2**.
- **Warehouse:** Data is loaded into **Snowflake RAW** (external + internal tables).
- **Transformations:** Implemented in **dbt** (STG → CORE → MARTS).
- **Refresh pattern:** Daily batch (**T+1**) with the option to replay from RAW.

---

## 7. Core KPIs

| ID     | KPI                                   | Definition                                                                                                                                                |
| ------ | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **R1** | Monthly **Completed Orders** by Store | `COUNT(DISTINCT order_id)` where `order_status IN ('Completed','Fulfilled')`, grouped by store & calendar_month (store-local).                            |
| **R2** | **Net Revenue (ex-VAT)** by Country   | `SUM(net_amount)` where `net_amount = gross_amount − vat_amount`; amounts in **store currency**; optional **AED-consolidated** via daily FX at order_date. |
| **R3** | **Top 10 Customers by Spend (AED)**   | Rank customers by `SUM(net_amount_in_AED)` for the period.                                                                                                |
| **R4** | **Active Customers per Month**        | `COUNT(DISTINCT customer_id)` with ≥ 1 completed order in that month.                                                                                    |
| **R5** | **Payments by Method**                | From `fact_payment`: `COUNT(*)` by `payment_method` for completed payments.                                                                               |
| **R6** | **Store Performance Index (SPI)**     | `(net_revenue / monthly_target) * (orders / footfall)`; to be finalized with Operations.                                                                  |

---

## 8. Refresh & Governance

- **Schedule:** Airflow daily at **03:00 UTC** (06:00 Riyadh / 07:00 Dubai).
- **Pipeline:** Extract → ADLS → Snowflake **RAW** → dbt (STG/CORE/MARTS) → BI refresh.
- **Data Quality:** dbt tests (unique, not_null, relationships, freshness) + reconciliation checks.
- **Runbooks:** failure alerts, backfill from RAW, warehouse autosuspend.
- **Docs:** dbt Docs + repo documentation under `10_docs/`.
