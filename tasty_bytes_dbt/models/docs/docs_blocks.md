{% docs order_id %}
Unique identifier for each customer order.
{% enddocs %}

{% docs truck_id %}
Unique identifier for the food truck that processed the order.
{% enddocs %}

{% docs order_date %}
Calendar date on which the order was placed, derived from order_ts.
{% enddocs %}

{% docs order_ts %}
Full timestamp when the order was placed.
{% enddocs %}

{% docs order_detail_id %}
Unique identifier for each line item within an order.
{% enddocs %}

{% docs line_number %}
Sequential line number of this item within the order.
{% enddocs %}

{% docs truck_brand_name %}
Brand name of the food truck that sold the item.
{% enddocs %}

{% docs menu_type %}
Category of cuisine offered by the truck (e.g., BBQ, Asian, Mexican).
{% enddocs %}

{% docs menu_item_id %}
Unique identifier for the menu item.
{% enddocs %}

{% docs menu_item_name %}
Display name of the menu item.
{% enddocs %}

{% docs item_category %}
High-level category grouping for the menu item.
{% enddocs %}

{% docs item_subcategory %}
More granular category for the menu item within its category.
{% enddocs %}

{% docs primary_city %}
City where the food truck primarily operates.
{% enddocs %}

{% docs region %}
Geographic region where the truck operates.
{% enddocs %}

{% docs country %}
Country where the food truck operates.
{% enddocs %}

{% docs franchise_flag %}
Flag indicating whether the truck is franchise-owned (1) or company-owned (0).
{% enddocs %}

{% docs franchise_id %}
Unique identifier for the franchise owner of the truck.
{% enddocs %}

{% docs franchisee_first_name %}
First name of the franchise owner.
{% enddocs %}

{% docs franchisee_last_name %}
Last name of the franchise owner.
{% enddocs %}

{% docs location_id %}
Unique identifier for the physical location where the truck operates.
{% enddocs %}

{% docs location_city %}
City name of the physical truck location.
{% enddocs %}

{% docs order_channel %}
Channel through which the order was placed (e.g., in-person, app).
{% enddocs %}

{% docs order_currency %}
ISO currency code for the order (e.g., USD, EUR).
{% enddocs %}

{% docs customer_id %}
Unique identifier for the loyalty program customer.
{% enddocs %}

{% docs first_name %}
Customer's first name.
{% enddocs %}

{% docs last_name %}
Customer's last name.
{% enddocs %}

{% docs e_mail %}
Customer's email address.
{% enddocs %}

{% docs phone_number %}
Customer's phone number.
{% enddocs %}

{% docs children_count %}
Number of children the customer has.
{% enddocs %}

{% docs gender %}
Customer's gender.
{% enddocs %}

{% docs marital_status %}
Customer's marital status.
{% enddocs %}

{% docs quantity %}
Number of units of the menu item ordered.
{% enddocs %}

{% docs unit_price %}
Price per unit of the menu item at the time of the order.
{% enddocs %}

{% docs price %}
Total line-item price (unit_price × quantity after discounts).
{% enddocs %}

{% docs order_amount %}
Subtotal of the order before tax and discounts.
{% enddocs %}

{% docs order_tax_amount %}
Tax amount applied to the order.
{% enddocs %}

{% docs order_discount_amount %}
Discount amount applied to the order.
{% enddocs %}

{% docs order_total %}
Final total of the order including tax and after discounts.
{% enddocs %}

{% docs date_valid_std %}
Calendar date of the weather observation.
{% enddocs %}

{% docs yyyy_mm %}
Year-month string derived from date_valid_std, formatted as YYYY-MM.
{% enddocs %}

{% docs city_name %}
Name of the city for the weather observation, from the postal codes reference table.
{% enddocs %}

{% docs country_desc %}
Full country name derived by joining weather data with Tasty Bytes country reference.
{% enddocs %}

{% docs avg_temperature_air_2m_f %}
Average air temperature at 2 meters above ground, in degrees Fahrenheit.
{% enddocs %}

{% docs avg_temperature_celsius %}
Average air temperature converted to degrees Celsius.
{% enddocs %}

{% docs avg_temperature_fahrenheit %}
Average air temperature in degrees Fahrenheit.
{% enddocs %}

{% docs tot_precipitation_in %}
Total precipitation for the day in inches.
{% enddocs %}

{% docs avg_precipitation_inches %}
Average daily precipitation in inches.
{% enddocs %}

{% docs avg_precipitation_millimeters %}
Average daily precipitation converted to millimeters.
{% enddocs %}

{% docs max_wind_speed_100m_mph %}
Maximum wind speed measured at 100 meters above ground, in miles per hour.
{% enddocs %}

{% docs daily_sales %}
Total sales revenue for the day at the given city, in the order currency.
{% enddocs %}

{% docs total_sales %}
Lifetime total spend by the customer across all orders.
{% enddocs %}

{% docs total_orders %}
Total number of distinct orders placed by the customer.
{% enddocs %}

{% docs visited_location_ids_array %}
Array of distinct location IDs the customer has visited.
{% enddocs %}

{% docs favourite_brand %}
The food truck brand the customer most frequently orders from.
{% enddocs %}

{% docs sign_up_date %}
Date the customer enrolled in the loyalty program.
{% enddocs %}
