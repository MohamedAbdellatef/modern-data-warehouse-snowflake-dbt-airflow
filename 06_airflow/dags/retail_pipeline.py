from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator


# -------- Slack failure callback --------
def slack_failure_callback(context):
    """
    Sends a Slack alert on DAG failure.

    Requires an Airflow connection called `slack_default`
    of type HTTP pointing to your Slack incoming webhook URL.
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


# -------- Paths & constants --------
DBT_PROJECT_DIR = "/opt/airflow/dags/05_dbt_project"
DBT_PROFILES_DIR = "/opt/airflow/dags/05_dbt_project/.dbt"

SNOWFLAKE_CONN_ID = "snowflake_default"
SQL_COPY_INTO_RAW = "04_snowflake/06_copy_into_raw.sql"  # relative to template_searchpath


default_args = {
    "owner": "data-eng",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


with DAG(
    dag_id="retail_pipeline",
    description="GulfMart daily pipeline: ADLS → Snowflake RAW → dbt stg/core/marts",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 6 * * *",  # 06:00 every day (Airflow timezone = Asia/Riyadh)
    catchup=False,
    default_args=default_args,
    on_failure_callback=slack_failure_callback,
    max_active_runs=1,
    tags=["gulfmart", "dbt", "retail"],
    template_searchpath=["/opt/airflow/dags"],  # so 04_snowflake/*.sql can be templated
) as dag:

    start = EmptyOperator(task_id="start")

    # 1) Load ADLS files into Snowflake RAW
    copy_into_raw = SnowflakeOperator(
        task_id="copy_into_raw",
        snowflake_conn_id=SNOWFLAKE_CONN_ID,
        sql=SQL_COPY_INTO_RAW,
    )

    # 2) Install dbt packages
    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt deps",
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    # 3) Build stg + core + marts (includes tests for each model)
    dbt_build = BashOperator(
        task_id="dbt_build",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            "dbt build --select models/stg models/core models/marts --fail-fast"
        ),
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    # 4) Generate dbt docs as an artifact
    dbt_docs = BashOperator(
        task_id="dbt_docs",
        bash_command=f"cd {DBT_PROJECT_DIR} && dbt docs generate",
        env={"DBT_PROFILES_DIR": DBT_PROFILES_DIR},
    )

    end = EmptyOperator(task_id="end")

    # Orchestration graph
    start >> copy_into_raw >> dbt_deps >> dbt_build >> dbt_docs >> end
