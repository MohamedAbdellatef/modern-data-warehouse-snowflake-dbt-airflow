# S2T — stg_customers

**Grain (STG):** 1 row = 1 customer from CRM.

## Source
- **RAW table:** `RAW.CRM_CUSTOMERS_RAW`
- **Natural key:** `customer_id_nat`
- **Important cols (as landed):**
  - `customer_id_nat, loyalty_tier, is_vip_flag, source_system, registration_ts, first_purchase_ts, country_code, city, email_optin_flag, birth_date, ingestion_date`

## Target
- **STG model:** `STG.stg_customers`

| Target Column        | Data Type      | Source/Rule                                                           |
|---|---|---|
| customer_id_nat      | varchar        | `customer_id_nat`                                                     |
| loyalty_tier         | varchar        | `nullif(trim(loyalty_tier),'')`                                       |
| is_vip_flag          | boolean        | `try_to_boolean(is_vip_flag)`                                         |
| source_system        | varchar        | `source_system`                                                       |
| registration_ts      | timestamp_ntz  | `try_to_timestamp_ntz(registration_ts)`                               |
| first_purchase_ts    | timestamp_ntz  | `try_to_timestamp_ntz(first_purchase_ts)`                             |
| country_code         | varchar        | `upper(trim(country_code))`                                           |
| city                 | varchar        | `initcap(trim(city))`                                                 |
| email_optin_flag     | boolean        | `try_to_boolean(email_optin_flag)`                                    |
| birth_date           | date           | `try_to_date(birth_date)`                                             |
| load_date            | date           | `to_date(ingestion_date)`                                            |

**Filters**
- keep all rows.

**Tests (dbt)**
- `not_null: customer_id_nat`
- `accepted_values: country_code in ('AE','SA','BH','KW','QA','OM','EG','JO','LB')` 
