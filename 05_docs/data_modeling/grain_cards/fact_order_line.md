#  GRAIN CARD — `core_fact_order_line`

## 1) Purpose (what this table is for)

Canonical transactional fact for the **Order to Cash** process at the item level.

This table represents revenue per sold line item and powers:
- Revenue ex-VAT (native currency)
- Product / category / brand performance
- Store / channel mix of sales
- Rollup to order-level metrics (AOV, total revenue per order) via aggregation
- Refund / fraud monitoring inputs

This is the atomic “truth” of sales. All higher-level tables (like `fact_order`) are derived from this.
---

## 2) Grain (one row = …)

**1 row = one order *line* at `order_local_ts`** 
i.e. 1 row per `order_number × line_number` for a completed/fulfilled order.

**Fact type:** Transactional fact (event-level).

Each row is a specific SKU sold in a specific order.

---

## 3) Upstream sources (STG)

- `stg_oms_order_items`  
  - line amounts, SKU, quantity, VAT amounts, currency, line timestamps
- `stg_oms_orders`  
  - order header (final_status, channel, customer, store_id, flags)
- Reference dims:  
  - `stg_pos_stores` (country, timezone, currency, ONLINE_* virtual stores)  
  - `stg_pim_products` (category, brand, vat_class)  
  - `stg_crm_customers` (customer_id_nat, loyalty_tier)  
  - `stg_dim_date` (calendar surrogate keys)

---

## 4) Primary / Natural keys
- **Natural PK:** `(order_number, line_number)`
- **Degenerate dimension key:** `order_number` (kept as-is for drill/reconciliation)
- **Warehouse surrogate key (optional):**  
  `order_line_sk = hash(order_number, line_number)` for clustering / joins

---

## 5) Foreign keys (conformed dimensions)

| Column           | Dimension Table             | Notes                                    |
| ---------------- | --------------------------- | ---------------------------------------- |
| `order_date_key` | `dim_date.date_key`         | Based on `order_local_ts`                |
| `store_key`      | `dim_store.store_key`       | From `store_id`, SCD2                    |
| `product_key`    | `dim_product.product_key`   | From `sku`, SCD2                         |
| `customer_key`   | `dim_customer.customer_key` | Nullable; fallback to UNKNOWN for guests |
| `channel_key`    | `dim_channel.channel_key`   | From normalized `channel`                |
| `currency_key`   | `dim_currency.currency_key` | From `currency_code`                     |

---

## 6) Measures (facts)

All measures stored in **native transaction currency** (AED, SAR, etc.) unless stated.

**numeric(18,2)** unless otherwise stated:

- `quantity` *(int)*  
- `unit_price` — unit list/charged price pre-discount, pre-VAT  
- `discount_amount` — discount applied to this line, pre-VAT  
- `gross_amount` — `(unit_price * quantity) - discount_amount`, still pre-VAT  
- `vat_amount` — VAT charged on this line  
- `net_amount` — `gross_amount - vat_amount`  
  - This is the revenue ex-VAT that Finance and Ops use
- `unit_net` — `net_amount / NULLIF(quantity,0)` *(Numeric(18,4))*  

👉 Note: `net_amount_aed` can be derived downstream using FX for the order’s business date. We do not have to persist it here at the line level if we want to keep this table currency-native.

---

## 7) Attributes (non-measure)

* `order_number`
* `line_number`
* `sku`, `store_id`, `customer_id_nat`, `channel`, `currency_code`, `country`
* `final_status`
* `order_flag` (e.g. TEST, INTERNAL, FRAUD)
* `vat_class` (for zero-rated logic)
---

## 8) Time columns

* `order_local_ts` — business bucketing by **store timezone**
* `order_utc_ts` — audit field
* `ingestion_date` — for **incremental loads**, accepts late data until **T+2**

---

## 9) Inclusion / Exclusion logic

* **Include** only if `final_status ∈ ('COMPLETED','FULFILLED')`
* **Exclude** if `final_status='CANCELLED'` or `order_flag ∈ ('TEST','INTERNAL','FRAUD')`

---

## 10) Regional policies (VAT / FX / Online)

* **VAT:** UAE 5%, KSA 15%, ZERO-rated by `vat_class`
* **FX:** daily AED conversion based on `order_local_ts`; frozen after **T+2**
* **Online orders:** assigned to virtual stores `ONLINE_UAE`, `ONLINE_KSA` with local settings

---

## 11) Incremental strategy

* Source files are append-only with `ingestion_date` watermark
* Allow late-arriving orders up to **T+2**
* Loads after that are idempotent unless reprocessed for month-end adjustment

---

## 12) Data Quality Tests — Design Phase

### Uniqueness

* `(order_number, line_number)` must be unique

### Foreign Key Relationships

* `store_key` must exist in `dim_store`
* `product_key` must exist in `dim_product`
* `customer_key` must exist in `dim_customer` *(can be UNKNOWN for guests)*
* `channel_key` must exist in `dim_channel`
* `currency_key` must exist in `dim_currency`
* `order_date_key` must exist in `dim_date`

### Not Null Constraints

* Required: `order_number`, `line_number`, `store_key`, `product_key`, `order_date_key`
* Optional (nullable): `customer_key`

### Accepted Values

* `channel ∈ {POS, WEB, MARKETPLACE}`
* `final_status ∈ {COMPLETED, FULFILLED, CANCELLED}`
* `currency_code ∈ {AED, SAR}`

###  Arithmetic Consistency

* `gross_amount ≈ net_amount + vat_amount`

  * Allow small rounding tolerance at line or aggregated level

###  Business Logic Checks

* `quantity >= 0`
* `unit_price >= 0`
* `net_amount >= 0`
* `discount_amount ≤ (unit_price × quantity)`

---

## 13) Performance notes

* Consider cluster/sort by `order_date_key`, `store_key` for partitioning
* Do not precompute FX; apply in views or marts if needed

---

## 14) Output object

* `core.fact_order_line` (incremental table, loaded by dbt)
* Derived: `core.fact_order` (order-level rollup used in marts like AOV, R1)

---

## 15) Acceptance examples

* Store “Riyadh Gallery” shows 205 completed orders in Oct-2025
* VAT test: sum(gross) ≈ sum(net) + sum(vat) per store-month
* Zero-rated products yield `vat_amount = 0`, `net = gross`

---