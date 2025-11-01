# S2T — stg_fx_rates_daily

**Grain:** 1 row = 1 FROM currency → AED rate per fx_date.

## Source
- `RAW.ERP_FX_RATES_DAILY_RAW`
  - cols: `FX_DATE, FROM_CCY, TO_CCY, RATE_TO_AED, SOURCE_SYSTEM, INGESTION_DATE`

## Target
- `STG.stg_fx_rates_daily`

| Target Column          | Type         | Source / Rule                      |
| ---------------------- | ------------ | ---------------------------------- |
| fx_date                | DATE         | `try_to_date(FX_DATE)`             |
| currency_code          | VARCHAR(3)   | `upper(trim(FROM_CCY))`            |
| conversion_rate_to_aed | NUMBER(18,6) | `try_to_decimal(RATE_TO_AED,18,6)` |
| source_system          | VARCHAR      | `SOURCE_SYSTEM`                    |
| load_date              | DATE         | `to_date(INGESTION_DATE)`          |


**Tests**
- `not_null: (fx_date, currency_code)`
- `unique_combination: (fx_date, currency_code)`
