"""Streamlit Quantitative Analysis PoC — main entry point.

Run with:
    streamlit run app.py
"""

from __future__ import annotations

import io

import numpy as np
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

from utils import (
    compute_returns,
    compute_rolling_average,
    compute_z_scores,
    get_numeric_columns,
    get_sample_data,
    try_fetch_yfinance,
)

# ---------------------------------------------------------------------------
# Page configuration
# ---------------------------------------------------------------------------
st.set_page_config(
    page_title="Quant Analysis PoC",
    page_icon="📈",
    layout="wide",
)

st.title("📈 Quantitative Analysis PoC")
st.caption("Powered by Streamlit · pandas · Plotly")

# ---------------------------------------------------------------------------
# Sidebar — data source & parameters
# ---------------------------------------------------------------------------
with st.sidebar:
    st.header("⚙️ Settings")

    data_source = st.radio(
        "Data source",
        options=["Sample data", "Upload CSV", "Yahoo Finance"],
        index=0,
    )

    df_raw: pd.DataFrame | None = None

    if data_source == "Sample data":
        df_raw = get_sample_data()
        st.info("Using synthetic sample data (252 trading days, 5 tickers).")

    elif data_source == "Upload CSV":
        uploaded = st.file_uploader("Upload a CSV file", type=["csv"])
        if uploaded is not None:
            df_raw = pd.read_csv(uploaded)
            st.success(f"Loaded {len(df_raw):,} rows × {len(df_raw.columns)} columns.")
        else:
            st.warning("Please upload a CSV file to continue.")

    else:  # Yahoo Finance
        yf_tickers_input = st.text_input(
            "Tickers (comma-separated)", value="AAPL,MSFT,GOOGL"
        )
        yf_period = st.selectbox(
            "Period", options=["1mo", "3mo", "6mo", "1y", "2y", "5y"], index=3
        )
        if st.button("Fetch data"):
            tickers = [t.strip().upper() for t in yf_tickers_input.split(",") if t.strip()]
            with st.spinner("Fetching from Yahoo Finance…"):
                df_raw = try_fetch_yfinance(tickers, period=yf_period)
            if df_raw is None:
                st.error("Failed to fetch data. Check ticker symbols or network access.")
            else:
                st.success(f"Loaded {len(df_raw):,} rows × {len(df_raw.columns)} columns.")

    # ------------------------------------------------------------------
    # Filters & parameters (shown when data is available)
    # ------------------------------------------------------------------
    if df_raw is not None:
        st.divider()
        st.subheader("Filters")

        # Date column detection
        date_cols = [
            c for c in df_raw.columns if "date" in c.lower() or "time" in c.lower()
        ]
        date_col: str | None = date_cols[0] if date_cols else None

        if date_col:
            df_raw[date_col] = pd.to_datetime(df_raw[date_col], errors="coerce")
            min_date = df_raw[date_col].min()
            max_date = df_raw[date_col].max()
            if pd.notna(min_date) and pd.notna(max_date):
                date_range = st.date_input(
                    "Date range",
                    value=(min_date.date(), max_date.date()),
                    min_value=min_date.date(),
                    max_value=max_date.date(),
                )
                if len(date_range) == 2:
                    start, end = date_range
                    mask = (df_raw[date_col].dt.date >= start) & (
                        df_raw[date_col].dt.date <= end
                    )
                    df_raw = df_raw.loc[mask].reset_index(drop=True)

        numeric_cols = get_numeric_columns(df_raw)

        if numeric_cols:
            selected_cols = st.multiselect(
                "Numeric columns to analyze",
                options=numeric_cols,
                default=numeric_cols[:5],
            )
        else:
            selected_cols = []

        st.divider()
        st.subheader("Parameters")
        rolling_window = st.slider("Rolling window (days)", min_value=5, max_value=60, value=20)


# ---------------------------------------------------------------------------
# Main area — only rendered when data is loaded
# ---------------------------------------------------------------------------
if df_raw is None:
    st.info("👈 Select a data source in the sidebar to get started.")
    st.stop()

df = df_raw.copy()
numeric_cols = get_numeric_columns(df)
analysis_cols = selected_cols if selected_cols else numeric_cols[:5]

tab_data, tab_stats, tab_charts, tab_insights = st.tabs(
    ["📋 Data", "📊 Stats", "📉 Charts", "💡 Insights"]
)

# ---------------------------------------------------------------------------
# Tab 1 — Raw Data
# ---------------------------------------------------------------------------
with tab_data:
    st.subheader("Raw DataFrame")
    st.dataframe(df, width="stretch", height=400)

    col_left, col_right = st.columns(2)
    col_left.metric("Rows", f"{len(df):,}")
    col_right.metric("Columns", f"{len(df.columns):,}")

    csv_bytes = df.to_csv(index=False).encode()
    st.download_button(
        label="⬇️ Download as CSV",
        data=csv_bytes,
        file_name="data_export.csv",
        mime="text/csv",
    )

# ---------------------------------------------------------------------------
# Tab 2 — Summary Statistics
# ---------------------------------------------------------------------------
with tab_stats:
    st.subheader("Summary Statistics")

    if analysis_cols:
        desc = df[analysis_cols].describe().T
        st.dataframe(desc, width="stretch")

        st.subheader("Correlation Matrix")
        corr = df[analysis_cols].corr()
        fig_corr = px.imshow(
            corr,
            text_auto=".2f",
            color_continuous_scale="RdBu_r",
            zmin=-1,
            zmax=1,
            title="Pearson Correlation Heatmap",
        )
        fig_corr.update_layout(height=500)
        st.plotly_chart(fig_corr, width="stretch")
    else:
        st.warning("No numeric columns selected for analysis.")

