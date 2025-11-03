from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator

# 🔧 CHANGE THESE PATHS TO MATCH YOUR AIRFLOW ENV
DBT_PROJECT_DIR = "/opt/airflow/dags/05_dbt_project"
DBT_PROFILES_DIR = "/opt/airflow/.dbt"   # or remove --profiles-dir if not needed
DBT_TARGET = "dev"

default_args = {
    "owner": "data-engineering",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="gulfmart_full_pipeline",
    description="End-to-end GulfMart pipeline: load RAW CSVs -> dbt snapshot -> dbt run -> dbt test",
    start_date=datetime(2024, 1, 1),
    schedule_interval="0 3 * * *",  # daily at 03:00
    catchup=False,
    default_args=default_args,
    max_active_runs=1,
    tags=["gulfmart", "snowflake", "dbt"],
) as dag:

    # 1️⃣ LOAD RAW LAYER (FROM STAGE TO RAW TABLES)
    # ❗️ Update stage name/path + file format to match your Snowflake setup

    load_crm_customers = SnowflakeOperator(
        task_id="load_crm_customers",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.CRM_CUSTOMERS
        FROM @RAW_STAGE/crm_customers/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_oms_orders = SnowflakeOperator(
        task_id="load_oms_orders",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.OMS_ORDERS
        FROM @RAW_STAGE/oms_orders/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_oms_order_items = SnowflakeOperator(
        task_id="load_oms_order_items",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.OMS_ORDER_ITEMS
        FROM @RAW_STAGE/oms_order_items/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_psp_payments = SnowflakeOperator(
        task_id="load_psp_payments",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.PSP_PAYMENTS
        FROM @RAW_STAGE/psp_payments/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_pim_products = SnowflakeOperator(
        task_id="load_pim_products",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.PIM_PRODUCTS
        FROM @RAW_STAGE/pim_products/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_oms_returns = SnowflakeOperator(
        task_id="load_oms_returns",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.OMS_RETURNS
        FROM @RAW_STAGE/oms_returns/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_pos_stores = SnowflakeOperator(
        task_id="load_pos_stores",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.POS_STORES
        FROM @RAW_STAGE/pos_stores/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_fx_rates_daily = SnowflakeOperator(
        task_id="load_fx_rates_daily",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.FX_RATES_DAILY
        FROM @RAW_STAGE/fx_rates_daily/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_gov_vat_policy = SnowflakeOperator(
        task_id="load_gov_vat_policy",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.GOV_VAT_POLICY
        FROM @RAW_STAGE/gov_vat_policy/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    load_finance_store_targets = SnowflakeOperator(
        task_id="load_finance_store_targets",
        snowflake_conn_id="snowflake_default",
        sql="""
        COPY INTO RAW.FINANCE_STORE_TARGETS_MONTHLY
        FROM @RAW_STAGE/finance_store_targets_monthly/
        FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY='"')
        ON_ERROR = 'ABORT_STATEMENT';
        """,
    )

    # group RAW tasks in a list for convenience
    raw_load_tasks = [
        load_crm_customers,
        load_oms_orders,
        load_oms_order_items,
        load_psp_payments,
        load_pim_products,
        load_oms_returns,
        load_pos_stores,
        load_fx_rates_daily,
        load_gov_vat_policy,
        load_finance_store_targets,
    ]

    # 2️⃣ DBT SNAPSHOTS
    dbt_snapshot = BashOperator(
        task_id="dbt_snapshot",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt snapshot --target {DBT_TARGET} --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    # 3️⃣ DBT RUN (all models: stg + core + marts)
    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt run --target {DBT_TARGET} --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    # 4️⃣ DBT TEST (all tests)
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt test --target {DBT_TARGET} --profiles-dir {DBT_PROFILES_DIR}"
        ),
    )

    # ⛓️ Dependencies:
    # RAW loads in parallel -> snapshots -> run -> test
    raw_load_tasks >> dbt_snapshot >> dbt_run >> dbt_test
