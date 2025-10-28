# Physical Model Notes — Snowflake CORE Layer
GulfMart Retail Data Warehouse

## 1. Warehouse Layering Strategy

### RAW
- Landing layer.
- External tables or COPY INTO from data lake (ADLS).
- Schema is 1:1 with source (OMS, POS, PSP, PIM, CRM, ERP).
- Data is not cleaned, types may still be strings, duplicates may exist.

### STG
- Staging / cleaning layer.
- We apply:
  - type casting (string → NUMBER, TIMESTAMP_LTZ, etc.)
  - trimming / uppercasing codes
  - deduplication using `ingestion_date`
  - status normalization (map statuses like `FULFILLED`, `COMPLETED`, etc.)
- Late-arriving logic is handled here.

### CORE
- Conformed business layer.
- This is where we create:
  - `dim_*` conformed dimensions (SCD-aware)
  - `fact_*` fact tables with business grain
- CORE is what analytics and marts depend on.
- All tables in the physical_model.png live in CORE.

### MARTS
- Presentation/business view layer.
- We build semantic tables / BI models for dashboards and Power BI.
- Facts are often aggregated to month/store/country and exposed with friendly column names.

---

## 2. Fact Tables (Grain, Load Strategy, Purpose)

### `fact_order_line`
- **Grain:** 1 row per `(order_number × line_number)`
- **Purpose:** Transactional sales at item level. Supports net revenue ex-VAT, VAT audit, discounts, product/category splits.
- **Loaded:** Incremental append.
- **Late-arrival policy:** We accept new or corrected records up to T+2 days after the business day.
- **Filters applied:** We exclude cancelled / test / fraud:
  - Only orders where `final_status IN ('COMPLETED','FULFILLED')`
  - Exclude rows where `order_flag IN ('TEST','INTERNAL','FRAUD')`
- **Core measures:**
  - `quantity`
  - `gross_amount`
  - `vat_amount`
  - `net_amount`
  - `discount_amount`
- **Keys to dimensions:**
  - `customer_key`, `product_key`, `store_key`, `channel_key`, `currency_key`, `order_date_key`

This table powers:
- R1: orders per store per month
- R2: net revenue ex-VAT per country/month
- R4: AOV (combined later in fact_order)
- R6: channel mix (Online vs In-Store)

---

### `fact_order`
- **Grain:** 1 row per `order_number`
- **Purpose:** Order header rollup. Used to report payment method, AOV, order counts, channel mix.
- **Built from:** Aggregating `fact_order_line`.
- **Loaded:** Incremental upsert (merge by `order_number`).
- **Important columns:**
  - `order_item_count`
  - `order_gross_amount_native`, `order_net_amount_native`, `order_net_amount_aed`
  - `payment_key`
  - `channel_key`
  - `is_valid_sales_flag`
  - `order_local_ts` (store timezone), `order_utc_ts` (audit)
- **Keys to dimensions:**
  - `customer_key`, `store_key`, `channel_key`, `payment_key`, `currency_key`, `order_date_key`

This table powers:
- R3: payment method mix per month
- R4: AOV per store / city / country
- R6: % Online vs In-Store
- Fraud / QA views from `is_valid_sales_flag`

---

### `fact_customer_monthly_activity`
- **Grain:** 1 row per `(customer_key × store_key × month_key)`
- **Purpose:** Monthly behavior per customer. Used for retention, repeat rate, active customer KPIs.
- **Loaded:** Monthly snapshot after month close (full refresh of that month).
- **Measures / flags:**
  - `orders_count`
  - `total_net_amount_aed`
  - `is_repeat_customer_flag` (1 if they purchased any time before this month)
  - `is_active_customer_flag` (1 if they bought this month)
  - `unique_order_days` (engagement intensity)
  - `first_purchase_month_key`
- **Keys to dimensions:**
  - `customer_key`, `store_key`, `channel_key`, `currency_key`, `month_key`

This table powers:
- C1: active customers per month
- C2: repeat vs new customer %
- CRM / loyalty segmentation

---

### `fact_store_target_monthly`
- **Grain:** 1 row per `(store_key × month_key)`
- **Purpose:** Finance view of “Target vs Actual” by store.
- **Loaded:** Monthly snapshot.
- **Measures:**
  - `target_amount_aed`
  - `actual_net_amount_aed`
  - `variance_amount_aed = actual - target`
  - `variance_pct = (actual / target) - 1`
  - `achieved_flag` (1 if store met or beat target)
- **Keys to dimensions:**
  - `store_key`, `month_key`, `currency_key`

