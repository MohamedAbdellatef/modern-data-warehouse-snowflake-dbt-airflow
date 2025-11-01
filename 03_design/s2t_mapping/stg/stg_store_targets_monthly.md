# S2T — stg_store_targets_monthly

**Grain:** 1 row = 1 store × month target.

## Source
- RAW: `RAW.FINANCE_STORE_TARGETS_MONTHLY_RAW`
- Columns: `source_system, store_id, target_month (YYYY-MM-01), target_amount_AED`

## Target
- STG: `STG.stg_store_targets_monthly`

| Target Column     | Type | Source/Rule |
|---|---|---|
| store_id          | number       | `store_id` |
| target_month      | date         | `try_to_date(target_month)` |
| target_amount_aed | number(18,2) | `target_amount_AED` |
| source_system     | varchar      | `source_system` |
| load_date         | date         | `current_date()` |

**Notes**
- Expect unique combo `(store_id, target_month)`.

