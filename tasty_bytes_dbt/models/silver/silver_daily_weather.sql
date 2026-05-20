{{
    config(
        materialized='incremental',
        unique_key=['postal_code', 'country', 'date_valid_std'],
        on_schema_change='append_new_columns'
    )
}}

SELECT
    hd.postal_code,
    hd.country,
    hd.date_valid_std,
    TO_VARCHAR(hd.date_valid_std, 'YYYY-MM')    AS yyyy_mm,
    pc.city_name,
    c.country                                   AS country_desc,
    hd.avg_temperature_air_2m_f,
    hd.tot_precipitation_in,
    hd.max_wind_speed_100m_mph
FROM {{ ref('bronze_weather_history') }} hd
JOIN {{ ref('bronze_postal_codes') }} pc
    ON pc.postal_code = hd.postal_code
    AND pc.country = hd.country
JOIN {{ ref('bronze_country') }} c
    ON c.iso_country = hd.country
    AND c.city = pc.city_name

{% if is_incremental() %}
    -- only process weather dates not yet in the table
    WHERE hd.date_valid_std > (SELECT MAX(date_valid_std) FROM {{ this }})
{% endif %}
