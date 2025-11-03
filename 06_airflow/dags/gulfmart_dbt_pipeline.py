from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# 🔧 CHANGE THIS to the path of your dbt project *inside the Airflow container*
DBT_PROJECT_DIR = "/usr/local/airflow/dags/05_dbt_project"
DBT_PROFILES_DIR = DBT_PROJECT_DIR  # you have profiles.yml in project root

default_args = {
    "owner": "gulfmart",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="gulfmart_dbt_pipeline",
    default_args=default_args,
    schedule_interval="0 3 * * *",  # daily at 03:00
    start_date=datetime(2025, 1, 1),
    catchup=False,
    max_active_runs=1,
    tags=["gulfmart", "dbt"],
) as dag:

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt deps"
        ),
    )

    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt snapshot --target dev"
        ),
    )

    dbt_run_core = BashOperator(
        task_id="dbt_run_core",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt run -s models/core/* --target dev"
        ),
    )

    dbt_run_marts = BashOperator(
        task_id="dbt_run_marts",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt run -s models/marts/* --target dev"
        ),
    )

    dbt_test_all = BashOperator(
        task_id="dbt_test_all",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt test --target dev"
        ),
    )

    dbt_source_freshness = BashOperator(
        task_id="dbt_source_freshness",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt source freshness --target dev"
        ),
    )

    # 🧩 Dependency graph
    dbt_deps >> dbt_snapshot >> dbt_run_core >> dbt_run_marts >> dbt_test_all
    dbt_run_core >> dbt_source_freshness
