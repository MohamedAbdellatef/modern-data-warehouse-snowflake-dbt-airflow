# S2T — stg_store_targets_monthly

**Grain:** 1 row = 1 store/month target.

## Source
- `RAW.FINANCE_STORE_TARGETS_MONTHLY_RAW`
  - cols: `store_id, month_key, target_amount_aed, source_system, ingestion_date`

## Target
- `STG.stg_store_targets_monthly`

| Target Column     | Type       | Source/Rule |
|---|---|---|
| store_id          | number     | `store_id` |
| month_key         | number(6)  | `month_key`  *(YYYYMM)* |
| target_amount_aed | number(18,2) | `target_amount_aed` |
| source_system     | varchar    | `source_system` |
| load_date         | date       | `to_date(ingestion_date)` |

**Tests**
- `not_null: (store_id, month_key)`
- `unique_combination: (store_id, month_key)`
