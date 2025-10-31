# S2T — stg_returns

**Grain:** 1 row = 1 return transaction line.

## Source
- `RAW.OMS_RETURNS_RAW`
  - cols: `return_id, order_number, line_number, store_id, product_id, quantity, amount_native, currency_code, return_ts, reason_code, source_system, ingestion_date`

## Target
- `STG.stg_returns`

| Target Column | Type | Source/Rule |
|---|---|---|
| return_id      | varchar        | `return_id` |
| order_number   | varchar        | `order_number` |
| line_number    | number         | `line_number` |
| store_id       | number         | `store_id` |
| product_id     | number         | `product_id` |
| quantity       | number(18,3)   | `quantity` |
| amount_native  | number(18,2)   | `amount_native` |
| currency_code  | varchar        | `upper(trim(currency_code))` |
| return_ts      | timestamp_ntz  | `try_to_timestamp_ntz(return_ts)` |
| reason_code    | varchar        | `upper(trim(reason_code))` |
| source_system  | varchar        | `source_system` |
| load_date      | date           | `to_date(ingestion_date)` |

**Tests**
- `not_null: return_id`
