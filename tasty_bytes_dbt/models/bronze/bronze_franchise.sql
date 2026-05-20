SELECT
    franchise_id,
    first_name,
    last_name,
    city,
    country,
    e_mail,
    phone_number
FROM {{ source('tasty_bytes_raw_pos', 'franchise') }}
