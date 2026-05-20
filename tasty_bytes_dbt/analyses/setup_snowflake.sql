-- =============================================================================
-- TASTY BYTES — ONE-TIME SNOWFLAKE SETUP
-- Run this script ONCE before your first `dbt run`.
-- It creates the source database, schemas, raw tables, and loads data from S3.
-- FROSTBYTE_WEATHERSOURCE must be separately imported from the Snowflake Marketplace.
-- =============================================================================

USE ROLE accountadmin;


-- -----------------------------------------------------------------------------
-- 1. DATABASE AND SOURCE SCHEMAS
-- These hold the raw transactional data that dbt's bronze layer reads from.
-- -----------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS tasty_bytes;

CREATE SCHEMA IF NOT EXISTS tasty_bytes.raw_pos;       -- point-of-sale tables
CREATE SCHEMA IF NOT EXISTS tasty_bytes.raw_customer;  -- customer loyalty tables


-- -----------------------------------------------------------------------------
-- 2. WAREHOUSE
-- -----------------------------------------------------------------------------

CREATE WAREHOUSE IF NOT EXISTS compute_wh
    WAREHOUSE_SIZE   = 'xsmall'
    WAREHOUSE_TYPE   = 'standard'
    AUTO_SUSPEND     = 60
    AUTO_RESUME      = TRUE
    INITIALLY_SUSPENDED = TRUE;

USE WAREHOUSE compute_wh;


-- -----------------------------------------------------------------------------
-- 3. S3 STAGE
-- The Tasty Bytes dataset is hosted publicly on S3 by Snowflake.
-- We create a named stage that points to the bucket path.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff
    TYPE = 'csv'
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    TRIM_SPACE = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    REPLACE_INVALID_CHARACTERS = TRUE
    DATE_FORMAT = AUTO
    TIME_FORMAT = AUTO
    TIMESTAMP_FORMAT = AUTO;

CREATE OR REPLACE STAGE tasty_bytes.public.s3load
    URL = 's3://sfquickstarts/tasty-bytes-builder-education/'
    FILE_FORMAT = tasty_bytes.public.csv_ff;

-- Verify the stage is reachable (lists files in the bucket):
-- LIST @tasty_bytes.public.s3load;


