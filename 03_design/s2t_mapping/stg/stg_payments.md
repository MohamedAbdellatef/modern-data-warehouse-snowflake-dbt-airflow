# S2T — stg_payments

**Grain:** 1 row = 1 payment record.

## Source
- `RAW.PSP_PAYMENTS_RAW`
  - cols: `payment_id, order_number, payment_method, payment_type, provider_name, payment_status, amount_native, currency_code, paid_ts, source_system, ingestion_date`

## Target
- `STG.stg_payments`

| Target Column  | Type | Source/Rule |
|---|---|---|
| payment_id      | varchar        | `payment_id` |
| order_number    | varchar        | `order_number` |
| payment_method  | varchar        | `upper(trim(payment_method))` |
| payment_type    | varchar        | `upper(trim(payment_type))` |
| provider_name   | varchar        | `initcap(trim(provider_name))` |
| payment_status  | varchar        | `upper(trim(payment_status))` |
| amount_native   | number(18,2)   | `amount_native` |
| currency_code   | varchar        | `upper(trim(currency_code))` |
| paid_ts         | timestamp_ntz  | `try_to_timestamp_ntz(paid_ts)` |
| source_system   | varchar        | `source_system` |
| load_date       | date           | `to_date(ingestion_date)` |

**Tests**
- `not_null: payment_id`
- `accepted_values: payment_status in ('AUTHORIZED','CAPTURED','REFUNDED','VOID','FAILED')`
