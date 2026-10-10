# RETAIL SALES ANALYTICS - STREAMLIT APPLICATION

import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestRegressor

# 1. PAGE SETUP

st.set_page_config(
    page_title="Retail Sales Analytics",
    layout="wide"
    )

st.title("Retail Sales Analytics")
st.write("Interactive Retail Sales Dashboard")

# 2. LOAD CLEANED DATA

sales = pd.read_csv("data/sales.csv")
skus = pd.read_csv("data/skus.csv")
stores = pd.read_csv("data/stores.csv")
customers = pd.read_csv("data/customers.csv")
inventory = pd.read_csv("data/inventory.csv")
promotions = pd.read_csv("data/promotions.csv")

# 3. DATA PREPARATION

# Convert all column names to lowercase
for df in [sales, skus, stores, customers, inventory, promotions]:
    df.columns = df.columns.str.lower()

# Convert sales date to datetime
sales["date"] = pd.to_datetime(sales["date"])

# Merge product information with sales
sales_analysis = sales.merge(
    skus[["sku_id", "sku_name", "category"]], on="sku_id", how="left"
)

# Merge store information with sales
sales_analysis = sales_analysis.merge(
    stores[["store_id", "store_name", "city"]], on="store_id", how="left"
)

# Merge customer information with sales
sales_analysis = sales_analysis.merge(
    customers[["cust_id", "loyalty_segment"]],left_on="customer_id",right_on="cust_id",how="left"
)

# 4. SIDEBAR FILTERS

st.sidebar.header("Filters")

selected_category = st.sidebar.multiselect(
    "Select Category",
    options=sorted(sales_analysis["category"].dropna().unique()
    )
)

selected_store = st.sidebar.multiselect(
    "Select Store",
    options=sorted(sales_analysis["store_name"].dropna().unique()
    )
)

selected_channel = st.sidebar.multiselect(
    "Select Channel",
    options=sorted(sales_analysis["channel"].dropna().unique()
    )
)

# 5. APPLY FILTERS

filtered_data = sales_analysis.copy()

if selected_category:
    filtered_data = filtered_data[
        filtered_data["category"].isin(selected_category)
    ]

if selected_store:
    filtered_data = filtered_data[
        filtered_data["store_name"].isin(selected_store)
    ]

if selected_channel:
    filtered_data = filtered_data[
        filtered_data["channel"].isin(selected_channel)
    ]

# 6. SALES KPIs

total_sales = filtered_data["total_value"].sum()

units_sold = filtered_data["quantity"].sum()

sales_records = len(filtered_data)

avg_sales_value = filtered_data["total_value"].mean()


st.subheader("Sales Overview")

col1, col2, col3, col4 = st.columns(4)

col1.metric(
    "Total Sales",
    f"AED {total_sales:,.2f}"
)

col2.metric(
    "Units Sold",
    f"{units_sold:,.0f}"
)

col3.metric(
    "Sales Records",
    f"{sales_records:,}"
)

col4.metric(
    "Average Sales Value",
    f"AED {avg_sales_value:,.2f}"
)

# 7. SALES ANALYSIS

st.subheader("Sales Analysis")

chart1, chart2 = st.columns(2)

# Sales by Category

category_sales = (
    filtered_data
    .groupby("category")["total_value"]
    .sum()
    .sort_values(ascending=False)
)

with chart1:

    fig, ax = plt.subplots()

    category_sales.plot(
        kind="bar",
        ax=ax
    )

    ax.set_title("Sales by Category")
    ax.set_xlabel("Category")
    ax.set_ylabel("Total Sales (AED)")

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# Sales by Channel

channel_sales = (
    filtered_data
    .groupby("channel")["total_value"]
    .sum()
    .sort_values(ascending=False)
)

with chart2:

    fig, ax = plt.subplots()

    channel_sales.plot(
        kind="bar",
        ax=ax
    )

    ax.set_title("Sales by Channel")
    ax.set_xlabel("Channel")
    ax.set_ylabel("Total Sales (AED)")

    plt.xticks(
        rotation=45,
        ha="right"
    )

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# 8. SALES TREND & PRODUCT PERFORMANCE

chart3, chart4 = st.columns(2)

# Monthly Sales Trend

monthly_data = filtered_data.copy()

monthly_data["year_month"] = (
    monthly_data["date"]
    .dt.to_period("M")
)

monthly_sales = (
    monthly_data
    .groupby("year_month")["total_value"]
    .sum()
)

with chart3:

    fig, ax = plt.subplots()

    monthly_sales.plot(
        kind="line",
        ax=ax
    )

    ax.set_title("Monthly Sales Trend")
    ax.set_xlabel("Month")
    ax.set_ylabel("Total Sales (AED)")

    plt.xticks(rotation=45)

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# Top 10 Products

