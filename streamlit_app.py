import streamlit as st
import altair as alt
import pandas as pd
import calendar
from snowflake.snowpark.context import get_active_session
from snowflake.snowpark.functions import col

session = get_active_session()

st.title("Weather and Sales Trends for Hamburg, Germany")

# Month/year picker — data runs 2019-01 to 2022-11
col1, col2 = st.columns(2)
with col1:
    year = st.selectbox("Year", [2019, 2020, 2021, 2022], index=3)
with col2:
    max_month = 11 if year == 2022 else 12
    month = st.selectbox("Month", range(1, max_month + 1),
                         index=1,  # default February
                         format_func=lambda m: calendar.month_name[m])

start = f"{year}-{month:02d}-01"
end   = f"{year}-{month:02d}-{calendar.monthrange(year, month)[1]}"

df = session.table("TASTY_BYTES.GOLD.GOLD_DAILY_SALES_HAMBURG").select(
    col("DATE"),
    col("DAILY_SALES"),
    col("AVG_TEMPERATURE_FAHRENHEIT"),
    col("AVG_PRECIPITATION_INCHES"),
    col("MAX_WIND_SPEED_100M_MPH")
).filter((col("DATE") >= start) & (col("DATE") <= end)).to_pandas()

df_long = df.melt("DATE", var_name="Measure", value_name="Value")
df_long["Measure"] = df_long["Measure"].replace({
    "DAILY_SALES":              "Daily Sales ($)",
    "AVG_TEMPERATURE_FAHRENHEIT": "Avg Temperature (°F)",
    "AVG_PRECIPITATION_INCHES": "Avg Precipitation (in)",
    "MAX_WIND_SPEED_100M_MPH":  "Max Wind Speed (mph)"
})

chart = alt.Chart(df_long).mark_line(point=True).encode(
    x=alt.X("DATE:T", title="Date"),
    y=alt.Y("Value:Q", title="Values"),
    color=alt.Color("Measure:N", title="Legend", scale=alt.Scale(
        range=["#29B5E8", "#FF6F61", "#0072CE", "#FFC300"]
    )),
    tooltip=["DATE:T", "Measure:N", "Value:Q"]
).interactive().properties(
    width=700,
    height=400,
    title=f"Daily Sales, Temperature, Precipitation, and Wind Speed — {calendar.month_name[month]} {year}"
).configure_title(
    fontSize=20,
    font="Arial"
).configure_axis(
    grid=True
).configure_view(
    strokeWidth=0
)

st.altair_chart(chart, use_container_width=True)
