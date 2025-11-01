# S2T — stg_returns

**Grain:** 1 row = 1 return record (order × sku × event).

## Source
- RAW: `RAW.OMS_RETURNS_RAW`
- Expected columns: `source_system, return_id, order_number, store_id, sku, quantity_returned, refund_amount_native, currency_code, return_status, return_reason_code, return_local_ts, return_utc_ts, ingestion_date`

## Target
- STG: `STG.stg_returns`

| Target Column        | Type          | Source/Rule                          |
|----------------------|---------------|--------------------------------------|
| return_id            | varchar       | `return_id`                          |
| order_number         | varchar       | `order_number`                       |
| store_id             | number        | `store_id`                           |
| sku                  | varchar       | `upper(trim(sku))`                   |
| quantity_returned    | number(18,3)  | `quantity_returned`                  |
| refund_amount_native | number(18,2)  | `coalesce(refund_amount_native, 0)`  |
| currency_code        | varchar       | `upper(trim(currency_code))`         |
| return_status        | varchar       | `upper(trim(return_status))`         |
| return_reason_code   | varchar       | `upper(trim(return_reason_code))`    |
| return_local_ts      | timestamp_ntz | `try_to_timestamp_ntz(return_local_ts)` |
| return_utc_ts        | timestamp_ntz | `try_to_timestamp_ntz(return_utc_ts)`   |
| source_system        | varchar       | `source_system`                      |
| load_date            | date          | `to_date(ingestion_date)`            |

**Notes**
- Enforce non-negative `quantity_returned` and `refund_amount_native`.
- Relationships to `stg_orders` (order_number), `stg_stores` (store_id), `stg_products` (sku).
