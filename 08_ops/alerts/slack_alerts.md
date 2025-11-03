# Slack Alerts

Airflow connection id: `slack_default`  
Channel: `#data-alerts`  
Failure message template:
`:rotating_light: {{ dag.dag_id }} failed at {{ ts }} — task {{ task_instance.task_id }}. Owner: @data-eng`

For local test (curl Webhook), use a secret URL and do not commit it.
