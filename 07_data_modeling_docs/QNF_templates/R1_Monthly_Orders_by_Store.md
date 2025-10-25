# QNF: R1 — Monthly Orders by Store

**Business Question:**  
How many completed orders did each store receive per calendar month?

**Business Need / Decision:**  
The Operations department tracks monthly order volume per store to evaluate sales performance, staffing efficiency, and resource allocation.  
This metric feeds directly into store performance dashboards and monthly operational reviews.

**Owner / Department:**  
Operations — Regional Retail Management.

**Metric Definition (Formula):**  
Orders = COUNT(DISTINCT order_id)  
Include only orders with `status IN ('completed','fulfilled')`  
Exclude `test`, `internal`, and `fraud` transactions.

**Aggregation Logic:**  
COUNT DISTINCT per store per calendar month.

**Counting Unit / Population:**  
All valid customer orders from POS and e-commerce systems that reached final status (`completed`, `fulfilled`).
Online handling: e-commerce orders are mapped to ONLINE_UAE or ONLINE_KSA virtual stores and included.

**Time Grain & Anchor:**  
Calendar month using store-local order timestamp (order_local_ts).

**Timezone & Boundary Policy:**  
Bucket orders using the **store’s local timezone**:  
- UAE stores → `Asia/Dubai (UTC +4)`  
- KSA stores → `Asia/Riyadh (UTC +3)`  
Month boundary = 00:00 local on the 1st.  
Regional consolidation for HQ is shown in Asia/Riyadh

**Filters (In / Out):**  
- **Include:** Completed or fulfilled customer orders.  
- **Exclude:** Test, fraud, internal, or canceled transactions.

**Breakdowns (Primary):**  
- Store (with hierarchy: Store → City → Country)  
- Channel (POS / Web / Marketplace)

**Currency / FX:**  
N/A — purely a volume metric.

**Related Dimensions:**  
- `dim_store`  
- `dim_date` (role: order_date)  
- `dim_channel`

**SLA / Refresh Policy:**  
Freshness T+1 by 06:00 Asia/Riyadh (03:00 UTC).
Monthly snapshot locks at T+2 (no changes after finance close).

**Acceptance Example:**  
For **October 2025**, Store = *Riyadh Gallery* reported **205 completed orders**.
