-- Simple daily cost view per warehouse
select
  day,
  warehouse_name,
  credits,
  round(credits * 2, 2) as approx_usd_cost -- adjust for your rate
from (
  select
    date_trunc('day', start_time) as day,
    warehouse_name,
    sum(credits_used) as credits
  from snowflake.account_usage.warehouse_metering_history
  group by 1,2
)
order by day desc, warehouse_name;