# ---------------------------------------------------------------------------
# Tab 3 — Charts
# ---------------------------------------------------------------------------
with tab_charts:
    if not analysis_cols:
        st.warning("No numeric columns selected for analysis.")
    else:
        # ---- Time series ----
        date_col_chart = next(
            (c for c in df.columns if "date" in c.lower() or "time" in c.lower()), None
        )
        st.subheader("Time Series")
        if date_col_chart:
            fig_ts = px.line(
                df,
                x=date_col_chart,
                y=analysis_cols,
                title="Price / Value Over Time",
                labels={"value": "Value", "variable": "Series"},
            )
            fig_ts.update_layout(height=400, legend_title_text="Series")
            st.plotly_chart(fig_ts, width="stretch")
        else:
            fig_ts = px.line(
                df[analysis_cols].reset_index(),
                x="index",
                y=analysis_cols,
                title="Values (by row index)",
                labels={"value": "Value", "variable": "Series"},
            )
            fig_ts.update_layout(height=400)
            st.plotly_chart(fig_ts, width="stretch")

        # ---- Distribution plots ----
        st.subheader("Distributions")
        dist_col = st.selectbox("Select column for distribution", analysis_cols, key="dist_col")
        fig_hist = px.histogram(
            df,
            x=dist_col,
            nbins=50,
            marginal="box",
            title=f"Distribution of {dist_col}",
        )
        fig_hist.update_layout(height=400)
        st.plotly_chart(fig_hist, width="stretch")

        # ---- Rolling average overlay ----
        st.subheader(f"Rolling Average (window = {rolling_window})")
        roll_col = st.selectbox("Select column for rolling average", analysis_cols, key="roll_col")

        roll_series = df[roll_col].dropna()
        roll_avg = compute_rolling_average(roll_series, window=rolling_window)

        x_axis = (
            df.loc[roll_series.index, date_col_chart]
            if date_col_chart
            else roll_series.index
        )
        fig_roll = go.Figure()
        fig_roll.add_trace(
            go.Scatter(x=x_axis, y=roll_series.values, mode="lines", name=roll_col, opacity=0.5)
        )
        fig_roll.add_trace(
            go.Scatter(
                x=x_axis,
                y=roll_avg.values,
                mode="lines",
                name=f"MA({rolling_window})",
                line=dict(width=2),
            )
        )
        fig_roll.update_layout(
            title=f"{roll_col} with {rolling_window}-Day Rolling Average",
            xaxis_title="Date" if date_col_chart else "Index",
            yaxis_title="Value",
            height=400,
            legend_title_text="Series",
        )
        st.plotly_chart(fig_roll, width="stretch")

# ---------------------------------------------------------------------------
# Tab 4 — Insights (derived metrics)
# ---------------------------------------------------------------------------
with tab_insights:
    if not analysis_cols:
        st.warning("No numeric columns selected for analysis.")
    else:
        insight_col = st.selectbox(
            "Select column for derived metrics", analysis_cols, key="insight_col"
        )
        series = df[insight_col].dropna()

        date_col_ins = next(
            (c for c in df.columns if "date" in c.lower() or "time" in c.lower()), None
        )
        x_ins = df.loc[series.index, date_col_ins] if date_col_ins else series.index

        col1, col2 = st.columns(2)

        # ---- Returns ----
        with col1:
            st.subheader("Period Returns")
            returns = compute_returns(series)
            fig_ret = px.bar(
                x=x_ins.iloc[1:] if hasattr(x_ins, "iloc") else x_ins[1:],
                y=returns.values,
                title=f"Period-over-Period Returns — {insight_col}",
                labels={"x": "Date" if date_col_ins else "Index", "y": "Return"},
                color=returns.values,
                color_continuous_scale="RdYlGn",
            )
            fig_ret.update_layout(height=350, coloraxis_showscale=False)
            st.plotly_chart(fig_ret, width="stretch")

            # Annualised stats
            ann_return = returns.mean() * 252
            ann_vol = returns.std() * np.sqrt(252)
            sharpe = ann_return / ann_vol if ann_vol != 0 else np.nan
            m1, m2, m3 = st.columns(3)
            m1.metric("Ann. Return", f"{ann_return:.1%}")
            m2.metric("Ann. Volatility", f"{ann_vol:.1%}")
            m3.metric("Sharpe Ratio", f"{sharpe:.2f}")

        # ---- Z-scores ----
        with col2:
            st.subheader("Z-Scores")
            z_scores = compute_z_scores(series)
            fig_z = px.line(
                x=x_ins,
                y=z_scores.values,
                title=f"Z-Score — {insight_col}",
                labels={"x": "Date" if date_col_ins else "Index", "y": "Z-Score"},
            )
            fig_z.add_hline(y=2, line_dash="dash", line_color="red", annotation_text="+2σ")
            fig_z.add_hline(y=-2, line_dash="dash", line_color="blue", annotation_text="-2σ")
            fig_z.update_layout(height=350)
            st.plotly_chart(fig_z, width="stretch")

        # ---- Rolling statistics table ----
        st.subheader("Rolling Statistics Summary")
        roll_stats = pd.DataFrame(
            {
                "Price": series,
                f"MA({rolling_window})": compute_rolling_average(series, window=rolling_window),
                "Return (%)": compute_returns(series).reindex(series.index) * 100,
                "Z-Score": compute_z_scores(series),
            }
        )
        if date_col_ins:
            roll_stats.insert(0, "Date", df.loc[series.index, date_col_ins].values)
        st.dataframe(
            roll_stats.tail(60).style.format(
                {
                    "Price": "{:.2f}",
                    f"MA({rolling_window})": "{:.2f}",
                    "Return (%)": "{:.3f}",
                    "Z-Score": "{:.3f}",
                }
            ),
            width="stretch",
            height=300,
        )
