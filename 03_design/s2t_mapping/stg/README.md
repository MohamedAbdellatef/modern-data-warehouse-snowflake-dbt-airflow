# STG S2T Mappings — GulfMart

**Purpose:** Document how RAW tables in Snowflake are standardized into **STG** models (one row = one source record), with light hygiene only (types, trims, null handling, simple derivations).

**Conventions**
- All STG models live in schema `STG`.
- New audit cols in STG: `load_date` (DATE from RAW.ingestion_date), `source_system` (passed-through).
- No business rules, no dimensional keys here.
- Soft validations captured as dbt tests (not-null / accepted values / unique combos when natural).

**Lineage (RAW → STG)**
- CRM_CUSTOMERS_RAW → stg_customers
- POS_STORES_RAW → stg_stores
- PIM_PRODUCTS_RAW → stg_products
- OMS_ORDERS_RAW → stg_orders
- OMS_ORDER_ITEMS_RAW → stg_order_items
- OMS_RETURNS_RAW → stg_returns
- PSP_PAYMENTS_RAW → stg_payments
- ERP_FX_RATES_DAILY_RAW → stg_fx_rates_daily
- FINANCE_STORE_TARGETS_MONTHLY_RAW → stg_store_targets_monthly
- GOV_VAT_POLICY_RAW → stg_vat_policy
