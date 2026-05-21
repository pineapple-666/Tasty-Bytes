{{
    config(
        materialized='incremental',
        unique_key='order_detail_id',
        on_schema_change='append_new_columns'
    )
}}

SELECT
    oh.order_id,
    oh.truck_id,
    DATE(oh.order_ts)                   AS order_date,
    oh.order_ts,
    od.order_detail_id,
    od.line_number,
    m.truck_brand_name,
    m.menu_type,
    m.menu_item_id,
    m.menu_item_name,
    m.item_category,
    m.item_subcategory,
    t.primary_city,
    t.region,
    t.country,
    t.franchise_flag,
    t.franchise_id,
    f.first_name                        AS franchisee_first_name,
    f.last_name                         AS franchisee_last_name,
    l.location_id,
    l.city                              AS location_city,
    oh.order_channel,
    oh.order_currency,
    od.quantity,
    od.unit_price,
    od.price,
    oh.order_amount,
    oh.order_tax_amount,
    oh.order_discount_amount,
    oh.order_total
FROM {{ ref('bronze_order_detail') }} od
JOIN {{ ref('bronze_order_header') }} oh
    ON od.order_id = oh.order_id
JOIN {{ ref('bronze_truck') }} t
    ON oh.truck_id = t.truck_id
JOIN {{ ref('bronze_menu') }} m
    ON od.menu_item_id = m.menu_item_id
JOIN {{ ref('bronze_franchise') }} f
    ON t.franchise_id = f.franchise_id
JOIN {{ ref('bronze_location') }} l
    ON oh.location_id = l.location_id

{% if is_incremental() %}
    -- on each run, only process orders newer than the latest already in the table
    WHERE oh.order_ts > (SELECT MAX(order_ts) FROM {{ this }})
{% endif %}
