-- Quick health checks after build

-- 1) Total rows in core fact
select count(*) as rows
from CORE.FACT_ORDER_LINE;

-- 2) Recent activity (last 1 day)
select count(*) as recent_rows
from CORE.FACT_ORDER_LINE
where order_local_ts >= dateadd('day', -1, current_timestamp());
