"""
================================================================================
 Amazon Sales Analytics — Interactive Dashboard (Streamlit)
================================================================================
 A reusable, dataset-agnostic analytics dashboard.

 FEATURES
   • Upload any CSV (or use the bundled Amazon Sales dataset)
   • Auto-detects date, category, region, revenue, profit columns
   • KPI Cards · Revenue Trend · Category Analysis · Correlation Heatmap
   • Top Performers · Geographic Analysis · Dynamic Insights
   • Sidebar filters (date range, category, region, payment)
   • One-click export of filtered data + insights (CSV)

 RUN
   cd Python
   pip install -r Requirements.txt
   streamlit run Dashboard.py
================================================================================
"""

import io
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import streamlit as st
from pathlib import Path

# ------------------------------------------------------------------ Page setup
st.set_page_config(
    page_title="Amazon Sales Analytics",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded",
)

sns.set_style("whitegrid")
PALETTE = {"primary": "#FF9900", "secondary": "#146EB4", "dark": "#232F3E"}

# ------------------------------------------------------------------ Helpers
@st.cache_data
def load_default_data():
    path = Path(__file__).parent / "../Dataset/Cleaned_Data.csv"
    if path.exists():
        df = pd.read_csv(path, parse_dates=["order_date"])
    else:
        df = pd.DataFrame()
    return df


def detect_columns(df):
    """Auto-detect key columns so the dashboard works on ANY sales dataset."""
    cols = {k: None for k in ["date", "revenue", "profit", "category", "region", "payment"]}
    lower = {c: str(c).lower() for c in df.columns}

    for c in df.columns:
        lc = lower[c]
        if cols["date"] is None and ("date" in lc or "time" in lc):
            cols["date"] = c
        if cols["revenue"] is None and ("revenue" in lc or "sales" in lc or "amount" in lc):
            cols["revenue"] = c
        if cols["profit"] is None and "profit" in lc:
            cols["profit"] = c
        if cols["category"] is None and ("categor" in lc or "product" in lc):
            cols["category"] = c
        if cols["region"] is None and ("region" in lc or "country" in lc or "location" in lc):
            cols["region"] = c
        if cols["payment"] is None and "payment" in lc:
            cols["payment"] = c

    # Fallback: if no profit column, engineer one with a 30% assumed margin
    if cols["profit"] is None and cols["revenue"] is not None:
        df = df.copy()
        df["profit"] = pd.to_numeric(df[cols["revenue"]], errors="coerce") * 0.30
        cols["profit"] = "profit"
    return df, cols


def fmt_money(x):
    return f"${x:,.0f}"


def kpi_card(label, value, delta=None):
    st.markdown(
        f"""
        <div style="background:linear-gradient(135deg,#232F3E,#146EB4);padding:20px;
                    border-radius:12px;color:white;">
            <div style="font-size:13px;opacity:.85;">{label}</div>
            <div style="font-size:26px;font-weight:700;margin-top:6px;">{value}</div>
            <div style="font-size:12px;margin-top:4px;opacity:.9;">{delta or ''}</div>
        </div>""",
        unsafe_allow_html=True,
    )


# ------------------------------------------------------------------ Sidebar
st.sidebar.title("⚙️ Configuration")

uploaded = st.sidebar.file_uploader("📤 Upload your CSV", type=["csv"])
if uploaded is not None:
    df = pd.read_csv(uploaded)
    st.sidebar.success("Custom dataset loaded!")
else:
    df = load_default_data()
    if df.empty:
        st.error("No data found. Please upload a CSV or place Cleaned_Data.csv in ../Dataset/")
        st.stop()
    st.sidebar.info("Using bundled Amazon Sales dataset.")

df, cols = detect_columns(df)

# Ensure date dtype
date_col = cols["date"]
if date_col and date_col in df.columns:
    df[date_col] = pd.to_datetime(df[date_col], errors="coerce")
    df = df.dropna(subset=[date_col])

# ------------------------------------------------------------------ Filters
st.sidebar.markdown("---")
st.sidebar.subheader("🎛️ Filters")

# Date filter
min_d, max_d = df[date_col].min(), df[date_col].max() if date_col else (None, None)
date_range = st.sidebar.date_input(
    "Date Range",
    value=(min_d, max_d) if date_col else (pd.Timestamp("2022-01-01"), pd.Timestamp("2023-12-31")),
    min_value=min_d, max_value=max_d,
)
if date_col and len(date_range) == 2:
    df = df[(df[date_col] >= pd.to_datetime(date_range[0])) &
            (df[date_col] <= pd.to_datetime(date_range[1]))]

# Categorical filters
def multiselect_filter(col, label):
    if col and col in df.columns:
        opts = ["All"] + sorted(df[col].dropna().astype(str).unique().tolist())
        sel = st.sidebar.multiselect(label, opts, default=["All"])
        if "All" not in sel:
            return df[df[col].astype(str).isin(sel)]
    return df

