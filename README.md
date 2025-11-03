# modern-data-warehouse-snowflake-dbt-airflow
## 🏗️ High-Level Architecture
![Data Architecture](00_overview/architecture_diagram.gif)

## 📂 Project Structure
```
modern-data-warehouse-snowflake-dbt-airflow/
│
├── README.md                          # full project overview
├── LICENSE
├── .gitignore
│
├── 01_airflow_dags/                   # orchestration layer
│   ├── retail_pipeline.py             # main DAG: sense_snowpipe → dbt_run → dbt_test → slack alert
│   ├── sensors/
│   │   └── sense_snowpipe.py          # optional sensor to check Snowpipe COPY_HISTORY
│   ├── operators/
│   │   └── dbt_operator.py            # custom wrapper for dbt commands
│   └── configs/
│       └── airflow_variables.json     # connections, schedules, Slack webhook, etc.

```
