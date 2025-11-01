# S2T — stg_payments

**Grain:** 1 row = 1 payment record.

## Source
- RAW: `RAW.PSP_PAYMENTS_RAW`
- Columns: `source_system, payment_id, order_number, store_id, payment_type, payment_status, payment_method, amount_native, fee_native, currency_code, payment_local_ts, payment_utc_ts, ingestion_date`

## Target
- STG: `STG.stg_payments`

| Target Column   | Type | Source/Rule |
|---|---|---|
| payment_id      | varchar        | `payment_id` |
| order_number    | varchar        | `order_number` |
| store_id        | number         | `store_id` |
| payment_type    | varchar        | `upper(trim(payment_type))` |
| payment_status  | varchar        | `upper(trim(payment_status))` |
| payment_method  | varchar        | `upper(trim(payment_method))` |
| amount_native   | number(18,2)   | `amount_native` |
| fee_native      | number(18,2)   | `coalesce(fee_native,0)` |
| currency_code   | varchar        | `upper(trim(currency_code))` |
| payment_local_ts| timestamp_ntz  | `try_to_timestamp_ntz(payment_local_ts)` |
| payment_utc_ts  | timestamp_ntz  | `try_to_timestamp_ntz(payment_utc_ts)` |
| source_system   | varchar        | `source_system` |
| load_date       | date           | `to_date(ingestion_date)` |

**Notes**
- Enforce non-negative `amount_native` and `fee_native`.
- Later in CORE, filter only **Completed Captures** when tying to completed/fulfilled orders.


**Tests**
- `not_null: payment_id`
- `accepted_values: payment_status in ('AUTHORIZED','CAPTURED','REFUNDED','VOID','FAILED')`
