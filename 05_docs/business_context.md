# Business Context — GulfMart Retail Data Warehouse

## 1. Company Overview
**GulfMart Retail Group** is a mid-size omni-channel retailer operating in **United Arab Emirates 🇦🇪** and **Saudi Arabia 🇸🇦**.  
The company manages more than 80 stores across Riyadh, Jeddah, Dammam, Dubai, Abu Dhabi, and Sharjah, selling electronics, fashion, and home-appliance products through both physical stores and an online marketplace.

**Headquarters:** Dubai  
**Currencies:** AED (🇦🇪) & SAR (🇸🇦)  
**VAT:** 5 % UAE · 15 % KSA  
**Fiscal calendar:** Gregorian / Monthly close T + 2  
**Timezone policy:** All operational reporting aligns to **Asia/Riyadh (UTC + 3)**.

---

## 2. Business Problem

GulfMart’s leadership faces inconsistent and delayed reporting because data is scattered across multiple systems:

| Challenge | Impact |
|------------|---------|
| **Fragmented data sources** (POS, e-commerce, CRM, inventory) | No single version of truth |
| **Inconsistent VAT & currency handling** | Finance numbers differ across regions |
| **Manual Excel-based reporting** | BI refresh takes days, not hours |
| **No historical tracking** | Customer and product changes lost over time |

Executives and regional managers currently rely on disconnected Excel files and inconsistent KPIs, making it impossible to have a unified view of performance across countries.
As a result, store managers, finance teams, and marketing analysts cannot make timely, data-driven decisions.

---

## 3. Warehouse Objective

Build a **Modern Cloud Data Warehouse** to deliver a **single trusted source of truth** for sales, revenue (ex-VAT), and customer analytics across both UAE and KSA.

### Key Goals
1. **Unify** sales, customer, and store data from all systems.  
2. **Automate** daily refresh (T + 1 @ 06:00 Asia/Riyadh).  
3. **Standardize** VAT and currency logic.  
4. **Model** facts & dimensions using **Kimball methodology** (STG → CORE → MARTS).  
5. **Enable** near-real-time Power BI dashboards for Operations, Finance, and Marketing.

---

## 4. Stakeholders & Use Cases

| Department | Example Questions (QNFs) | Consumes From |
|-------------|--------------------------|---------------|
| **Operations** | How many completed orders per month by store? Which stores underperform? | `sales_monthly_by_store` mart |
| **Finance** | What is net revenue ex-VAT by country and currency? | `revenue_by_country` mart |
| **Marketing / CRM** | Who are the top 10 customers this quarter? How many active customers each month? | `dim_customer`, `fact_order` |
| **BI Team** | Can dashboards refresh daily without manual prep? | MARTS layer |
| **IT / Data Engineering** | Are pipelines auditable and recoverable? | RAW + STG layers, Airflow + dbt metadata |

---

## 5. Technical Vision

| Layer | Tool / Tech | Purpose |
|--------|--------------|----------|
| **Ingestion** | **Airflow / ADF** | Extract CSV & API data → ADLS Gen2 |
| **Storage (RAW)** | **ADLS Gen2 → Snowflake RAW schema** | Immutable landing zone |
| **Transformation** | **dbt on Snowflake** | Build STG, CORE (facts/dims), MARTS |
| **Orchestration** | **Airflow** | Automate daily load, run dbt + tests |
| **Quality & Lineage** | **dbt tests + docs** | not-null, unique, relationships |
| **Analytics** | **Power BI / Tableau** | Visualize KPIs for business users |

---

## 6. Core KPIs (Business Questions)

| ID | KPI / Metric | Definition |
|----|---------------|-------------|
| **R1** | Monthly Orders by Store | COUNT(DISTINCT order_id) per month per store |
| **R2** | Net Revenue Ex-VAT by Country | SUM(total_amount / 1.05 or / 1.15) |
| **R3** | Top 10 Customers by Spend | SUM(total_amount) GROUP BY customer |
| **R4** | Active Customers per Month | COUNT(DISTINCT customer_id WHERE orders ≥ 1) |
| **R5** | Orders by Payment Method | COUNT BY payment_method |
| **R6** | Store Performance Index | (Revenue vs Target) × Footfall |

---

## 7. Refresh & Governance

- **Schedule:** Airflow DAG runs daily @ 05:30 UTC (08:30 Dubai / 07:30 Riyadh)  
- **Pipeline:** Extract → ADLS → Snowflake RAW → dbt Transform → Power BI Refresh  
- **Data Quality:** dbt tests + Airflow alerts on failure  
- **Governance:** Snowflake Unity Catalog roles (`RAW_READ`, `CORE_WRITE`, `BI_READ`)  
- **Documentation:** dbt Docs + Architecture Diagram (`05_docs/architecture.png`)
- **Access Control:** Snowflake roles are separated by purpose (WH_INGEST, WH_DBT, WH_BI) to ensure cost control and least-privilege access
---