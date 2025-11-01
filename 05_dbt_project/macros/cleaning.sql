{% macro strip(col) %} nullif(trim({{ col }}), '') {% endmacro %}
{% macro norm_code(col) %} upper(trim({{ col }})) {% endmacro %}
{% macro safe_bool(col) %} try_to_boolean({{ col }}) {% endmacro %}
{% macro safe_ts(col) %} try_to_timestamp_ntz({{ col }}) {% endmacro %}
{% macro safe_date(col) %} try_to_date({{ col }}) {% endmacro %}
