# QNF: R7 — Active Customers per Month

**Question**: How many **unique customers** had **≥1 completed order** per **calendar month**?
**Owner / Decision**: Ops & CRM — footprint, engagement, retention.

---

## Metric (definitions)

* **active_customers = COUNT(DISTINCT customer_id_nat)**
  where `final_status ∈ {'Completed','Fulfilled'}` and `order_flag ∉ {'Test','Internal','Fraud'}`.

> **Identity rule:** `customer_id_nat` is the **master customer identifier** after identity resolution (POS ↔ e-com). If only channel-specific IDs exist, map to a **customer_master_id** first.
> **Guest/anonymous orders:** exclude by default (or count under `GUEST` bucket if business requests—document choice).

---

## Population

All **customer orders** (POS + e-commerce) that reached **final status** within the period.
E-commerce orders are mapped to **ONLINE_UAE / ONLINE_KSA** virtual stores.

---

## Time Grain & Anchor

* **Grain**: Calendar **month**
* **Anchor timestamp**: **store-local order timestamp** (`order_local_ts`)
* **Boundary**: Month starts **00:00 local** on the 1st

---

## Timezone & Boundary Policy

* UAE → `Asia/Dubai (UTC+4)`
* KSA → `Asia/Riyadh (UTC+3)`
  HQ roll-ups displayed in **Asia/Riyadh**.

---

## Breakdowns (Primary)

* **Country → City → Store**
  *(Note: a single customer can appear in multiple stores/cities/countries within the same month; counts are per-group and not globally de-duplicated unless specified.)*

**Drilldowns (Secondary)**

* **Channel** (POS / Web / Marketplace)

---

## Currency / FX

N/A — count metric.

---

## Filters (In / Out)

* **Include:** `final_status ∈ {'Completed','Fulfilled'}`; non-null `customer_id_nat`.
* **Exclude:** `order_flag ∈ {'Test','Internal','Fraud'}`, `status='Cancelled'`, `customer_id_nat IS NULL` (or treat as `GUEST` per policy).

---

## Related Dimensions

* `dim_customer` (SCD2; use **current row** for attributes when grouping by segment, etc.)
* `dim_store` (country, currency, timezone)
* `dim_date` (role: order_date)
* `dim_channel`

---

## SLA / Freeze

* Freshness: **T+1 by 06:00 Asia/Riyadh (03:00 UTC)**
* Month **locks at T+2** (values frozen after finance close)

---

## Acceptance Example

**2025-10**, **Riyadh Gallery** → **27** distinct active customers.

---