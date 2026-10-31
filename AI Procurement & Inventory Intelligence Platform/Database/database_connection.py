import psycopg2
import pandas as pd
import numpy as np


# 1. Connect to PostgreSQL

connection = psycopg2.connect(
    host="localhost",
    database="ai_procurement_db",
    user="postgres",
    password="Comp@174",
    port="5432"
)

print("Database connected successfully!")


# 2. Load Products

df_products = pd.read_sql(
    "SELECT * FROM products;",
    connection
)

print("\nProducts loaded successfully")
print("Products shape:", df_products.shape)


# --------------------------------------------------
# 3. Load Inventory
# --------------------------------------------------

df_inventory = pd.read_sql(
    "SELECT * FROM inventory;",
    connection
)

print("\nInventory loaded successfully")
print("Inventory shape:", df_inventory.shape)

print("\nInventory columns:")
print(df_inventory.columns.tolist())


# --------------------------------------------------
# 4. Select the columns we actually need
# --------------------------------------------------

inventory_columns = [
    "product_id",
    "current_stock",
    "reserved_stock",
    "available_stock"
]

# Add reorder_level only if it exists
if "reorder_level" in df_inventory.columns:
    inventory_columns.append("reorder_level")
else:
    print("\nWARNING: reorder_level was not found in inventory table.")


df_inventory = df_inventory[inventory_columns]


# --------------------------------------------------
# 5. Merge Products + Inventory
# --------------------------------------------------

df_product_inventory = pd.merge(
    df_products,
    df_inventory,
    on="product_id",
    how="inner"
)

print("\nMerged DataFrame created successfully!")
print("Merged shape:", df_product_inventory.shape)

print("\nMerged columns:")
print(df_product_inventory.columns.tolist())


# --------------------------------------------------
# 6. Convert stock columns to numeric
# --------------------------------------------------

stock_columns = [
    "current_stock",
    "reserved_stock",
    "available_stock"
]

for column in stock_columns:
    df_product_inventory[column] = pd.to_numeric(
        df_product_inventory[column],
        errors="coerce"
    )


# --------------------------------------------------
# 7. Create reorder_level if it does not exist
# --------------------------------------------------

if "reorder_level" not in df_product_inventory.columns:

    print("\nreorder_level not found.")
    print("Creating reorder_level using available stock data.")

    # Temporary business rule for our project
    df_product_inventory["reorder_level"] = (
        df_product_inventory["available_stock"] * 0.30
    )


# Make sure reorder_level is numeric
df_product_inventory["reorder_level"] = pd.to_numeric(
    df_product_inventory["reorder_level"],
    errors="coerce"
)


# --------------------------------------------------
# 8. Create Stock Status
# --------------------------------------------------

df_product_inventory["stock_status"] = np.where(
    df_product_inventory["available_stock"]
    <= df_product_inventory["reorder_level"],

    "Procurement Required",

    np.where(
        df_product_inventory["available_stock"]
        <= df_product_inventory["reorder_level"] * 1.5,

        "Reorder Soon",

        "Healthy"
    )
)


# --------------------------------------------------
# 9. Display final result
# --------------------------------------------------

print("\n========== STOCK STATUS ==========")

print(
    df_product_inventory[
        [
            "product_name",
            "available_stock",
            "reorder_level",
            "stock_status"
        ]
    ]
)


# --------------------------------------------------
# 10. Stock Status Summary
# --------------------------------------------------

print("\n========== STOCK STATUS SUMMARY ==========")

print(
    df_product_inventory["stock_status"].value_counts()
)
# --------------------------------------------------
# Stock Status Summary
# --------------------------------------------------

print("\n========== STOCK STATUS SUMMARY ==========")

stock_summary = (
    df_product_inventory["stock_status"]
    .value_counts()
    .reset_index()
)

stock_summary.columns = [
    "stock_status",
    "product_count"
]

# Calculate percentage
stock_summary["percentage"] = (
    stock_summary["product_count"]
    / stock_summary["product_count"].sum()
    * 100
)

# Round percentage to 2 decimal places
stock_summary["percentage"] = stock_summary["percentage"].round(2)

print(stock_summary)

