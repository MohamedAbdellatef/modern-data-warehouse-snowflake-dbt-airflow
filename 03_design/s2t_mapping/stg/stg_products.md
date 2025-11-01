# S2T — stg_products

**Grain:** 1 row = 1 SKU.

## Source
- RAW: `RAW.PIM_PRODUCTS_RAW`
- Columns: `sku, product_name, category, brand, vat_class, source_system`

## Target
- STG: `STG.stg_products`

| Target Column | Type | Source/Rule |
|---|---|---|
| sku           | varchar | `upper(trim(sku))` |
| product_name  | varchar | `initcap(trim(product_name))` |
| category      | varchar | `initcap(trim(category))` |
| brand         | varchar | `initcap(trim(brand))` |
| vat_class     | varchar | `upper(trim(vat_class))` |
| source_system | varchar | `source_system` |
| load_date     | date    | `current_date()` |

**Notes**
- `sku` is the natural key; ensure uniqueness.

