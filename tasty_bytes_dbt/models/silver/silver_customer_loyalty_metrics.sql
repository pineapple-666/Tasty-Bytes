{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        on_schema_change='append_new_columns'
    )
}}

SELECT
    cl.customer_id,
    cl.city,
    cl.country,
    cl.first_name,
    cl.last_name,
    cl.phone_number,
    cl.e_mail,
    cl.gender,
    cl.marital_status,
    cl.children_count,
    cl.favourite_brand,
    cl.sign_up_date,
    SUM(oh.order_total)                         AS total_sales,
    COUNT(DISTINCT oh.order_id)                 AS total_orders,
    ARRAY_AGG(DISTINCT oh.location_id)          AS visited_location_ids_array,
    MAX(oh.order_ts)                            AS last_order_ts
FROM {{ ref('bronze_customer_loyalty') }} cl
JOIN {{ ref('bronze_order_header') }} oh
    ON cl.customer_id = oh.customer_id

{% if is_incremental() %}
    -- find customers who have placed orders since the last run,
    -- then re-aggregate their FULL history so cumulative totals stay correct.
    -- the MERGE on unique_key='customer_id' overwrites their existing row.
    WHERE cl.customer_id IN (
        SELECT DISTINCT customer_id
        FROM {{ ref('bronze_order_header') }}
        WHERE order_ts > (SELECT MAX(last_order_ts) FROM {{ this }})
    )
{% endif %}

GROUP BY
    cl.customer_id,
    cl.city,
    cl.country,
    cl.first_name,
    cl.last_name,
    cl.phone_number,
    cl.e_mail,
    cl.gender,
    cl.marital_status,
    cl.children_count,
    cl.favourite_brand,
    cl.sign_up_date
