# Tasty Bytes — dbt + Snowflake Data Engineering Pipeline

## Overview

I work as a data engineer on the Tasty Bytes team — a fictional food truck business operating 450 trucks globally. Analysts flagged the Hamburg, Germany truck as an underperformer and asked me to investigate. My goal was to build a production-grade data pipeline that combines Tasty Bytes sales data with third-party weather data to find the root cause.

The finding: **Hamburg experiences consistently high wind speeds (40–67 mph), which suppresses food truck sales. Customers don't go out in those conditions.**

The pipeline ingests raw data from Snowflake's S3-hosted dataset and the FROSTBYTE_WEATHERSOURCE Marketplace feed, transforms it through a bronze → silver → gold architecture using dbt, and delivers the result as a live Streamlit dashboard deployed inside Snowflake.

---

## Architecture

```
S3 (Tasty Bytes)          Snowflake Marketplace
      │                          │
      ▼                          ▼
 RAW_POS / RAW_CUSTOMER    FROSTBYTE_WEATHERSOURCE
      │                          │
      └──────────┬───────────────┘
                 ▼
           Bronze Layer (views)
           Silver Layer (incremental tables)
           Gold Layer   (incremental tables)
                 │
                 ▼
        Streamlit Dashboard
```

| Layer  | Snowflake Schema     | Materialization | Purpose                              |
|--------|----------------------|-----------------|--------------------------------------|
| Bronze | `TASTY_BYTES.BRONZE` | View            | Thin wrappers over raw source tables |
| Silver | `TASTY_BYTES.SILVER` | Incremental     | Cleaned, enriched, joined datasets   |
| Gold   | `TASTY_BYTES.GOLD`   | Incremental     | Business-level aggregates for BI     |

---

## Data Sources

- **`TASTY_BYTES.RAW_POS`** — Point-of-sale data: orders, trucks, menus, locations, franchises (loaded from S3)
- **`FROSTBYTE_WEATHERSOURCE.ONPOINT_ID`** — Daily weather observations and postal codes (Snowflake Marketplace)

---

## Models

**Bronze (9 views):** `bronze_order_header`, `bronze_order_detail`, `bronze_menu`, `bronze_truck`, `bronze_franchise`, `bronze_location`, `bronze_country`, `bronze_weather_history`, `bronze_postal_codes`

**Silver (2 incremental tables):**
- `silver_orders` — Full enriched order grain (orders + trucks + menus + locations)
- `silver_daily_weather` — Daily weather per city joined with country and city references

**Gold (2 incremental tables):**
- `gold_daily_sales_hamburg` — Daily Hamburg sales joined with local weather (the primary output)
- `gold_daily_city_metrics` — Daily sales aggregated across all cities

---

## Macros

- `fahrenheit_to_celsius(temp_f)` — Inline SQL temperature conversion
- `inch_to_millimeter(inch)` — Inline SQL precipitation conversion
- `generate_schema_name` — Routes each layer to its correct Snowflake schema (BRONZE / SILVER / GOLD)

---

## Key Finding

Querying `gold_daily_sales_hamburg` against Hamburg weather data reveals that the truck operates in a city with consistently high wind speeds throughout the year. Wind speeds regularly exceed 40 mph and spike above 60 mph. These conditions explain the truck's underperformance — the pipeline surfaces this by joining daily sales with weather observations at the city level.

---

## How to Run

### Prerequisites
- Snowflake account with `TASTY_BYTES` database and `FROSTBYTE_WEATHERSOURCE` Marketplace data
- dbt-snowflake installed: `pip install dbt-snowflake`
- RSA key pair configured for authentication (see `profiles.yml`)

### 1. One-time Snowflake setup
Run `analyses/setup_snowflake.sql` in Snowsight to create schemas, warehouse, S3 stage, and load raw data.

### 2. Configure connection
Edit `tasty_bytes_dbt/profiles.yml` with your Snowflake account, user, and private key path.

### 3. Verify connection
```bash
cd tasty_bytes_dbt
dbt debug
```

### 4. Build all models
```bash
dbt run
```

### 5. Run tests
```bash
dbt test
```

### 6. Generate and view documentation
```bash
dbt docs generate && dbt docs serve
```

### 7. Deploy Streamlit dashboard
```bash
cd ..
snow streamlit deploy --replace --connection tasty_bytes
```

Open Snowsight → Streamlit → **Hamburg Weather & Sales** to view the interactive dashboard.

---

## Project Structure

```
Tasty-Bytes/
├── streamlit_app.py              # Streamlit dashboard (deployed to Snowflake)
├── snowflake.yml                 # Snowflake CLI project config
├── project_structure.md          # This file
└── tasty_bytes_dbt/
    ├── dbt_project.yml
    ├── profiles.yml              # Snowflake connection (gitignored)
    ├── analyses/
    │   └── setup_snowflake.sql   # One-time Snowflake setup script
    ├── macros/
    │   ├── fahrenheit_to_celsius.sql
    │   ├── inch_to_millimeter.sql
    │   └── generate_schema_name.sql
    ├── models/
    │   ├── bronze/               # 10 source views
    │   ├── silver/               # 3 incremental tables
    │   ├── gold/                 # 3 incremental tables
    │   └── docs/                 # schema.yml + doc blocks
    └── tests/                    # Custom data tests
```
