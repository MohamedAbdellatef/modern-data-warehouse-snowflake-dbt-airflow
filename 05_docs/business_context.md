### Business Context — GulfMart Retail Data Warehouse

**1. Company Overview**
GulfMart Retail Group is a mid-size omni-channel retailer in **UAE 🇦🇪** and **KSA 🇸🇦** (80+ stores across Riyadh, Jeddah, Dammam, Dubai, Abu Dhabi, Sharjah; channels: stores + marketplace).
**HQ:** Dubai · 
**Currencies:** AED/SAR · 
**VAT:** UAE 5%, KSA 15% · 
**Fiscal:** Gregorian, monthly close T+2.
**Time policy:** **Store-local time** for operational facts;
**HQ roll-ups** at **Asia/Riyadh (UTC+3)**.

---

**2. Business Problem**
Disparate POS, e-commerce, CRM, and inventory systems cause slow, inconsistent reporting.

| Challenge                          | Impact                        |
| ---------------------------------- | ----------------------------- |
| Fragmented sources                 | No single source of truth     |
| Inconsistent VAT/currency handling | Finance numbers don’t match   |
| Manual Excel pipelines             | BI refresh takes days         |
| No slowly changing history         | Customer/product changes lost |

---

**3. Warehouse Objective**
Deliver a **single trusted source of truth** for Sales/Revenue (ex-VAT) and Customer analytics across UAE & KSA.

**Goals**

1. **Unify** sales, customer, store data.
2. **Automate** daily refresh **T+1 @ 06:00 Asia/Riyadh (03:00 UTC)**.
3. **Standardize** VAT and currency rules; optional FX consolidation.
4. **Model** with **Kimball** (RAW→STG→CORE→MARTS).
5. **Enable** Power BI dashboards for Operations, Finance, Marketing.

---

**4. Stakeholders & Use Cases**

| Dept          | Example Questions                                     | Consumes                   |
| ------------- | ----------------------------------------------------- | -------------------------- |
| Operations    | Which stores underperform month-to-month?             | `sales_monthly_by_store`   |
| Finance       | What is **net revenue (ex-VAT)** by country/currency? | `revenue_by_country`       |
| Marketing/CRM | Top 10 customers by AED spend this quarter?           | `dim_customer`, sales mart |
| BI            | Can dashboards refresh daily without manual steps?    | MARTS                      |
| Data Eng      | Are loads auditable/replayable?                       | RAW + STG, lineage tests   |

---

**5. Technical Vision**

| Layer             | Tech                          | Purpose                                       |
| ----------------- | ----------------------------- | --------------------------------------------- |
| Ingestion         | Airflow/ADF + COPY/Snowpipe   | Land to ADLS → load to Snowflake RAW          |
| Storage           | ADLS Gen2 + **Snowflake RAW** | Immutable, lineaged copy                      |
| Transform         | **dbt on Snowflake**          | STG (clean), CORE (facts/dims), MARTS (stars) |
| Orchestration     | Airflow                       | Schedule dbt + tests                          |
| Quality & Lineage | dbt tests/docs                | not_null, unique, relationships, freshness    |
| Analytics         | Power BI/Tableau              | Business consumption                          |

**Governance & Security**

* **Roles:** `INGESTOR`, `TRANSFORMER`, `BI_READER` (least privilege).
* **Warehouses:** `WH_INGEST`, `WH_DBT`, `WH_BI` (auto-suspend).
* **Policies:** **Masking** (PII), **Row Access** (country scoping), **Object Tags** (classification).

---

**6. Core KPIs (clear definitions)**

| ID     | KPI                                   | Definition                                                                                                                                                |
| ------ | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **R1** | Monthly **Completed Orders** by Store | `COUNT(DISTINCT order_id)` where order_status in (‘Completed’, ‘Fulfilled’), grouped by store & calendar_month (store-local).                             |
| **R2** | **Net Revenue (ex-VAT)** by Country   | `SUM(net_amount)` where `net_amount = gross_amount − vat_amount`; amounts in **store currency**; provide **AED-consolidated** via daily FX at order_date. |
| **R3** | **Top 10 Customers by Spend (AED)**   | Rank customers by `SUM(net_amount_in_AED)` for the period.                                                                                                |
| **R4** | **Active Customers per Month**        | `COUNT(DISTINCT customer_id)` with ≥1 completed order in that month.                                                                                      |
| **R5** | **Payments by Method**                | From `fact_payment`: `COUNT(*)` by `payment_method` for completed payments.                                                                               |
| **R6** | **Store Performance Index (SPI)**     | Provisional: `(net_revenue / monthly_target) * (orders / footfall)`; to be finalized with Ops.                                                            |

---

**7. Refresh & Governance**

* **Schedule:** Airflow daily at **03:00 UTC** (**06:00 Riyadh / 07:00 Dubai**).
* **Pipeline:** Extract → ADLS → Snowflake **RAW** → dbt (STG/CORE/MARTS) → BI refresh.
* **DQ:** dbt tests (unique/not_null/relationships/freshness) + reconciliation checks.
* **Runbooks:** failure alerts, backfill from RAW, warehouse autosuspend.
* **Docs:** dbt Docs + `/docs/architecture.png`.

---