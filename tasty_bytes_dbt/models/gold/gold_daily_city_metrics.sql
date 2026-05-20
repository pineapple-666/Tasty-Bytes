{{
    config(
        materialized='incremental',
        unique_key=['date', 'city_name', 'country_desc'],
        on_schema_change='append_new_columns'
    )
}}

SELECT
    dw.date_valid_std                                               AS date,
    dw.city_name,
    dw.country_desc,
    ZEROIFNULL(SUM(o.price))                                        AS daily_sales,
    ROUND(AVG(dw.avg_temperature_air_2m_f), 2)                     AS avg_temperature_fahrenheit,
    ROUND(AVG({{ fahrenheit_to_celsius('dw.avg_temperature_air_2m_f') }}), 2) AS avg_temperature_celsius,
    ROUND(AVG(dw.tot_precipitation_in), 2)                         AS avg_precipitation_inches,
    ROUND(AVG({{ inch_to_millimeter('dw.tot_precipitation_in') }}), 2)        AS avg_precipitation_millimeters,
    MAX(dw.max_wind_speed_100m_mph)                                AS max_wind_speed_100m_mph
FROM {{ ref('silver_daily_weather') }} dw
LEFT JOIN {{ ref('silver_orders') }} o
    ON dw.date_valid_std = o.order_date
    AND dw.city_name = o.primary_city
    AND dw.country_desc = o.country

{% if is_incremental() %}
    -- only process dates not yet in the gold table
    WHERE dw.date_valid_std > (SELECT MAX(date) FROM {{ this }})
{% endif %}

GROUP BY
    dw.date_valid_std,
    dw.city_name,
    dw.country_desc
ORDER BY
    dw.date_valid_std,
    dw.country_desc,
    dw.city_name