top_products = (
    filtered_data
    .groupby("sku_name")["total_value"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

with chart4:

    fig, ax = plt.subplots()

    top_products.sort_values().plot(
        kind="barh",
        ax=ax
    )

    ax.set_title("Top 10 Products by Sales")
    ax.set_xlabel("Total Sales (AED)")
    ax.set_ylabel("Product")

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# 9. CUSTOMER & DISCOUNT ANALYSIS

st.subheader("Customer & Discount Analysis")

chart5, chart6 = st.columns(2)

# Sales by Loyalty Segment

loyalty_sales = (
    filtered_data
    .dropna(subset=["loyalty_segment"])
    .groupby("loyalty_segment")["total_value"]
    .sum()
    .sort_values(ascending=False)
)

with chart5:

    fig, ax = plt.subplots()

    loyalty_sales.plot(
        kind="bar",
        ax=ax
    )

    ax.set_title("Sales by Loyalty Segment")
    ax.set_xlabel("Loyalty Segment")
    ax.set_ylabel("Total Sales (AED)")

    plt.xticks(rotation=0)

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# Discounted vs Non-Discounted

discount_sales = pd.Series({

    "Discounted":
        filtered_data.loc[
            filtered_data["discount_pct"] > 0,
            "total_value"
        ].sum(),

    "Non-Discounted":
        filtered_data.loc[
            filtered_data["discount_pct"] == 0,
            "total_value"
        ].sum()
})


with chart6:

    fig, ax = plt.subplots()

    discount_sales.plot(
        kind="bar",
        ax=ax
    )

    ax.set_title(
        "Discounted vs Non-Discounted Sales"
    )

    ax.set_xlabel(
        "Discount Status"
    )

    ax.set_ylabel(
        "Total Sales (AED)"
    )

    plt.xticks(rotation=0)

    plt.tight_layout()

    st.pyplot(fig)

    plt.close(fig)

# 10. DATASET INFORMATION

st.divider()

st.caption(
    "Retail sales data analysed for the period "
    "January 2021 to October 2025."
)

# 10. PRODUCT DEMAND PREDICTION

st.subheader("Product Demand Prediction")

st.write(
    "Estimate the expected quantity sold using a Random Forest Regression model."
)

prediction_col1, prediction_col2, prediction_col3 = st.columns(3)

with prediction_col1:
    prediction_store = st.selectbox(
        "Store",
        sorted(sales["store_id"].unique())
    )

with prediction_col2:
    prediction_sku = st.selectbox(
        "Product (SKU)",
        sorted(sales["sku_id"].unique())
    )

with prediction_col3:
    prediction_channel = st.selectbox(
        "Channel",
        sorted(sales["channel"].unique())
    )

prediction_col4, prediction_col5 = st.columns(2)

with prediction_col4:
    prediction_discount = st.number_input(
        "Discount Percentage",
        min_value=0.0,
        max_value=35.0,
        value=0.0,
        step=5.0
    )

with prediction_col5:
    prediction_date = st.date_input(
    "Sales Date",
    value=sales["date"].max().date(),
    min_value=sales["date"].min().date(),
    max_value=sales["date"].max().date()
)

# RANDOM FOREST MODEL

@st.cache_resource
def train_demand_model(sales_data):

    model_data = sales_data[
        ["date", "store_id", "sku_id", "channel",
         "discount_pct", "quantity"]
    ].copy()

    # Date features
    model_data["year"] = model_data["date"].dt.year
    model_data["month"] = model_data["date"].dt.month
    model_data["day_of_week"] = model_data["date"].dt.dayofweek

    model_data = model_data.drop("date", axis=1)

    # Separate features and target
    X = model_data.drop("quantity", axis=1)
    y = model_data["quantity"]

    # Convert categorical columns into dummy variables
    X = pd.get_dummies(
        X,
        columns=["store_id", "sku_id", "channel"],
        drop_first=True
    )

    # Train Random Forest
    model = RandomForestRegressor(
        n_estimators=50,
        max_depth=10,
        random_state=42,
        n_jobs=-1
    )

    model.fit(X, y)

    return model, X.columns


demand_model, model_columns = train_demand_model(sales)

if st.button("Predict Demand"):

    # Create one row using user inputs
    input_data = pd.DataFrame({
        "store_id": [prediction_store],
        "sku_id": [prediction_sku],
        "channel": [prediction_channel],
        "discount_pct": [prediction_discount],
        "year": [prediction_date.year],
        "month": [prediction_date.month],
        "day_of_week": [prediction_date.weekday()]
    })

    # Apply same encoding used during model training
    input_data = pd.get_dummies(
        input_data,
        columns=["store_id", "sku_id", "channel"]
    )

    # Match model training columns
    input_data = input_data.reindex(
        columns=model_columns,
        fill_value=0
    )

    # Make prediction
    predicted_quantity = demand_model.predict(input_data)[0]

    st.success(
        f"Predicted Quantity Sold: {predicted_quantity:.2f} units"
    )