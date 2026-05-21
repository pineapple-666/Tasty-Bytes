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
| `gold_customer_loyalty_metrics` | Lifetime value and behaviour per loyalty customer |

---

## Quick Start

```bash
# 1. Install dbt
pip install dbt-snowflake

# 2. Configure Snowflake connection
# Edit tasty_bytes_dbt/profiles.yml with your account + RSA key

# 3. Verify connection
cd tasty_bytes_dbt && dbt debug

# 4. Build all 16 models
dbt run

# 5. Run 25 data quality tests
dbt test

# 6. Open data catalog
dbt docs generate && dbt docs serve

# 7. Deploy Streamlit dashboard
cd .. && snow streamlit deploy --replace --connection tasty_bytes
```

> See [tasty_bytes_dbt/GUIDE.md](tasty_bytes_dbt/GUIDE.md) for the full step-by-step guide including Snowflake setup, CI/CD, and Snowpipe.

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
