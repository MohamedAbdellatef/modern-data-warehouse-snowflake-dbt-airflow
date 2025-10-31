# S2T — stg_vat_policy

**Grain:** 1 row = 1 VAT class record (latest wins if duplicated).

## Source
- `RAW.GOV_VAT_POLICY_RAW`
  - cols: `vat_class, vat_percent, country_code, source_system, ingestion_date`

## Target
- `STG.stg_vat_policy`

| Target Column | Type | Source/Rule |
|---|---|---|
| vat_class     | varchar      | `upper(trim(vat_class))` |
| vat_percent   | number(5,2)  | `vat_percent` |
| country_code  | varchar      | `upper(trim(country_code))` |
| source_system | varchar      | `source_system` |
| load_date     | date         | `to_date(ingestion_date)` |

**Tests**
- `not_null: vat_class`
- `accepted_values: country_code in ('AE','SA', '...')`
