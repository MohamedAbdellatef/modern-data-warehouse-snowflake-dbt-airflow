# Operations (Runbooks, SLOs, Cost & Monitoring)

This folder documents how the **retail daily pipeline** runs in production.

- **alerts/**: Slack alert patterns and expectations.
- **checks/**: Data-diff config + SQL smoke checks.
- **cost/**: Ready-to-run Snowflake credit / cost queries.
- **data_contracts/**: Schema contracts for critical models (e.g. `fact_order_line`).
- **lineage/**: OpenLineage example env configuration.
- **monitors/**: Snowflake resource monitor + warehouse and query-tagging policies.
- **runbooks/**: How to operate and recover the `retail_pipeline` DAG.
- **slo/**: Freshness, timeliness and reliability targets.

**Owners**: Data Engineering  
**SLA**: DAG `retail_pipeline` finishes by **06:30 Asia/Riyadh** on business days.
