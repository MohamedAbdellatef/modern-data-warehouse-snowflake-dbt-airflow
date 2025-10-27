# GRAIN CARD — `core.fact_order`

## 1) Purpose (what this table is for)
Aggregated transactional fact representing **one completed order** in the *Order to Cash* process.  
Provides the core metrics for store, channel, and country-level reporting.

This fact powers:
- Order counts (R1)
- Net revenue ex-VAT by store / country (R2)
- Average Order Value (R4)
- Channel mix (R6)
- Payment-method and refund analytics (R3, R5)

It is built by rolling up line-level transactions from `core.fact_order_line`.

---

## 2) Grain (one row = …)
**1 row = one completed order at its fulfillment timestamp (`order_local_ts`)**

**Fact type:** Transactional (header-level rollup).  
Each row summarizes the entire order across all items and payments.

---

## 3) Upstream sources (CORE / STG)
- `core.fact_order_line` — base line-level transactions
- `stg_oms_orders` — header attributes (status, customer, channel, payment method)
- Reference dims:
  - `dim_store`, `dim_customer`, `dim_channel`, `dim_currency`, `dim_date`
  - (Optionally) `dim_payment_method`

---

## 4) Primary / Natural keys
- **Natural PK:** `order_number`
- **Degenerate dim:** `order_number` kept as varchar for drill-through and reconciliation
- **Optional SK:** `order_sk = hash(order_number)`

---

## 5) Foreign keys (conformed dimensions)

| Column           | Dimension Table             | Notes                                             |
| ---------------- | --------------------------- | ------------------------------------------------- |
| `order_date_key` | `dim_date.date_key`         | Based on `order_local_ts`                         |
| `store_key`      | `dim_store.store_key`       | From `store_id` (SCD2; captures country/timezone) |
| `customer_key`   | `dim_customer.customer_key` | Nullable; UNKNOWN for guests                      |
| `channel_key`    | `dim_channel.channel_key`   | Derived from normalized `channel`                 |
| `currency_key`   | `dim_currency.currency_key` | From `currency_code`                              |
| `payment_key`    | `dim_payment_method.key`    | From `psp_payments.payment_method` (optional)     |

---

## 6) Measures (facts)
All amounts stored in **native currency** and, when applicable, AED-converted versions for consolidated reporting.

| Measure | Definition | Type |
|----------|-------------|------|
| `orders_count` | Always 1 per row (for counting orders) | int |
| `order_gross_amount_native` | Σ line `gross_amount` (pre-VAT) | numeric(18,2) |
| `order_vat_amount_native` | Σ line `vat_amount` | numeric(18,2) |
| `order_net_amount_native` | Σ line `net_amount` (ex-VAT) | numeric(18,2) |
| `order_net_amount_aed` | `order_net_amount_native × FX(order_date,currency→AED)` | numeric(18,2) |
| `refund_net_amount_native` | optional; join refund lines if available | numeric(18,2) |
| `aov_native` | `order_net_amount_native / orders_count` | derived |
| `aov_aed` | `order_net_amount_aed / orders_count` | derived |

*All monetary amounts rounded per order after aggregation.*

---

## 7) Attributes (non-measure)
- `order_number`
- `store_id`
- `customer_id_nat`
- `channel`
- `currency_code`
- `country`
- `final_status`
- `order_flag`
- `payment_method` (dominant or primary)
- `order_local_ts`, `order_utc_ts`
- `ingestion_date`

---

## 8) Inclusion / Exclusion logic
- **Include:** orders with `final_status ∈ ('COMPLETED','FULFILLED')`
- **Exclude:**  
  - `final_status = 'CANCELLED'`  
  - `order_flag ∈ ('TEST','INTERNAL','FRAUD')`

For split-payment orders, keep one row per order using the **dominant** payment method (largest captured amount).  
Future enhancement: create `fact_order_payment_bridge` for multi-payment orders.

---

## 9) Regional policies (VAT / FX / Online stores)
- VAT and FX rules inherited from `fact_order_line`.
- UAE VAT 5 %, KSA VAT 15 %; zero-rated items excluded in `order_vat_amount_native`.
- AED conversion uses FX rate on `order_local_date`, frozen after **T+2**.
- Online orders belong to virtual stores `ONLINE_UAE` / `ONLINE_KSA` (same currency/timezone).

---

## 10) Incremental & late-arrival policy
- Built incrementally from `fact_order_line` using `order_number` watermark.
- For each run:
  - Re-aggregate all lines where `order_local_ts >= current_date - 7`.
  - Capture late rows / adjustments until **T+2** close.
- After T+2, month is frozen; reprocessing allowed only via Finance approval.

---

## 11) Data Quality Tests — Design Phase

### Uniqueness
- `order_number` unique in `core.fact_order`.

### Foreign Key Relationships
- All FK columns must resolve to their dimension SKs.

### Not Null
- `order_number`, `store_key`, `order_date_key` required.

### Arithmetic Consistency
- For every order:  
  `order_gross_amount_native ≈ order_net_amount_native + order_vat_amount_native` (±0.01 tolerance)
- Aggregated across store / month: same identity must hold.




### Business Rules

* `order_net_amount_native >= 0`
* `order_vat_amount_native >= 0`

---

## 12) Performance & modeling notes

* Cluster by `order_date_key`, `store_key`.
* Partition by month for incremental refresh.
* Store amounts in native currency; AED conversions handled downstream if needed.
* Keep degenerate `order_number` for easy drill-through to order lines.
* This table serves as the “header grain” for the Order to Cash process.

---

## 13) Outputs & consumers

* **Model:** `core.fact_order` (incremental dbt model)
* **Downstream marts:**

  * `mart_sales_monthly_by_store`
  * `mart_revenue_country_monthly`
  * `mart_aov_monthly`
  * `mart_channel_mix_monthly`
  * `mart_payment_mix_monthly`
* **BI:** Power BI → Operations & Finance dashboards

---

## 14) Acceptance examples

* Oct 2025, Riyadh Gallery = 205 completed orders.

  * `SUM(order_net_amount_native)` matches `Σ line.net_amount` for same store-month.
* VAT triangle check:
  `Σ gross ≈ Σ net + Σ vat` within ± 0.01 per store-month.
* AOV example:

  * Two orders: 100 AED and 200 AED → AOV = 150 AED.

---