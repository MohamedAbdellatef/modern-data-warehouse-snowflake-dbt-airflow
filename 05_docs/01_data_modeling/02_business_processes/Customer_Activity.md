# Process: Customer Activity & Retention

## 1) Purpose & Stakeholders
**Purpose.**  
Provide a trusted foundation for measuring **customer engagement and retention**.  
It tracks how many customers are **active per calendar month**, how many are **repeat vs new**, and how much **net revenue** each segment generates across UAE and KSA.

**Stakeholders.**  
CRM / Loyalty, Marketing, Management, BI / Analytics.

**SLA.**  
Monthly refresh; daily T+1 update for Month-to-Date metrics.  
Official month closes and freezes **T+2 06:00 Asia/Riyadh**.

---

## 2) Business Scope & Lifecycle
Covers the lifecycle of a **customer’s purchasing activity** from the first completed order onward.

**Lifecycle:**  
`First purchase → Active customer → Repeat → Dormant (no purchase)`  

Definitions:
- **Active** = ≥1 completed order in the given calendar month.  
- **New** = active this month but no prior orders.  
- **Repeat** = active this month *and* had ≥1 order in a prior month.  
- **Inactive** = no completed orders in the month.

**Include:** Orders with `final_status ∈ ('COMPLETED','FULFILLED')`.  
**Exclude:** Orders flagged `TEST`, `INTERNAL`, `FRAUD`, or `CANCELLED`.

---

## 3) Source Systems & Cadence
- **OMS:** `oms_orders.csv`, `oms_order_items.csv` → transactional order data (daily).  
- **CRM:** `crm_customers.csv` → customer master with loyalty tier, VIP flag (daily).  
- **Reference:** `pos_stores.csv` (country, timezone), `dim_date.csv` (calendar mapping).  

**Incremental watermark:** `ingestion_date` (accept late arrivals up to **T+2**).  
Evaluation cadence: monthly (bucketed by store-local calendar month).

---

## 4) Facts & Grain
- **Canonical:** `core.fact_customer_monthly_activity` — **1 row = 1 customer × 1 calendar month**.  
- **Grain type:** Periodic Snapshot (monthly).  
- **Derived:** None in v1.

This fact aggregates order-level data into customer-month summaries used for retention and loyalty analysis.

---

## 5) Measures & Formulas
| Measure | Description |
|----------|--------------|
| `is_active_flag` | 1 if customer placed ≥1 completed order this month |
| `is_repeat_flag` | 1 if customer has ≥1 completed order in any prior month |
| `is_new_flag` | 1 if first-ever order month = this month |
| `orders_count_month` | Count of completed orders this month |
| `total_net_amount_native_month` | Σ of order net amounts (ex-VAT, native currency) |
| `total_net_amount_aed_month` | Same converted to AED (FX frozen T+2) |
| `first_order_month` | First purchase month (YYYY-MM) |
| `last_order_month` | Most recent completed order month |
| `loyalty_tier`, `is_vip_flag` | From CRM attributes |

---

## 6) Keys
- **Natural key:** (`customer_id_nat`, `month_key`)  
- **Optional surrogate:** `customer_month_sk = hash(customer_id_nat, month_key)`  
- **Degenerate:** None  

Each combination of customer and month appears exactly once.

---

## 7) Conformed Dimensions
- `dim_customer` (SCD2: name, loyalty_tier, region, is_vip_flag)  
- `dim_date` (month grain, role: activity_month)  
- `dim_country` or `dim_store` (to derive UAE/KSA region)  
- `dim_channel` (POS / WEB / MARKETPLACE, if required for segmentation)

---

## 8) Time Behavior & Timezones
- Bucket orders by **store local time** (`Asia/Dubai` or `Asia/Riyadh`).  
- Month boundary = **00:00 local time** on the 1st.  
- Late-arrival window = 7 days; freeze after **T+2**.  
- Activity month = month(order_local_ts).  

---

## 9) Regional Policies (VAT / FX / Guests)
- **VAT:** Excluded; we use `net_amount` from Order to Cash.  
- **FX:** Use daily rate at order_local_date; conversions frozen after T+2.  
- **Guests:** Orders without valid `customer_id_nat` are excluded from customer metrics but tracked in `dim_customer.UNKNOWN` for DQ auditing.

---

## 10) Data Quality Rules
**Uniqueness:** (`customer_id_nat`, `month_key`) unique.  
**Relationships:**  
- `customer_key` in `dim_customer`  
- `month_key` in `dim_date`  
- `country_key` in `dim_country`  

**Business Logic:**  
- If `is_active_flag=0` ⇒ orders_count=0 and amounts=0.  
- If `is_repeat_flag=1` ⇒ `first_order_month < current_month`.  
- `repeat_count ≤ active_count`.  
- Exclude all TEST/FRAUD customers.

---

## 11) Transform Steps (RAW → STG → CORE)

**RAW → STG**  
- Filter to `COMPLETED` / `FULFILLED` orders.  
- Standardize `customer_id_nat`, `channel`, `currency_code`.  
- Derive `order_month_key` from `order_local_ts`.

**STG → CORE**  
- Aggregate per (`customer_id_nat`, `order_month_key`).  
- Count orders, sum `net_amount_native` and convert to AED.  
- Lookup first-ever order month to derive `is_repeat_flag`.  
- Join to `crm_customers` for loyalty tier, VIP flag.  
- Assign FK to `dim_date`, `dim_customer`, `dim_country`.

---

## 12) QNFs Served & Marts
| QNF | Description | Mart |
|------|--------------|------|
| **C1** | How many unique customers had ≥1 completed order per month? | `mart_customer_activity_monthly` |
| **C2** | What % of active customers are repeat customers? | `mart_customer_activity_monthly` |

These marts feed the CRM / Marketing retention dashboards (Active, New, Repeat rates per region).

---

## 13) Edge Cases
- Customers with only refunds → excluded from active counts.  
- Guest customers → mapped to `UNKNOWN`.  
- Orders split across timezones → follow **store local** calendar.  
- Customer merges or ID changes → handled in `dim_customer` SCD2.

---

## 14) Reconciliation & Controls
- **Active count = distinct customers** in qualified `oms_orders` for that month.  
- **Repeat ⊆ Active** (validate monthly).  
- **Revenue tie-back:** sum of `total_net_amount_aed_month` = sum of customer-level revenue from `fact_order_line`.  
- **Late arrivals after T+2** logged in audit table.

---

## 15) Outputs
- `core.fact_customer_monthly_activity`  
- `mart_customer_activity_monthly`  
- Power BI: “Customer Retention & Loyalty Dashboard”

---

## 16) Acceptance Examples
- **October-2025:**  
  - Active customers = 12,430  
  - Repeat customers = 7,900  
  - Repeat rate = 63.5%  
  - New customers = 4,530  
  - Total net spend = 5.8 M AED  

- **Customer #C00582**  
  - first_order_month = 2025-07  
  - orders_count_month = 3  
  - total_net_amount_aed_month = 540 AED  
  - is_active_flag = 1, is_repeat_flag = 1  

---

