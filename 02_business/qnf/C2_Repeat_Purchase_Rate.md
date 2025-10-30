# QNF: C2 — Repeat Purchase Rate (Monthly)

**Question:**  
What **percentage of active customers** in a given **calendar month** are **repeat customers** (i.e., have purchased in any prior month)?

**Owner / Decision:**  
CRM & Marketing — retention, loyalty campaign ROI, and customer base health.

---

## Metric (Definitions)

* **active_customers** = COUNT(DISTINCT customer_id_nat)  
  where `final_status ∈ {'Completed','Fulfilled'}` and `order_flag ∉ {'Test','Internal','Fraud'}`.

* **repeat_customers** = COUNT(DISTINCT customer_id_nat)  
  where the same `customer_id_nat` has at least **one previous completed order** in any earlier calendar month.

* **repeat_purchase_rate** =  
  `ROUND(repeat_customers / NULLIF(active_customers, 0) * 100, 2)`

> Customers are counted once per month per country.  
> If a customer shopped in both UAE & KSA, they are considered separately per country (country-level repeat rate).  
> Guest/anonymous orders excluded unless a `GUEST` segment is defined.

---

## Population

All **customers** (registered, identified) who placed **≥1 completed order** in the given month.  
Data drawn from both POS and e-commerce sources after identity resolution.

---

## Time Grain & Anchor

* **Grain:** Calendar **month**
* **Anchor timestamp:** **store-local order timestamp** (`order_local_ts`)
* **Boundary:** Month starts **00:00 local** on the 1st

---

## Timezone & Boundary Policy

* UAE → `Asia/Dubai (UTC+4)`  
* KSA → `Asia/Riyadh (UTC+3)`  
  HQ roll-ups shown in `Asia/Riyadh`.

---

## Breakdowns (Primary)

* **Country → Channel (POS / Online / Marketplace)**  
* **Customer Segment (New / Repeat)**  

> Derived flags:
> - `is_repeat_customer = 1` if customer had ≥1 historical completed order before current month  
> - `is_new_customer = 1` if first ever order occurred in current month

---

## Currency / FX

N/A — percentage metric (count-based).

---

## Filters (In / Out)

* **Include:** completed/fulfilled orders, identified customers.  
* **Exclude:** test, internal, fraud, canceled, or guest orders (unless specified otherwise).

---

## Related Dimensions

* `dim_customer` (identity-resolved, SCD2)
* `dim_date` (role: order_date)
* `dim_channel`
* `dim_store` (country, timezone)

---

## SLA / Freeze

* Freshness: **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**  
* Month **locks at T+2**

---

## Acceptance Example

October 2025, KSA:  
- Active customers = 8,000  
- Repeat customers = 2,400  
→ Repeat Purchase Rate = **30.00%**

---
