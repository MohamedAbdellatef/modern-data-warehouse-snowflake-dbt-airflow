-- Quick health checks after build
select count(*) as rows from CORE.MARTS.FACT_ORDER_LINE;
select count(*) as recent_rows
from CORE.MARTS.FACT_ORDER_LINE
where order_local_ts >= dateadd('day', -1, current_timestamp());
