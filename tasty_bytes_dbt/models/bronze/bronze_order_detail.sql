SELECT
    order_detail_id,
    order_id,
    menu_item_id,
    discount_id,
    line_number,
    quantity,
    unit_price,
    price,
    order_item_discount_amount
FROM {{ source('tasty_bytes_raw_pos', 'order_detail') }}
