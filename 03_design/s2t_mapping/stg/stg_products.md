# S2T — stg_products

**Grain:** 1 row = 1 product/SKU.

## Source
- `RAW.PIM_PRODUCTS_RAW`
  - cols: `product_id, sku, product_name, category, subcategory, brand, vat_class, is_active_flag, ingestion_date, source_system`

## Target
- `STG.stg_products`

| Target Column | Type | Source/Rule |
|---|---|---|
| product_id     | number  | `product_id` |
| sku            | varchar | `upper(trim(sku))` |
| product_name   | varchar | `initcap(trim(product_name))` |
| category       | varchar | `initcap(trim(category))` |
| subcategory    | varchar | `initcap(trim(subcategory))` |
| brand          | varchar | `initcap(trim(brand))` |
| vat_class      | varchar | `upper(trim(vat_class))` |
| is_active_flag | boolean | `try_to_boolean(is_active_flag)` |
| source_system  | varchar | `source_system` |
| load_date      | date    | `to_date(ingestion_date)` |

**Tests**
- `not_null: product_id`
- `unique: product_id`
