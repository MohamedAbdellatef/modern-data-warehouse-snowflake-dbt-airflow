-- Warehouse credits by day (last 30 days)
select
  date_trunc('day', start_time) as day,
  warehouse_name,
  sum(credits_used) as credits
from snowflake.account_usage.warehouse_metering_history
where start_time >= dateadd('day', -30, current_timestamp())
group by 1, 2
order by 1 desc, 2;

