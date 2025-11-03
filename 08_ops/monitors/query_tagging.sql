-- Example: set query tag so Snowflake shows lineage back to Airflow / dbt.

alter session set query_tag = OBJECT_CONSTRUCT(
  'app', 'dbt',
  'project', 'gulfmart',
  'environment', '{{ target.name }}',
  'job', 'retail_pipeline',
  'run_at', to_char(current_timestamp(), 'YYYY-MM-DD"T"HH24:MI:SS')
)::string;
