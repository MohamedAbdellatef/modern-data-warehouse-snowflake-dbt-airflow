# S2T — stg_vat_policy

**Grain:** 1 row = 1 country policy row (effective date).

## Source
- RAW: `RAW.GOV_VAT_POLICY_RAW`
- Columns: `country, vat_rate, effective_from, source_system`

## Target
- STG: `STG.stg_vat_policy`

| Target Column | Type | Source/Rule |
|---|---|---|
| country_code   | varchar     | `upper(trim(country))` |
| vat_rate       | number(5,2) | `vat_rate` |
| effective_from | date        | `try_to_date(effective_from)` |
| source_system  | varchar     | `source_system` |
| load_date      | date        | `current_date()` |

**Notes**
- Expected values for `country_code`: `UAE`, `KSA`.
