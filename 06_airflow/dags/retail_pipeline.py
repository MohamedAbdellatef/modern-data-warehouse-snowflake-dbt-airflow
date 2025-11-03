from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator


# -------- Slack failure callback --------
def slack_failure_callback(context):
    """
    Sends a Slack alert on DAG failure.
    Requires a connection called `slack_default` of type HTTP
    pointing to your Slack webhook URL.
    """
    from airflow.providers.slack.operators.slack_webhook import SlackWebhookOperator

    dag_id = context["dag"].dag_id
    task_id = context["task_instance"].task_id
    ts = context["ts"]

    message = (
        f":rotating_light: DAG *{dag_id}* failed\n"
        f"*Task*: `{task_id}`\n"
        f"*When*: {ts}"
    )

    SlackWebhookOperator(
        task_id="slack_failure_notification",
        http_conn_id="slack_default",
        message=message,
        username="airflow",
    ).execute(context=context)


# -------- DAG definition --------
DBT_PROJECT_DIR = "/opt/airflow/dags/05_dbt_project"
DBT_PROFILES_DIR = "/opt/airflow/dags/05_dbt_project/.dbt"

default_args = {
    "owner": "data-eng",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="retail_pipeline",
    description="GulfMart daily retail pipeline: dbt stg → core → marts",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 6 * * *",  # 06:00 every day (set Airflow timezone to Asia/Riyadh)
    catchup=False,
    default_args=default_args,
    on_failure_callback=slack_failure_callback,
    tags=["gulfmart", "dbt", "retail"],
) as dag:

    start = EmptyOperator(task_id="start")

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt deps",
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    # Build stg + core + marts (includes tests on each model)
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt build --select models/stg models/core models/marts --fail-fast"
        ),
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    # Optional: dbt docs as an artifact
    dbt_docs = BashOperator(
        task_id="dbt_docs",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt docs generate",
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    end = EmptyOperator(task_id="end")

    start >> dbt_deps >> dbt_build >> dbt_docs >> end
