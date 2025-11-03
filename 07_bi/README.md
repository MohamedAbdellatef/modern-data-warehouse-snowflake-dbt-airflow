# BI Layer — GulfMart

This folder describes how marts are consumed in BI tools (Power BI / Tableau / Looker).

## Dashboards

1. **R1 – Monthly Orders by Store**
   - Source mart: `mart_monthly_orders_by_store`
   - Grain: month × store
   - Key visuals:
     - Bar chart: orders_count by store_name
     - Line chart: orders_count over time

2. **R2 – Net Sales by Country**
   - Source mart: `mart_net_sales_by_country_monthly`
   - Grain: month × country
   - Metrics: `net_amount_ex_vat_aed`, orders_count

3. **R3 – Orders by Payment Method**
   - Source mart: `mart_orders_by_payment_method_monthly`
   - Grain: month × payment_method
   - Metrics: orders_count, share_of_orders_pct

4. **R4 – Average Order Value (AOV)**
   - Source mart: `mart_aov_monthly`
   - Grain: month
   - Metric: `aov_net_aed`

5. **R5 – Refund Rate / Amount**
   - Source mart: `mart_refund_rate_amount_monthly`
   - Grain: month
   - Metrics: refund_rate_pct, refund_amount_aed

6. **R6 – Orders Channel Mix**
   - Source mart: `mart_channel_mix_monthly`
   - Grain: month × channel
   - Metrics: orders_count, share_pct

7. **C1 – Active Customers per Month**
   - Source mart: `mart_active_customers_monthly`

8. **C2 – Repeat Purchase Rate**
   - Source mart: `mart_repeat_purchase_rate_monthly`

9. **S1 – Store Performance Index**
   - Source mart: `mart_store_performance_index`

10. **S2 – Revenue vs Target Gap**
    - Source mart: `mart_store_target_vs_actual_monthly`

## Future Work

- Add screenshots or exported PBIX / TDS / LookML files.
- Add links to real dashboards when deployed.
