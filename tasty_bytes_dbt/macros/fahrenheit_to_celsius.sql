{% macro fahrenheit_to_celsius(temp_f) %}
    ({{ temp_f }} - 32) * (5.0 / 9)
{% endmacro %}
