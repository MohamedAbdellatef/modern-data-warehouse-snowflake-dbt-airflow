# 01_data_lake — Azure Data Lake Gen2 (DEV)

This folder documents the **landing zone** for files in the storage account
`datafromsources` (UAE North, Hierarchical Namespace **enabled**).

It explains where data lives, how folders are partitioned, and how Snowflake reads it.

---

## 1) Containers & purpose

| Container | Purpose | Typical file |
|-----------|---------|--------------|
| `crm`     | Customer master from CRM | `2025/09/crm_customers_202509.csv` |
| `oms`     | Orders domain (orders / order_items / returns) | `orders/2025/10/oms_orders_202510.csv` |
| `psp`     | Payments from PSP | `payments/2025/09/psp_payments_202509.csv` |
| `erp`     | Exchange rates (daily) | `fx_rates_daily/2025/08/erp_fx_rates_daily_202508.csv` |
| `finance` | Store monthly targets | `store_targets_monthly/2025/10/finance_store_targets_monthly_202510.csv` |
| `gov`     | Static VAT policy | `gov_vat_policy.csv` |
| `pos`     | Stores master | `pos_stores.csv` |
| `pim`     | Product catalog | `pim_products.csv` |

A machine-readable manifest of all paths/patterns is in [`adls_manifest.yml`](./adls_manifest.yml).

---

## 2) Partitioning & naming

- **Monthly** folders (when applicable): `.../2025/08/`, `.../2025/09/`, `.../2025/10/`
- **File names** carry year/month:  
  - `crm_customers_YYYYMM.csv`  
  - `psp_payments_YYYYMM.csv`  
  - `erp_fx_rates_daily_YYYYMM.csv` (contains many days)  
  - `finance_store_targets_monthly_YYYYMM.csv`
- **Static lookups** (no partition): `gov_vat_policy.csv`, `pim_products.csv`, `pos_stores.csv`.

**CSV contract**

- UTF-8, comma‐separated, header row present
- Fields optionally enclosed by `"`
- `NULL` or empty string treated as null

Snowflake reuses a **common file format**:

```sql
CREATE OR REPLACE FILE FORMAT GULFMART.RAW.RAW_COMMON_CSV
  TYPE = CSV
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  NULL_IF = ('', 'NULL');

## 3) How this is used

- Airflow lands CSVs into these ADLS paths.
- Snowflake external stages (see `04_snowflake/04_create_stages.sql`) point at each container.
- `COPY INTO` commands (see `04_snowflake/06_copy_into_raw.sql`) load data into `GULFMART.RAW.*_RAW` tables using `RAW_COMMON_CSV`.
