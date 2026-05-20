SELECT
    country_id,
    country,
    iso_currency,
    iso_country,
    city_id,
    city,
    city_population
FROM {{ source('tasty_bytes_raw_pos', 'country') }}
