# S2T — stg_stores

**Grain:** 1 row = 1 store.

## Source
- `RAW.POS_STORES_RAW`
  - Expected cols: `store_id, store_code, store_name, city, country, currency_code, timezone, store_type, is_active_flag, ingestion_date, source_system`

## Target
- `STG.stg_stores`

| Target Column | Type | Source/Rule |
|---|---|---|
| store_id       | number      | `store_id` |
| store_code     | varchar     | `upper(trim(store_code))` |
| store_name     | varchar     | `initcap(trim(store_name))` |
| city           | varchar     | `initcap(trim(city))` |
| country_code   | varchar     | `upper(trim(country))` |
| currency_code  | varchar     | `upper(trim(currency_code))` |
| timezone       | varchar     | `trim(timezone)` |
| store_type     | varchar     | `upper(trim(store_type))` |
| is_active_flag | boolean     | `try_to_boolean(is_active_flag)` |
| source_system  | varchar     | `source_system` |
| load_date      | date        | `to_date(ingestion_date)` |

**Tests**
- `not_null: store_id`
- `unique: store_id`
- `accepted_values: currency_code in ('AED','SAR','BHD','KWD','QAR','OMR','USD','EUR')`
