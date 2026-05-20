{{ config(severity = 'warn') }}

SELECT
    date,
    daily_sales
FROM {{ ref('gold_daily_sales_hamburg') }}
WHERE daily_sales < 0
