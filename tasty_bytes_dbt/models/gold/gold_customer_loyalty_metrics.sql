{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        on_schema_change='append_new_columns'
    )
}}

SELECT
    customer_id,
    city,
    country,
    first_name,
    last_name,
    phone_number,
    e_mail,
    gender,
    marital_status,
    children_count,
    favourite_brand,
    sign_up_date,
    total_sales,
    total_orders,
    visited_location_ids_array,
    last_order_ts
FROM {{ ref('silver_customer_loyalty_metrics') }}

{% if is_incremental() %}
    -- silver already re-aggregated full history for active customers;
    -- only pass through rows that are newer than what gold already has
    WHERE last_order_ts > (SELECT MAX(last_order_ts) FROM {{ this }})
{% endif %}

ORDER BY total_sales DESC
