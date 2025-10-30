# Process: Order to Cash (Sales / Orders)

## 1) Purpose & Stakeholders
**Purpose.** Provide a trusted foundation for order-driven KPIs across UAE/KSA: order counts per store / per channel, net revenue ex-VAT, AOV, channel mix, refunds, and payment mix.  
**Stakeholders.** Operations, Finance, BI (Power BI).  
**SLA.** Daily freshness **T+1 by 06:00 Asia/Riyadh**, month closes **T+2**.

---

## 2) Business Scope & Event Lifecycle
Covers the life of a customer order **through fulfillment**.  
Payment method and refunds are modeled here (Order-to-Cash scope); physical return reasons are handled in a separate **Returns** process.

**Lifecycle:** `Created → (Paid via PSP) → Fulfilled/Completed → (optional Return/Refund) → Closed`  
**Include:** `COMPLETED`, `FULFILLED`  
**Exclude:** `CANCELLED` and orders flagged `TEST`, `INTERNAL`, `FRAUD`.  
All downstream revenue and AOV reporting use only included statuses.

---

## 3) Source Systems & Cadence
**OMS:** `oms_orders`, `oms_order_items` (daily; keep `order_local_ts`, `order_utc_ts`, `ingestion_date`)  
**PSP:** `psp_payments` (daily; for payment method / capture status validation)  
**Reference:**  
- `pos_stores` (country, currency, timezone, ONLINE_*),  
- `pim_products` (category, brand, vat_class),  
- `crm_customers` (customer_id_nat, loyalty_tier).  

**Incremental watermark:** `ingestion_date` (late arrivals allowed until **T+2**).

---

## 4) Facts & Grain
- **Canonical:** `core.fact_order_line` — **1 row = order_number × line_number** (transactional fact).  
- **Derived:** `core.fact_order` — **1 row = completed order_number** (aggregated from `fact_order_line` + header).

Why line grain? VAT, discount, and category exist at line level; we can safely roll up to order.

---

## 5) Measures & Formulas (line level)
**Definitions (for this model):**
- `unit_price` – base price per unit (pre-discount, pre-VAT)  
- `discount_amount` – per line, pre-VAT  
- `gross_amount = (unit_price × quantity) − discount_amount` (pre-VAT)  
- `vat_amount` – VAT charged on this line  
- **`net_amount = gross_amount − vat_amount`** (ex-VAT revenue)  
- `net_amount_aed = net_amount × FX(order_local_date, currency_code → AED)`

Order totals in `fact_order`: `order_gross_native`, `order_vat_native`, **`order_net_native`** = Σ line measures.

---

## 6) Keys
- **Natural key (line):** `(order_number, line_number)`  
- **Degenerate dim:** `order_number`  
- **Business FKs:** `store_id`, `sku`, `customer_id_nat`, `channel`, `currency_code` → resolved to dimension SKs in CORE.

---

## 7) Conformed Dimensions
`dim_date (role: order_date)`, `dim_store` (SCD2; country, currency, timezone, store_type incl. ONLINE_*),  
`dim_product` (SCD2; category, brand, vat_class), `dim_customer` (SCD2), `dim_channel`, `dim_currency`.

---

## 8) Time Behavior & Timezones
- Keep both `order_utc_ts` (audit) and `order_local_ts` (business).  
- Bucket by **store local time**; month boundary = **00:00 local on 1st**.  
- **Incremental lookback:** 7 days on `order_local_ts`; freeze after **T+2**.  
All “per calendar month” metrics use store-local time bucketing.

---

## 9) Regional Policies (VAT / FX / Online Stores)
- **VAT:** UAE 5 %, KSA 15 %; ZERO-rated per `product.vat_class`.  
- **FX:** convert to AED using daily rate at `order_local_date`; FX frozen at **T+2**.  
- **Online mapping:** Web/App/Marketplace orders use virtual stores `ONLINE_UAE` / `ONLINE_KSA` (inherit country/currency/timezone).  
- **Rounding:** compute at line precision; round line to 2 dp, then aggregate.  
All consolidated regional reporting is in AED.

