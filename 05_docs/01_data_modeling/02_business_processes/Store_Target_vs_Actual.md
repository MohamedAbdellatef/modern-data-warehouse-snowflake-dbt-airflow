# Process: Store Target vs Actual

## 1) Purpose & Stakeholders
**Purpose.**  
Provide visibility into **store performance against monthly sales targets**, measuring achievement %, variance, and trends across UAE and KSA.

**Stakeholders.**  
Retail Operations, Finance, and Management (Performance Review, Bonus Allocation).

**SLA.**  
Data available **T+1 06:00 Asia/Riyadh**.  
Targets and actuals frozen by **T+3** of the following month.

---

## 2) Business Scope & Lifecycle
Covers **monthly sales target assignment and performance tracking** per physical store.

**Lifecycle:**  
`Target Set → Month Running (Actual Orders) → Month Closed → Variance Calculated → Reporting`

**Include:**  
- Physical stores (POS only).  
- Orders with `final_status IN ('COMPLETED','FULFILLED')`.  
- Actuals derived from `fact_order` aggregated by store and month.

**Exclude:**  
- Online stores (ONLINE_UAE, ONLINE_KSA).  
- Test / Fraud / Internal transactions.

---

## 3) Source Systems & Cadence
- `finance_targets.csv` — monthly store-level targets (in native currency and AED).  
- `fact_order` — actual net sales (ex-VAT) per store/month.  
- `pos_stores.csv` — country, currency, timezone.  
- `dim_date.csv` — calendar month references.  

**Incremental watermark:** `month_key` (monthly refresh).  
Targets are typically uploaded by Finance at the start of each month.

---

## 4) Facts & Grain
- **Canonical fact:** `core.fact_store_target_monthly` — **1 row = 1 store × 1 calendar month**  
- **Fact type:** Periodic Snapshot (monthly)

This fact unifies *target* (budget) and *actual* (realized sales) for each store.

---

## 5) Measures & Formulas
| Measure | Formula | Notes |
|----------|----------|-------|
| `target_amount_aed` | From finance_targets | frozen at upload |
| `actual_amount_aed` | Σ of order net_amount_aed from fact_order | ex-VAT |
| `achievement_pct` | (actual / target) * 100 | capped at 200% |
| `variance_aed` | actual - target | absolute variance |
| `variance_pct` | (actual - target) / target * 100 | percentage variance |
| `order_count` | Σ completed orders | optional supporting metric |

---

## 6) Keys
- **Natural key:** (`store_id`, `month_key`)  
- **Optional surrogate key:** `store_month_sk = hash(store_id, month_key)`  
- Unique per store per month.

---

## 7) Conformed Dimensions
- `dim_store` (SCD2: includes region, currency, timezone, store_type)  
- `dim_date` (month grain)  
- `dim_country` (from store)  
- `dim_currency` (AED, SAR)

---

## 8) Time Behavior & Timezones
- Targets align with **store-local calendar months**.  
- Actuals use the same local month bucket (Asia/Dubai or Asia/Riyadh).  
- Freeze both after **T+3** to ensure stable KPI reporting.

---

## 9) Regional / Business Rules
- **VAT:** Actuals exclude VAT; targets are already ex-VAT.  
- **FX:** Both targets and actuals converted to AED for consolidation.  
- **Store Inclusion:** Online stores tracked separately in eCommerce process.

---

## 10) Data Quality Rules
**Uniqueness:** (`store_id`, `month_key`) unique.  
**Relationships:**  
- `store_key` exists in `dim_store`  
- `month_key` in `dim_date`  

**Arithmetic:**  
- `achievement_pct = ROUND(actual / target * 100, 2)`  
- `variance_aed = actual - target`  
- `variance_pct = variance_aed / target * 100`

**Validation:**  
- No negative targets.  
- Target must exist before variance calculation.  
- Country consistency (store.country = finance_targets.country).

---

## 11) Transform Steps (RAW → STG → CORE)
**RAW → STG**
- Load `finance_targets.csv` and normalize store codes, month, and AED conversion.
- Clean `fact_order` (exclude online stores, keep completed/fulfilled).
- Aggregate by store_id × month.

**STG → CORE**
- Join target and actual data on (store_id, month_key).  
- Compute `achievement_pct`, `variance_aed`, `variance_pct`.  
- Assign dimensional keys.  
- Write to `core.fact_store_target_monthly`.

---

## 12) QNFs Served & Marts
| QNF | Description | Mart |
|------|--------------|------|
| **S1** | What % of monthly revenue target did each physical store achieve? | `mart_store_target_monthly` |
| **S2** | How much above/below target (in AED) each store? | `mart_store_target_monthly` |

These marts feed Finance & Operations dashboards (Target Achievement).

---

## 13) Edge Cases
- Store closed mid-month → prorate target (optional).  
- Store with zero target → achievement = NULL.  
- Missing FX → flag and exclude from consolidated totals.  
- Negative sales (full refunds) → adjust actual accordingly.

---

## 14) Reconciliation & Controls
- Σ actuals per country = Σ from `fact_order`.  
- Σ target per country = Σ from Finance targets sheet.  
- Variance per country = actual - target (validated).  
- Reconciliation done monthly during close (T+3).

---

## 15) Outputs
- `core.fact_store_target_monthly`  
- `mart_store_target_monthly`  
- Power BI: “Store Performance vs Target” dashboard (UAE/KSA filters)

---

## 16) Acceptance Examples
- Oct-2025 (Riyadh Gallery):  
  - Target = 500,000 SAR → 489,000 actual → achievement = 97.8%  
  - Variance = -11,000 SAR (-2.2%)  
- Oct-2025 (Dubai Mall):  
  - Target = 450,000 AED → 465,000 actual → achievement = 103.3%, variance = +15,000 AED

---