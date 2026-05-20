SELECT
    postal_code,
    country,
    city_name
FROM {{ source('frostbyte_weathersource', 'postal_codes') }}
