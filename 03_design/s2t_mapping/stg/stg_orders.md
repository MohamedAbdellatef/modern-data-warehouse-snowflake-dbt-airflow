# S2T — stg_orders

**Grain:** 1 row = 1 order header.

## Source
- `RAW.OMS_ORDERS_RAW`
  - cols (expected): `order_number, customer_id_nat, store_id, channel_code, currency_code, order_local_ts, order_utc_ts, final_status, order_item_count, order_gross_amount_native, order_vat_amount_native, order_net_amount_native, is_valid_sales_flag, source_system, ingestion_date`

## Target
- `STG.stg_orders`

| Target Column              | Type           | Source/Rule |
|---|---|---|
| order_number               | varchar        | `order_number` |
| customer_id_nat           | varchar        | `customer_id_nat` |
| store_id                   | number         | `store_id` |
| channel_code               | varchar        | `upper(trim(channel_code))` |
| currency_code              | varchar        | `upper(trim(currency_code))` |
| order_local_ts             | timestamp_ntz  | `try_to_timestamp_ntz(order_local_ts)` |
| order_utc_ts               | timestamp_ntz  | `try_to_timestamp_ntz(order_utc_ts)` |
| final_status               | varchar        | `upper(trim(final_status))` |
| order_item_count           | number         | `order_item_count` |
| order_gross_amount_native  | number(18,2)   | `order_gross_amount_native` |
| order_vat_amount_native    | number(18,2)   | `order_vat_amount_native` |
| order_net_amount_native    | number(18,2)   | `order_net_amount_native` |
| is_valid_sales_flag        | boolean        | `try_to_boolean(is_valid_sales_flag)` |
| source_system              | varchar        | `source_system` |
| load_date                  | date           | `to_date(ingestion_date)` |

**Tests**
- `not_null: order_number`
- `accepted_values: final_status in ('PLACED','PAID','CANCELLED','RETURNED','FULFILLED')` (adapt)