-- -----------------------------------------------------------------------------
-- 4. RAW TABLE DDL
-- These tables live in the source schemas (raw_pos, raw_customer).
-- dbt's bronze models SELECT from these — they do NOT create them.
-- -----------------------------------------------------------------------------

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.country (
    country_id      NUMBER(18,0),
    country         VARCHAR,
    iso_currency    VARCHAR(3),
    iso_country     VARCHAR(2),
    city_id         NUMBER(19,0),
    city            VARCHAR,
    city_population VARCHAR
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.franchise (
    franchise_id    NUMBER(38,0),
    first_name      VARCHAR,
    last_name       VARCHAR,
    city            VARCHAR,
    country         VARCHAR,
    e_mail          VARCHAR,
    phone_number    VARCHAR
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.location (
    location_id     NUMBER(19,0),
    placekey        VARCHAR,
    location        VARCHAR,
    city            VARCHAR,
    region          VARCHAR,
    iso_country_code VARCHAR,
    country         VARCHAR
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.menu (
    menu_id                         NUMBER(19,0),
    menu_type_id                    NUMBER(38,0),
    menu_type                       VARCHAR,
    truck_brand_name                VARCHAR,
    menu_item_id                    NUMBER(38,0),
    menu_item_name                  VARCHAR,
    item_category                   VARCHAR,
    item_subcategory                VARCHAR,
    cost_of_goods_usd               NUMBER(38,4),
    sale_price_usd                  NUMBER(38,4),
    menu_item_health_metrics_obj    VARIANT
);

CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck (
    truck_id            NUMBER(38,0),
    menu_type_id        NUMBER(38,0),
    primary_city        VARCHAR,
    region              VARCHAR,
    iso_region          VARCHAR,
    country             VARCHAR,
    iso_country_code    VARCHAR,
    franchise_flag      NUMBER(38,0),
    year                NUMBER(38,0),
    make                VARCHAR,
    model               VARCHAR,
    ev_flag             NUMBER(38,0),
    franchise_id        NUMBER(38,0),
    truck_opening_date  DATE
);

-- order_header is the primary transactional (fact) table.
-- New rows arrive continuously as customers place orders.
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_header (
    order_id                NUMBER(38,0),
    truck_id                NUMBER(38,0),
    location_id             FLOAT,
    customer_id             NUMBER(38,0),
    discount_id             VARCHAR,
    shift_id                NUMBER(38,0),
    shift_start_time        TIME(9),
    shift_end_time          TIME(9),
    order_channel           VARCHAR,
    order_ts                TIMESTAMP_NTZ(9),
    served_ts               VARCHAR,
    order_currency          VARCHAR(3),
    order_amount            NUMBER(38,4),
    order_tax_amount        VARCHAR,
    order_discount_amount   VARCHAR,
    order_total             NUMBER(38,4)
);

-- order_detail holds the line items for each order (one row per menu item ordered).
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_detail (
    order_detail_id             NUMBER(38,0),
    order_id                    NUMBER(38,0),
    menu_item_id                NUMBER(38,0),
    discount_id                 VARCHAR,
    line_number                 NUMBER(38,0),
    quantity                    NUMBER(5,0),
    unit_price                  NUMBER(38,4),
    price                       NUMBER(38,4),
    order_item_discount_amount  VARCHAR
);

CREATE OR REPLACE TABLE tasty_bytes.raw_customer.customer_loyalty (
    customer_id         NUMBER(38,0),
    first_name          VARCHAR,
    last_name           VARCHAR,
    city                VARCHAR,
    country             VARCHAR,
    postal_code         VARCHAR,
    preferred_language  VARCHAR,
    gender              VARCHAR,
    favourite_brand     VARCHAR,
    marital_status      VARCHAR,
    children_count      VARCHAR,
    sign_up_date        DATE,
    birthday_date       DATE,
    e_mail              VARCHAR,
    phone_number        VARCHAR
);


-- -----------------------------------------------------------------------------
-- 5. INITIAL DATA LOAD — COPY INTO FROM S3
-- This is a one-time historical load.
-- For ongoing ingestion see Section 6 below.
-- -----------------------------------------------------------------------------

USE WAREHOUSE compute_wh;

COPY INTO tasty_bytes.raw_pos.country
    FROM @tasty_bytes.public.s3load/raw_pos/country/;

COPY INTO tasty_bytes.raw_pos.franchise
    FROM @tasty_bytes.public.s3load/raw_pos/franchise/;

COPY INTO tasty_bytes.raw_pos.location
    FROM @tasty_bytes.public.s3load/raw_pos/location/;

COPY INTO tasty_bytes.raw_pos.menu
    FROM @tasty_bytes.public.s3load/raw_pos/menu/;

COPY INTO tasty_bytes.raw_pos.truck
    FROM @tasty_bytes.public.s3load/raw_pos/truck/;

COPY INTO tasty_bytes.raw_customer.customer_loyalty
    FROM @tasty_bytes.public.s3load/raw_customer/customer_loyalty/;

-- The order tables (transactional data) are loaded from a subset provided by Snowflake.
-- In production, new files are dropped into S3 continuously and picked up by Snowpipe.
COPY INTO tasty_bytes.raw_pos.order_header
    FROM @tasty_bytes.public.s3load/raw_pos/subset_order_header/;

COPY INTO tasty_bytes.raw_pos.order_detail
    FROM @tasty_bytes.public.s3load/raw_pos/subset_order_detail/;


-- -----------------------------------------------------------------------------
-- 6. ONGOING INGESTION — SNOWFLAKE SNOWPIPE (CONTINUOUS S3 → SNOWFLAKE)
-- Snowpipe watches the S3 bucket and auto-ingests new files as they land.
-- Your ERP / POS system writes new order CSV/JSON files to S3.
-- Snowpipe picks them up within seconds — no polling needed.
-- -----------------------------------------------------------------------------

-- Create a dedicated pipe for order_header (the main transactional table).
CREATE OR REPLACE PIPE tasty_bytes.public.pipe_order_header
    AUTO_INGEST = TRUE   -- triggered by S3 event notifications
AS
COPY INTO tasty_bytes.raw_pos.order_header
    FROM @tasty_bytes.public.s3load/raw_pos/order_header/
    FILE_FORMAT = (FORMAT_NAME = 'tasty_bytes.public.csv_ff');

CREATE OR REPLACE PIPE tasty_bytes.public.pipe_order_detail
    AUTO_INGEST = TRUE
AS
COPY INTO tasty_bytes.raw_pos.order_detail
    FROM @tasty_bytes.public.s3load/raw_pos/order_detail/
    FILE_FORMAT = (FORMAT_NAME = 'tasty_bytes.public.csv_ff');

-- Check pipe status:
-- SELECT SYSTEM$PIPE_STATUS('tasty_bytes.public.pipe_order_header');

-- Pause / resume Snowpipe:
-- ALTER PIPE tasty_bytes.public.pipe_order_header PAUSE;
-- ALTER PIPE tasty_bytes.public.pipe_order_header RESUME;

-- NOTE: AUTO_INGEST requires an S3 event notification (SQS queue) pointing at Snowflake.
-- See: https://docs.snowflake.com/en/user-guide/data-load-snowpipe-auto-s3
-- For testing without event notifications, you can call:
-- ALTER PIPE tasty_bytes.public.pipe_order_header REFRESH;
