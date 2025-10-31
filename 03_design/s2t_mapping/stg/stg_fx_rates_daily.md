# S2T — stg_fx_rates_daily

**Grain:** 1 row = 1 currency rate per date.

## Source
- `RAW.ERP_FX_RATES_DAILY_RAW`
  - cols: `fx_date, currency_code, conversion_rate_to_aed, source_system, ingestion_date`

## Target
- `STG.stg_fx_rates_daily`

| Target Column           | Type | Source/Rule |
|---|---|---|
| fx_date                 | date         | `try_to_date(fx_date)` |
| currency_code           | varchar      | `upper(trim(currency_code))` |
| conversion_rate_to_aed  | number(18,6) | `conversion_rate_to_aed` |
| source_system           | varchar      | `source_system` |
| load_date               | date         | `to_date(ingestion_date)` |

**Tests**
- `not_null: (fx_date, currency_code)`
- `unique_combination: (fx_date, currency_code)`
