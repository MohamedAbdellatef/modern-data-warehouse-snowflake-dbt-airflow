# S2T — stg_orders

**Grain:** 1 row = 1 order header.

## Source
- `RAW.OMS_ORDERS_RAW`
  - cols (expected): `SOURCE_SYSTEM, ORDER_NUMBER, STORE_ID, CUSTOMER_ID_NAT, CHANNEL, FINAL_STATUS, ORDER_LOCAL_TS, ORDER_UTC_TS, ORDER_FLAG, INGESTION_DATE`

## Target
- `STG.stg_orders`

| Target Column   | Type          | Source / Rule                          |
| --------------- | ------------- | -------------------------------------- |
| order_number    | VARCHAR       | `ORDER_NUMBER`                         |
| customer_id_nat | VARCHAR       | `CUSTOMER_ID_NAT`                      |
| store_id        | NUMBER        | `STORE_ID`                             |
| channel_code    | VARCHAR       | `upper(trim(CHANNEL))`                 |
| final_status    | VARCHAR       | `upper(trim(FINAL_STATUS))`            |
| order_local_ts  | TIMESTAMP_NTZ | `try_to_timestamp_ntz(ORDER_LOCAL_TS)` |
| order_utc_ts    | TIMESTAMP_NTZ | `try_to_timestamp_ntz(ORDER_UTC_TS)`   |
| order_flag_code | VARCHAR       | `upper(trim(ORDER_FLAG))`              |
| source_system   | VARCHAR       | `SOURCE_SYSTEM`                        |
| load_date       | DATE          | `to_date(INGESTION_DATE)`              |


**Tests**
- `not_null: order_number`
- `accepted_values: final_status in ('COMPLETED','FULFILLED','CANCELLED')` 
