SELECT
    postal_code,
    country,
    date_valid_std,
    city_name,
    avg_temperature_air_2m_f,
    tot_precipitation_in,
    max_wind_speed_100m_mph
FROM {{ source('frostbyte_weathersource', 'history_day') }}
