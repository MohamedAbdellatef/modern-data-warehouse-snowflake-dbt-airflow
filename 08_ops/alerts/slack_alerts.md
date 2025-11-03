# Slack Alerts

**Airflow connection id**: `slack_default`  
**Channel**: `#data-alerts`  

Failure message template:

> `:rotating_light: {{ dag.dag_id }} failed at {{ ts }} — task {{ task_instance.task_id }}. Owner: @data-eng`

Notes:

- For local tests with `curl` + Incoming Webhooks, use a **secret URL** and do **not** commit it.
- In production, the webhook / OAuth token must be stored in:
  - Airflow Connection `slack_default`, or  
  - Airflow Variable / Secret backend (recommended).
