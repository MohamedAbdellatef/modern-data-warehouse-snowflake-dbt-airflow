# GRAIN CARD — `fact_customer_monthly_activity`

## 1) Purpose
Summarizes **customer-level activity per calendar month** for retention and loyalty analytics.  
Powers metrics like *Active Customers (C1)*, *Repeat Rate (C2)*, customer spend, and segmentation (UAE vs KSA, channel, loyalty tier).

---

## 2) Grain (one row = …)
**1 row = one customer × one calendar month (store-local time zone)**

**Fact Type:** Periodic Snapshot (monthly)  
**Refresh Policy:** Incremental rebuild each month (T+1 daily update, freeze T+2)

---

## 3) Upstream Sources (STG)
- `stg_oms_orders` — order header data (status, store, customer, timestamps)
- `stg_oms_order_items` — line-level revenue (net amount, VAT, currency)
- `stg_crm_customers` — loyalty attributes, tier, VIP flag
- `stg_pos_stores` — region and timezone (UAE / KSA)
- `stg_dim_date` — month boundaries for bucketing

---

## 4) Primary / Natural Keys
- **Natural key:** (`customer_id_nat`, `month_key`)
- **Optional surrogate key:** `customer_month_sk = hash(customer_id_nat, month_key)`
- Each customer–month pair appears only once.

---

## 5) Foreign Keys (Dimensions)
| Column | Dimension Table | Notes |
|---------|-----------------|-------|
| `customer_key` | `dim_customer` | SCD2, current attributes for that month |
| `month_key` | `dim_date` | Represents start of calendar month |
| `country_key` | `dim_country` | Derived from latest store country |
| `channel_key` | `dim_channel` | Dominant channel for that month (optional) |

---

## 6) Measures
| Column | Description | Data Type |
|---------|-------------|-----------|
| `is_active_flag` | 1 if ≥1 completed order in month | int |
| `is_repeat_flag` | 1 if any completed order in prior months | int |
| `is_new_flag` | 1 if first-ever order month = this month | int |
| `orders_count_month` | Number of completed orders | int |
| `total_net_amount_native_month` | Net revenue ex-VAT, native currency | numeric(18,2) |
| `total_net_amount_aed_month` | Net revenue in AED (converted via FX) | numeric(18,2) |
| `first_order_month` | First month customer purchased | date |
| `last_order_month` | Most recent order month | date |

---

## 7) Attributes (non-measure)
- `customer_id_nat`
- `loyalty_tier`, `is_vip_flag` (from CRM)
- `country_code`, `currency_code`
- `active_segment` (NEW / REPEAT / INACTIVE)
- `data_load_date`

---

## 8) Time Columns
- `month_start_date` — first day of month (from `dim_date`)
- `month_end_date` — last day of month
- `ingestion_date` — pipeline watermark (used for incremental load)

---

## 9) Inclusion / Exclusion Logic
**Include:**
- Orders with `final_status ∈ ('COMPLETED','FULFILLED')`

**Exclude:**
- Orders flagged `TEST`, `INTERNAL`, `FRAUD`
- Orders with `customer_id_nat` = NULL (optional per design)

**Special:**
- Refund-only months are not counted as active unless paired with a new completed order.

---

## 10) Regional / Business Rules
- **VAT:** Excluded (use `net_amount` from `fact_order_line`)
- **FX:** Convert native → AED using same policy as Order to Cash (`daily rate @ order_date`, frozen after T+2)
- **Guests:** May be excluded or mapped to `dim_customer.UNKNOWN`
- **Timezone:** Bucket orders by **store local timezone** (Asia/Dubai or Asia/Riyadh)

---

## 11) Incremental Strategy
- Watermark: `ingestion_date`  
- Recompute daily for latest month (`T+1` loads)  
- Late arrivals accepted until `T+2`, then freeze the month  
- Rebuild only current and prior month to handle late orders

---

## 12) Data Quality Tests — Design Phase

### Uniqueness
- (`customer_id_nat`, `month_key`) must be unique

### Relationships
- All foreign keys must exist in conformed dimensions

### Logic Integrity
- If `is_active_flag=0` ⇒ `orders_count_month=0` and all revenue fields = 0  
- If `is_repeat_flag=1` ⇒ `first_order_month < current_month`  
- `repeat_count ≤ active_count`

### Accepted Values
- `currency_code ∈ {AED, SAR}`
- `country ∈ {UAE, KSA}`

### Arithmetic Checks
- Σ(`total_net_amount_aed_month`) across customers = Σ(`fact_order_line.net_amount_aed`) per month

---

## 13) Performance Notes
- Cluster by `month_key`
- Optional Z-order on `country_key` for regional rollups
- Partition retention: keep 24 months rolling window

---

## 14) Output Object
- `core.fact_customer_monthly_activity` (incremental dbt model)  
- Consumed by: `mart_customer_activity_monthly`

---

## 15) Acceptance Examples
- Oct-2025 UAE:  
  - Active customers = **12,430**, Repeat = **7,900**, Repeat rate = **63.5%**  
  - New customers = **4,530**, Total spend = **5.8 M AED**
- Example record:  
  `customer_id_nat = 100512`, `month_key = 202510`, `is_active_flag=1`, `is_repeat_flag=1`, `orders_count_month=3`, `total_net_amount_aed_month=540.00`

---