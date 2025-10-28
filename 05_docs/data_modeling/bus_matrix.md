# 📊 Bus Matrix — GulfMart Data Warehouse

This Bus Matrix defines how each business process maps to its fact tables and the conformed dimensions shared across the enterprise warehouse.  
It ensures consistent KPIs, joins, and governance across the **Order to Cash**, **Customer Activity**, and **Store Target vs Actual** processes.

---

| **Business Process** | **Fact Table** | **Fact Type / Grain** | **Grain Description** | **Key Measures (Examples)** | **Dim_Product** | **Dim_Customer** | **Dim_Payment** | **Dim_Channel** | **Dim_Store** | **Dim_Currency** | **Dim_Date** |
|-----------------------|----------------|------------------------|------------------------|------------------------------|-----------------|------------------|-----------------|-----------------|----------------|------------------|---------------|
| **Order_to_Cash** | `fact_order_line` | Transaction | 1 row per *order line* (`order_number × line_number`) at `order_local_ts` | `quantity`, `gross_amount`, `net_amount`, `vat_amount`, `discount_amount` | ✅ | ✅ | — | ✅ | ✅ | ✅ | ✅ |
| **Order_to_Cash** | `fact_order` | Transaction | 1 row per *order* at `order_local_ts` | `orders_count`, `order_net_native`, `order_net_aed`, `aov`, `order_gross_native` | — | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Customer_Activity** | `fact_customer_monthly_activity` | Periodic Snapshot | 1 row per *customer × calendar month* | `is_active_flag`, `is_repeat_flag`, `orders_count_month`, `total_net_amount_aed_month` | — | ✅ | — | ✅ | ✅ | ✅ | ✅ |
| **Store_Target_vs_Actual** | `fact_store_target_monthly` | Periodic Snapshot | 1 row per *store × calendar month* | `target_amount_aed`, `actual_amount_aed`, `variance_aed`, `variance_pct` | — | — | — | — | ✅ | ✅ | ✅ |

---

## 🧩 Notes

### 1. Conformed Dimensions
| Dimension | Description | Shared Across |
|------------|-------------|----------------|
| **dim_date** | Calendar & fiscal attributes | All facts |
| **dim_store** | Store, city, country, timezone, type (physical/online) | Order_to_Cash, Store_Target_vs_Actual, Customer_Activity |
| **dim_customer** | Loyalty tier, VIP flag, demographic attributes | Order_to_Cash, Customer_Activity |
| **dim_product** | Product, category, brand, VAT class | Order_to_Cash (line-level only) |
| **dim_channel** | Sales channel (POS, WEB, MARKETPLACE) | All order/customer-related facts |
| **dim_currency** | Currency ISO code and FX rate info | All facts with AED conversions |
| **dim_payment** | Payment method, PSP info | Order-level facts only |

---

### 2. Fact Relationships
- `fact_order_line` → feeds `fact_order` (aggregated).
- `fact_order` → feeds `fact_customer_monthly_activity` (aggregated by customer/month).
- `fact_store_target_monthly` joins with `fact_order` for actual vs target marts.

---

### 3. Grain Hierarchy Overview
| Level | Example Fact | Example Question |
|--------|---------------|------------------|
| **Transactional** | `fact_order_line`, `fact_order` | “How many orders per store/day?” |
| **Periodic Snapshot (Monthly)** | `fact_customer_monthly_activity`, `fact_store_target_monthly` | “What % of active customers were repeat buyers this month?” / “Which store exceeded its target?” |

---

### 4. Usage in Marts
| Mart | Based On | KPI / Metric |
|-------|-----------|--------------|
| `mart_sales_monthly_by_store` | `fact_order` | R1 — Monthly Orders by Store |
| `mart_revenue_country_monthly` | `fact_order_line` | R2 — Net Revenue ex-VAT by Country |
| `mart_aov_monthly` | `fact_order` | R4 — Average Order Value |
| `mart_channel_mix_monthly` | `fact_order` | R6 — Online vs In-Store Mix |
| `mart_active_customers_monthly` | `fact_customer_monthly_activity` | C1 — Active Customers |
| `mart_repeat_rate_monthly` | `fact_customer_monthly_activity` | C2 — Repeat Rate |
| `mart_store_target_monthly` | `fact_store_target_monthly` | S1/S2 — Target vs Actual |

---

### 5. Incremental Policy Summary
| Process | Incremental Logic | Late Arrivals |
|----------|------------------|----------------|
| Order_to_Cash | Watermark on `ingestion_date`; freeze after T+2 | Allowed until T+2 |
| Customer_Activity | Recomputed monthly from order facts | N/A |
| Store_Target_vs_Actual | Refreshed monthly on Finance update | N/A |

---