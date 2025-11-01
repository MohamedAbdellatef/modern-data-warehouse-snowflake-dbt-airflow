# S2T — stg_order_items

**Grain:** 1 row = 1 order line.

## Source
- `RAW.OMS_ORDER_ITEMS_RAW`
  - cols: `source_system, order_number, line_number, store_id, sku, quantity, unit_price, discount_amount, gross_amount, vat_amount, net_amount, country, currency_code, category, order_local_ts, order_utc_ts, ingestion_date`

## Target
- `STG.stg_order_items`

| Target Column   | Type          | Source / Rule                          |
| --------------- | ------------- | -------------------------------------- |
| order_number    | varchar       | `order_number`                         |
| line_number     | number        | `line_number`                          |
| store_id        | number        | `store_id`                             |
| sku             | varchar       | `upper(trim(sku))`                     |
| quantity        | number(18,3)  | `quantity`                             |
| unit_price      | number(18,2)  | `unit_price`                           |
| discount_amount | number(18,2)  | `coalesce(discount_amount, 0)`         |
| gross_amount    | number(18,2)  | `gross_amount`                         |
| vat_amount      | number(18,2)  | `vat_amount`                           |
| net_amount      | number(18,2)  | `net_amount`                           |
| currency_code   | varchar       | `upper(trim(currency_code))`           |
| country_code    | varchar       | `upper(trim(country))`                 |
| category        | varchar       | `initcap(trim(category))`              |
| order_local_ts  | timestamp_ntz | `try_to_timestamp_ntz(order_local_ts)` |
| order_utc_ts    | timestamp_ntz | `try_to_timestamp_ntz(order_utc_ts)`   |
| source_system   | varchar       | `upper(trim(source_system))`           |
| load_date       | date          | `to_date(ingestion_date)`              |


**Tests**
- `not_null: (order_number, line_number)`
- `unique_combination: (order_number, line_number)`
