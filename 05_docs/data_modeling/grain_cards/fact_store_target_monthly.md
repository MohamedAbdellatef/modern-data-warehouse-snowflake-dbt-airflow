# GRAIN CARD — `fact_store_target_monthly`

## 1) Purpose
Unifies **monthly target vs actual performance** per physical store for operational and financial reporting.

---

## 2) Grain (one row = …)
**1 row = one store × one calendar month (store-local)**  
**Fact Type:** Periodic Snapshot (monthly)

---

## 3) Upstream Sources
- `stg_finance_targets` — store targets by month  
- `stg_fact_order` — actual net revenue per store-month  
- `stg_pos_stores` — store metadata (country, currency)  
- `dim_date` — calendar month mapping  

---

## 4) Primary / Natural Keys
- (`store_id`, `month_key`)  
- Optional surrogate: `store_month_sk = hash(store_id, month_key)`

---

## 5) Foreign Keys (Dimensions)
| Column | Dimension Table | Notes |
|---------|-----------------|-------|
| `store_key` | `dim_store` | Physical store attributes |
| `month_key` | `dim_date` | Calendar month |
| `country_key` | `dim_country` | Derived from store |
| `currency_key` | `dim_currency` | Native + AED |

---

## 6) Measures
| Column | Description | Type |
|---------|--------------|------|
| `target_amount_native` | Target in native currency | numeric(18,2) |
| `target_amount_aed` | Target converted to AED | numeric(18,2) |
| `actual_amount_native` | Actual sales (ex-VAT) | numeric(18,2) |
| `actual_amount_aed` | Converted actual sales | numeric(18,2) |
| `achievement_pct` | (actual / target) × 100 | numeric(9,2) |
| `variance_aed` | actual - target | numeric(18,2) |
| `variance_pct` | (actual - target) / target × 100 | numeric(9,2) |
| `orders_count` | Supporting metric | int |

---

## 7) Attributes
- `store_id`, `store_name`, `country`, `currency_code`
- `month_name`, `month_start_date`
- `data_load_date`

---

## 8) Time Columns
- `month_key` (links to `dim_date`)
- `month_start_date`
- `ingestion_date` (incremental watermark)

---

## 9) Inclusion / Exclusion Logic
- Include: Physical stores only, valid targets, completed/fulfilled orders.
- Exclude: ONLINE_* stores, cancelled/test/fraud orders, stores without assigned target.

---

## 10) Regional / Business Rules
- **VAT:** Excluded from actuals.  
- **FX:** Convert both target and actual using same daily rate at month-end; frozen after T+3.  
- **Store Timezone:** Asia/Dubai or Asia/Riyadh, depending on store.  

---

## 11) Incremental Strategy
- Monthly refresh (append + upsert).  
- Rebuild current and prior month only.  
- Watermark: `month_key`.  
- Late adjustments allowed until T+3 close.

---

## 12) Data Quality Tests
### Uniqueness
(`store_id`, `month_key`) unique.

### Relationships
- `store_key` in `dim_store`  
- `month_key` in `dim_date`

### Arithmetic
- `variance_aed = actual_amount_aed - target_amount_aed`  
- `achievement_pct = ROUND(actual_amount_aed / target_amount_aed * 100, 2)`

### Value Ranges
- `achievement_pct BETWEEN 0 AND 200`  
- `target_amount_aed > 0`  
- `currency_code ∈ {AED, SAR}`

---

## 13) Performance Notes
- Cluster by `month_key`, `store_key`
- Partition retention = 24 months
- Common joins with `fact_order` for audit

---

## 14) Output Object
`core.fact_store_target_monthly` (incremental dbt model)  
Used by: `mart_store_target_monthly`

---

## 15) Acceptance Examples
- Riyadh Gallery (Oct-2025):  
  - target_amount_aed = 487,000  
  - actual_amount_aed = 495,500  
  - variance_aed = +8,500  
  - achievement_pct = 101.7%  
- Dubai Mall (Oct-2025):  
  - target_amount_aed = 450,000  
  - actual_amount_aed = 465,000  
  - variance_aed = +15,000  
  - achievement_pct = 103.3%

---

