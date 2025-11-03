-- Daily credit guardrail with suspend at 100%

use role ACCOUNTADMIN;

create or replace resource monitor RM_DAILY
  with credit_quota = 50
  frequency = daily
  start_timestamp = immediately
  triggers
    on 80 percent do notify
    on 100 percent do suspend;

alter warehouse WH_TRANSFORM set resource_monitor = RM_DAILY;
alter warehouse WH_INGEST   set resource_monitor = RM_DAILY;