This table powers:
- S1: % of target achieved by store
- S2: variance in AED and %

---

## 3. Conformed Dimensions

These dimensions are shared across multiple fact tables so KPIs align between Finance, Operations, and CRM. This is why the physical model diagram has “spider” relationships; that’s expected.

### `dim_store`
- SCD Type: 2
- Tracks `store_name`, `city`, `country`, `currency_code`, `timezone`, `store_type` (PHYSICAL vs ONLINE_UAE / ONLINE_KSA).
- Used by *all* fact tables.
- Enables slice by region, segment (online vs physical), etc.

### `dim_customer`
- SCD Type: 2
- Loyalty and profile over time: `loyalty_tier`, `is_vip_flag`, `registration_ts`, `first_purchase_ts`, `city`, `country_code`.
- Used by:
  - `fact_order_line`
  - `fact_order`
  - `fact_customer_monthly_activity`

### `dim_product`
- SCD Type: 2
- From PIM, includes `sku`, `product_name`, `category`, `brand`, `vat_class`.
- Only joins to `fact_order_line` (line grain is where product lives).

### `dim_channel`
- SCD Type: 1
- Small lookup: `channel_code` (POS/WEB/MARKETPLACE), `channel_name`, and `is_digital_flag` (1 = online).
- Used to answer “Online vs In-Store %” and splits dashboards.
- Used in most fact tables.

### `dim_currency`
- SCD Type: 2 by `effective_date`
- Includes `currency_code`, `country_code`, and `conversion_rate_to_aed`.
- Used by all revenue-related facts so we can report:
  - native currency (AED vs SAR)
  - and unified AED
- This is how we satisfy:  
  “total net revenue excluding VAT per country per calendar month”  
  and  
  “AOV in native and AED.”

### `dim_date`
- Static calendar table (not SCD).
- Contains `date_key` (yyyymmdd), `full_date`, `month`, `quarter`, `year`, `is_weekend`, `month_start_date`, `month_end_date`.
- Every fact has date or month FK:  
  - transactional facts link at day grain  
  - monthly snapshot facts link using the 1st of month.

### `dim_payment`
- SCD Type: 1
- Contains `payment_method`, `payment_type`, `provider_name`, `payment_status`.
- Joins **only** to `fact_order` because payment is at order header.


---

## 4. Business Rules / Data Quality

### Status filtering
- Only include orders with final status in (“COMPLETED”, “FULFILLED”).
- Exclude:
  - CANCELLED
  - internal test orders (`order_flag IN ('TEST','INTERNAL','FRAUD')`)

### VAT
- VAT is tracked per line in `fact_order_line`:
  - `gross_amount` (pre-VAT)
  - `vat_amount`
  - `net_amount` (gross - vat)
- Finance can validate that:  
  `Σgross_amount ≈ Σnet_amount + Σvat_amount` by store, month, country.

### FX / AED conversion
- `fact_order` and `fact_store_target_monthly` use AED for executive reporting.
- Currency conversion uses `dim_currency.conversion_rate_to_aed` at order date.
- Snapshot freeze (T+2) ensures Finance and Ops are aligned on totals.

### Timezone
- We store:
  - `order_local_ts` (store timezone, business-view of “when did we sell”)
  - `order_utc_ts` (audit trace)
- Month cutoffs use store **local time** by country / timezone — not UTC.

---

## 5. Why the physical model diagram looks busy (and that’s OK)

- We use **conformed dimensions**: `dim_store`, `dim_channel`, `dim_currency`, `dim_date`, etc.
- Those dimensions are reused by multiple facts.
- That is *good design* because KPIs match across Finance, Operations, CRM.
- The side effect: visually, each dimension fans out into multiple fact tables. So the final physical model diagram will always have many lines. That is expected in a mature warehouse.

---

## 6. How this feeds BI / Reporting

From these CORE tables we can derive marts such as:
- Monthly Orders by Store
- Revenue by Country in AED
- AOV per Channel
- Repeat vs New Customer %
- Store Target vs Actual with Variance %

These marts are exposed to:
- Finance dashboards
- Operations dashboards
- CRM/Loyalty dashboards
- Ad-hoc SQL consumers

---

## 7. Summary

- The Snowflake CORE layer is fully modeled.  
- All fact grains are explicitly defined and tied to business questions (QNFs).  
- All conformed dimensions are defined and SCD policy is known.  
- FX, VAT, and timezone rules are embedded in the design.  
- Load strategy is clear: incremental facts, monthly snapshots, SCD2 dims.

This is production-style warehouse documentation.
