SELECT
    location_id,
    placekey,
    location,
    city,
    region,
    iso_country_code,
    country
FROM {{ source('tasty_bytes_raw_pos', 'location') }}
