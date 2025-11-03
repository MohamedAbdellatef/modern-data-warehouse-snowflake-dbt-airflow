from airflow import DAG
from airflow.utils.dates import days_ago
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator

default_args = {
    "owner": "data_engineer",
    "retries": 1,
    "email_on_failure": True,
}

with DAG(
    dag_id="gulfmart_daily_ingestion",
    description="Daily pipeline: load landed files from ADLS Gen2 into Snowflake RAW, then continue dbt transforms.",
    default_args=default_args,
    start_date=days_ago(1),
    schedule_interval="@daily",
    catchup=False,
    max_active_runs=1,
) as dag:

    load_raw_oms_orders = SnowflakeOperator(
        task_id="load_raw_oms_orders",
        snowflake_conn_id="snowflake_conn",
        sql="""
            COPY INTO GULFMART.RAW.OMS_ORDERS_RAW
            FROM @GULFMART.RAW.ADL_STAGE/oms/oms_orders/load_date={{ ds }}/
            FILE_FORMAT=(FORMAT_NAME = GULFMART.RAW.FF_CSV)
            ON_ERROR='CONTINUE';
        """,
    )

    load_raw_oms_order_items = SnowflakeOperator(
        task_id="load_raw_oms_order_items",
        snowflake_conn_id="snowflake_conn",
        sql="""
            COPY INTO GULFMART.RAW.OMS_ORDER_ITEMS_RAW
            FROM @GULFMART.RAW.ADL_STAGE/oms/oms_order_items/load_date={{ ds }}/
            FILE_FORMAT=(FORMAT_NAME = GULFMART.RAW.FF_CSV)
            ON_ERROR='CONTINUE';
        """,
    )

    load_raw_psp_payments = SnowflakeOperator(
        task_id="load_raw_psp_payments",
        snowflake_conn_id="snowflake_conn",
        sql="""
            COPY INTO GULFMART.RAW.PSP_PAYMENTS_RAW
            FROM @GULFMART.RAW.ADL_STAGE/psp/psp_payments/load_date={{ ds }}/
            FILE_FORMAT=(FORMAT_NAME = GULFMART.RAW.FF_CSV)
            ON_ERROR='CONTINUE';
        """,
    )

    load_raw_fx_rates = SnowflakeOperator(
        task_id="load_raw_fx_rates",
        snowflake_conn_id="snowflake_conn",
        sql="""
            COPY INTO GULFMART.RAW.ERP_FX_RATES_DAILY_RAW
            FROM @GULFMART.RAW.ADL_STAGE/erp/fx_rates_daily/load_date={{ ds }}/
            FILE_FORMAT=(FORMAT_NAME = GULFMART.RAW.FF_CSV)
            ON_ERROR='CONTINUE';
        """,
    )

    load_raw_store_targets = SnowflakeOperator(
        task_id="load_raw_store_targets",
        snowflake_conn_id="snowflake_conn",
        sql="""
            COPY INTO GULFMART.RAW.FINANCE_STORE_TARGETS_MONTHLY_RAW
            FROM @GULFMART.RAW.ADL_STAGE/finance/store_targets_monthly/load_date={{ ds }}/
            FILE_FORMAT=(FORMAT_NAME = GULFMART.RAW.FF_CSV)
            ON_ERROR='CONTINUE';
        """,
    )

    # execution order 
    load_raw_oms_orders >> load_raw_oms_order_items >> load_raw_psp_payments >> load_raw_fx_rates >> load_raw_store_targets
