# R1 — Monthly Orders by Store

**Business Question:**  
How many completed orders did each store get per calendar month?

**Metric Formula:** COUNT(DISTINCT order_id)

**Grain:** One row = one completed order  
**Fact Type:** Transactional  
**Fact Table:** fact_order  
**Dimensions:** dim_store, dim_date  
**Timezone Policy:** Store local (Asia/Dubai, Asia/Riyadh)

**DQ Checks:**  
- Unique order_id  
- 0 null foreign keys  
- Valid order status (completed, fulfilled)
