-- Standard warehouse policies for ingest + transform

use role ACCOUNTADMIN;

alter warehouse WH_INGEST set
  auto_suspend = 300,                 -- 5 minutes
  auto_resume = true,
  statement_timeout_in_seconds = 3600,
  max_cluster_count = 1;

alter warehouse WH_TRANSFORM set
  auto_suspend = 300,
  auto_resume = true,
  statement_timeout_in_seconds = 7200,
  max_cluster_count = 2;