for col, label in [(cols["category"], "Category"), (cols["region"], "Region"),
                   (cols["payment"], "Payment Method")]:
    df = multiselect_filter(col, label)

if df.empty:
    st.warning("No data matches the selected filters.")
    st.stop()

# ------------------------------------------------------------------ Header
st.title("📊 Amazon Sales Analytics Dashboard")
st.caption("End-to-end BI dashboard · Upload any dataset or use the bundled data")

# ------------------------------------------------------------------ KPI cards
rev_col = cols["revenue"] or "total_revenue"
prof_col = cols["profit"]
rev = pd.to_numeric(df[rev_col], errors="coerce").sum()
profit = pd.to_numeric(df[prof_col], errors="coerce").sum() if prof_col else rev * 0.3
orders = len(df)
margin = (profit / rev * 100) if rev else 0
aov = (rev / orders) if orders else 0

c1, c2, c3, c4, c5 = st.columns(5)
with c1: kpi_card("Total Revenue", fmt_money(rev))
with c2: kpi_card("Total Profit", fmt_money(profit))
with c3: kpi_card("Orders", f"{orders:,}")
with c4: kpi_card("Profit Margin", f"{margin:.1f}%")
with c5: kpi_card("Avg Order Value", fmt_money(aov))

st.markdown("---")

# ------------------------------------------------------------------ Charts
left, right = st.columns(2)

with left:
    st.subheader("📈 Revenue Trend")
    if date_col:
        t = df.groupby(df[date_col].dt.to_period("M").astype(str))[rev_col].sum().reset_index()
        t.columns = ["Month", "Revenue"]
        st.line_chart(t.set_index("Month"))
    else:
        st.info("No date column detected.")

with right:
    st.subheader("🧩 Category Analysis")
    if cols["category"]:
        c = df.groupby(cols["category"])[rev_col].sum().sort_values(ascending=False)
        st.bar_chart(c)
    else:
        st.info("No category column detected.")

# Correlation heatmap
st.subheader("🔥 Correlation Heatmap")
num_df = df.select_dtypes(include=[np.number])
if num_df.shape[1] >= 2:
    fig, ax = plt.subplots(figsize=(11, 5))
    sns.heatmap(num_df.corr(), annot=True, fmt=".2f", cmap="coolwarm", center=0, ax=ax)
    st.pyplot(fig)
else:
    st.info("Not enough numeric columns for correlation.")

cA, cB = st.columns(2)
with cA:
    st.subheader("🏆 Top 10 Products by Revenue")
    if "product_id" in df.columns:
        top = (df.groupby("product_id")[rev_col].sum().nlargest(10).reset_index())
        st.dataframe(top.style.format({rev_col: fmt_money}), use_container_width=True)
    else:
        st.info("No product_id column.")

with cB:
    st.subheader("🌍 Geographic Analysis")
    if cols["region"]:
        g = (df.groupby(cols["region"])
               .agg(Revenue=(rev_col, "sum"), Orders=(rev_col, "size"))
               .sort_values("Revenue", ascending=False))
        st.dataframe(g.style.format({"Revenue": fmt_money}), use_container_width=True)
        st.bar_chart(g["Revenue"])
    else:
        st.info("No region column detected.")

# ------------------------------------------------------------------ Dynamic insights
st.markdown("---")
st.subheader("💡 Dynamic Insights")
insights = []
if cols["category"]:
    top_cat = df.groupby(cols["category"])[rev_col].sum().idxmax()
    insights.append(f"**Top category:** {top_cat} generates the highest revenue.")
if cols["region"]:
    top_reg = df.groupby(cols["region"])[rev_col].sum().idxmax()
    insights.append(f"**Top region:** {top_reg} leads in revenue.")
if date_col:
    best_month = df.groupby(df[date_col].dt.to_period("M").astype(str))[rev_col].sum().idxmax()
    insights.append(f"**Best month:** {best_month} recorded peak revenue.")
insights.append(f"**Profitability:** Overall margin is **{margin:.1f}%** — AOV is {fmt_money(aov)}.")
insights.append(f"**Order volume:** {orders:,} orders in the current filter.")
for i in insights:
    st.markdown(f"- {i}")

# ------------------------------------------------------------------ Export
st.markdown("---")
col1, col2 = st.columns(2)
with col1:
    csv = df.to_csv(index=False).encode()
    st.download_button("⬇️ Download Filtered Data (CSV)", csv,
                       "filtered_data.csv", "text/csv")
with col2:
    insights_df = pd.DataFrame({"Insight": insights})
    st.download_button("⬇️ Download Insights (CSV)",
                       insights_df.to_csv(index=False).encode(),
                       "insights.csv", "text/csv")

st.caption("Built with Streamlit · Part of the Universal Data Analytics Project")
