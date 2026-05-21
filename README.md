# Tasty Bytes — dbt + Snowflake Data Engineering Pipeline

A production-grade data pipeline that investigates why a food truck in Hamburg, Germany underperforms. Built with dbt, Snowflake, and Streamlit.

**Finding:** Hamburg experiences consistently high wind speeds (40–67 mph). Customers don't go out in those conditions — wind is the root cause of the truck's low sales.

---

## Dashboard

![Hamburg Weather & Sales Dashboard](assets/streamlit_dashboard.png)

The Streamlit dashboard (deployed inside Snowflake) overlays daily sales with temperature, precipitation, and wind speed. Switch between months using the year/month picker to explore seasonal patterns.

---

## Architecture

```
S3 (Tasty Bytes orders)      Snowflake Marketplace (Weather)
         │                              │
         ▼                              ▼
   RAW_POS / RAW_CUSTOMER     FROSTBYTE_WEATHERSOURCE
         │                              │
         └──────────┬───────────────────┘
                    ▼
             Bronze  (views)       ← source wrappers
             Silver  (incremental) ← cleaned & joined
             Gold    (incremental) ← business aggregates
                    │
                    ▼
          Streamlit in Snowflake
```

| Layer  | Schema               | Materialization |
|--------|----------------------|-----------------|
| Bronze | `TASTY_BYTES.BRONZE` | View            |
| Silver | `TASTY_BYTES.SILVER` | Incremental     |
| Gold   | `TASTY_BYTES.GOLD`   | Incremental     |

---

## Key Models

| Model | Description |
|---|---|
| `gold_daily_sales_hamburg` | Daily Hamburg sales joined with local weather — primary output |
| `gold_daily_city_metrics` | Daily sales aggregated across all cities |

---

## Quick Start

```bash
# 1. Install dbt
pip install dbt-snowflake

# 2. Configure Snowflake connection
# Edit tasty_bytes_dbt/profiles.yml with your account + RSA key

# 3. Verify connection
cd tasty_bytes_dbt && dbt debug

# 4. Build all models
dbt run

# 5. Run data quality tests
dbt test

# 6. Open data catalog
dbt docs generate && dbt docs serve

# 7. Deploy Streamlit dashboard
cd .. && snow streamlit deploy --replace --connection tasty_bytes
```

> See [tasty_bytes_dbt/GUIDE.md](tasty_bytes_dbt/GUIDE.md) for the full step-by-step guide including Snowflake setup, CI/CD, and Snowpipe.

---

## Data Coverage Notes

**Order data (S3 subset):** Only 3 cities are loaded for demonstration purposes — **Boston, Cairo, and Mumbai**. All other cities in `gold_daily_city_metrics` will show zero sales. The full production dataset covers all 450 trucks globally.

**Weather data (Frostbyte Marketplace):** The weather dataset covers 22 cities but does not include Cairo. As a result, Cairo's order data has no matching weather records and is absent from `gold_daily_city_metrics`. This is a gap in the third-party dataset, not a pipeline bug.

**Does the Cairo gap affect the Hamburg analysis?** No. Hamburg is fully covered by the Frostbyte weather dataset. The primary output — `gold_daily_sales_hamburg` — joins Hamburg sales with Hamburg weather and is unaffected by Cairo's missing data.

---

## CI/CD

GitHub Actions runs automatically on every push to `main`:

| Trigger | Job | Action |
|---|---|---|
| Pull request | CI | Compile + test changed models in isolated schema |
| Merge to `main` | CD | Full `dbt run` + `dbt test` to `DBT_PROD` |
| Daily 02:00 UTC | Scheduled refresh | Keeps gold tables current |

Credentials are stored as encrypted GitHub Secrets — never in the repo.

---

## Tech Stack

- **Snowflake** — cloud data warehouse + Marketplace weather data
- **dbt** — transformation layer (bronze → silver → gold)
- **Streamlit in Snowflake** — interactive dashboard
- **GitHub Actions** — CI/CD + scheduled refresh
- **Snowflake CLI** — Streamlit deployment
