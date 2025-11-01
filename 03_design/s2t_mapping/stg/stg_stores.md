# S2T — stg_stores

**Grain:** 1 row = 1 store.

## Source
- RAW table: `RAW.POS_STORES_RAW`
- Columns: `store_id, store_code, store_name, city, country, currency_code, timezone, store_type, open_date, source_system`

## Target
- STG model: `STG.stg_stores`

| Target Column | Type | Source/Rule |
|---|---|---|
| store_id      | number       | `store_id` |
| store_code    | varchar      | `upper(trim(store_code))` |
| store_name    | varchar      | `initcap(trim(store_name))` |
| city          | varchar      | `initcap(trim(city))` |
| country_code  | varchar      | `upper(trim(country))` |
| currency_code | varchar      | `upper(trim(currency_code))` |
| timezone      | varchar      | `trim(timezone)` |
| store_type    | varchar      | `upper(trim(store_type))` |
| open_date     | date         | `try_to_date(open_date)` |
| source_system | varchar      | `source_system` |
| load_date     | date         | `current_date()` (no `ingestion_date` in source) |

**Notes**
- Uniqueness expected on `store_id` and `store_code`.