---

## 10) Data Quality Rules (dbt tests)
- **Uniqueness:** `(order_number, line_number)` unique.  
- **Relationships:** lines → orders, lines → stores, lines → products, lines → customers.  
- **Accepted values:**  
  - `channel ∈ {POS, WEB, MARKETPLACE}` (STG normalizes)  
  - `final_status ∈ {COMPLETED, FULFILLED, CANCELLED}` (only included statuses propagate to CORE)  
  - `currency_code ∈ {AED, SAR}`  
- **Arithmetic identity:** `|Σ(gross) − Σ(net) − Σ(vat)| <= 0.01 × row_count` (tolerance).  
- **No negative quantities; unit_price >= 0.**  
- **Cross-process invariant (Payments):** Every Completed/Fulfilled order must have ≥ 1 Completed Capture in `psp_payments`.  
- **FX integrity:** Each `currency_code` must have a valid FX rate for the `order_date_key` at T+2.

---

## 11) Transform Steps (RAW → STG → CORE)
**RAW → STG**  
- Cast types; trim / UPPER codes; normalize `channel` and `status` to standard sets.  
- Deduplicate by `(order_number, line_number)` keeping latest by `ingestion_date`.  
- Derive `order_date_key = to_date(order_local_ts)`.

**STG → CORE**  
- Build `core.fact_order_line` from `stg_oms_order_items` + header attrs from `stg_oms_orders`; resolve FKs to `dim_store`, `dim_product`, `dim_customer`, `dim_date`.  
- Build `core.fact_order` as Σ of line measures joined to header (store / channel / customer).  
- Replace business FKs with dimension surrogate keys.

---

## 12) QNFs Served & Marts
- **R1** Monthly Orders by Store → `mart_sales_monthly_by_store` (from `fact_order`)  
- **R2** Net Revenue ex-VAT by Country → `mart_revenue_country_monthly` (from lines + FX)  
- **R3** Orders by Payment Method → `mart_payment_mix_monthly` (join Payments data)  
- **R4** AOV → `mart_aov_monthly` (Σ order_net_AED / COUNT orders)  
- **R5** Refund Amount & Rate → `mart_refund_rate_monthly` (from refund lines)  
- **R6** Channel Mix → `mart_channel_mix_monthly`

---

## 13) Edge Cases
- Exclude `CANCELLED` and flags `TEST / INTERNAL / FRAUD`.  
- Partial shipments: include only if `final_status ∈ (COMPLETED, FULFILLED)`.  
- Guest orders: map to `dim_customer.UNKNOWN`; track % as DQ metric.

---

## 14) Reconciliation & Controls
- **Order totals = Σ line totals** (per order & month).  
- **VAT triangle:** `Σgross − Σnet ≈ Σvat` per month & store/country.  
- **FX check:** Σ `order_net_amount_aed` should ≈ Σ `order_net_native × FX`.  
- **Late arrival alert:** rows after T+2 flagged and quarantined.  
- **Finance reconciliation:** Monthly AED totals in `fact_order` must match Finance books post T+2 close.

---

## 15) Outputs
- `core.fact_order_line` (canonical)  
- `core.fact_order` (derived)  
- Marts: `mart_sales_monthly_by_store`, `mart_revenue_country_monthly`, `mart_payment_mix_monthly`, `mart_aov_monthly`, `mart_refund_rate_monthly`, `mart_channel_mix_monthly`  
- Power BI dataset: **Operations & Finance Dashboard**

---

## 16) Acceptance Examples
- **R1:** Oct-2025, Riyadh Gallery = **205 completed orders**  
- **R2:** UAE 1,050,000 gross → **1,000,000 AED net** (5 %)  
       KSA 1,150,000 gross → **1,000,000 SAR net** (15 %)  
       AED-consolidated ≈ **1.98 M AED**  
- **AOV:** two orders 100 & 200 AED → **150 AED**  

---