# PROCESS: Orders / Sales

**Purpose & Owner**: Ops + Finance reporting (orders, revenue ex-VAT, AOV, channel mix, active/repeat).

**Event & Final Statuses**: Order lifecycle; **final** = {'Completed','Fulfilled'}.

**Sources & Cadence**:
- OMS: `oms_orders.csv`, `oms_order_items.csv` (daily CSV → ADLS)

**Fact candidates**
- `fact_order_line` — **1 row = one order line at `order_local_ts`** · **Type:** Transactional

**Measures**
- quantity
- gross_amount
- vat_amount
- **net_amount = gross_amount − vat_amount** (line-level, 2dp)

**Keys**
- PK: `(order_number, line_number)`
- Degenerate: `order_number`

**Conformed Dimensions**
- `dim_date` (role: order_date)
- `dim_store` (SCD2: country, currency, timezone)
- `dim_product` (SCD2)
- `dim_customer` (SCD2 after identity resolution)
- `dim_channel`, `dim_currency`, `dim_order_status`

**Time Behaviour**
- Keep `order_utc_ts`; derive `order_local_ts` using store tz
- Bucket month by **store local**; late arriving allowed until **T+2**

**Policies**
- VAT 5% UAE / 15% KSA, zero-rated via product class
- FX to AED at **order_date**; freeze at **T+2**
- Online → ONLINE_UAE / ONLINE_KSA virtual stores

**Data Quality**
- Unique `(order_number, line_number)`
- FK to dims present
- Status vocabulary within allowed list
- `SUM(gross) − SUM(net) ≈ SUM(vat)` within tolerance

**QNFs & Marts**
- R1 → `mart_sales_monthly_by_store`
- R2 → `mart_revenue_country_monthly`
- R4 → `mart_aov_monthly`
- R6 → `mart_channel_mix_monthly`
- C1 → `mart_active_customers_monthly`
- C2 → `mart_repeat_rate_monthly`
