import streamlit as st
import pandas as pd
import mysql.connector

# --- 1. DATABASE CONNECTION FUNCTION ---
def run_query(query):
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="root",
            password="Aditya@122", # Update this
            database="OLA_INSIGHTS_PROJECT"
        )
        df = pd.read_sql(query, conn)
        conn.close()
        return df
    except Exception as e:
        st.error(f"Error: {e}")
        return None

# --- 2. APP UI CONFIG ---
st.set_page_config(page_title="Ola Analytics", layout="wide")
st.title("🚖 Ola Ride Analysis Dashboard")
st.markdown("---")

# --- 3. SIDEBAR NAVIGATION ---
st.sidebar.header("Navigation")
option = st.sidebar.selectbox("Select SQL Insight", [
    "1. Successful Bookings",
    "2. Avg Distance per Vehicle",
    "3. Customer Cancellations",
    "4. Top 5 Customers",
    "5. Driver Cancellations (Issues)",
    "6. Prime Sedan Ratings",
    "7. UPI Payment Rides",
    "8. Avg Rating per Vehicle",
    "9. Total Successful Revenue",
    "10. Incomplete Rides & Reasons"
])

# --- 4. EXECUTION LOGIC FOR ALL 10 QUERIES ---

if option == "1. Successful Bookings":
    st.subheader("✅ Successful Bookings")
    count_df = run_query("SELECT count(*) as total FROM ola_rides WHERE Booking_Status = 'Success'")
    st.metric("Total Successful Rides", f"{count_df['total'][0]:,}")
    data = run_query("SELECT * FROM ola_rides WHERE Booking_Status = 'Success' LIMIT 1000")
    st.write("Preview of first 1000 records:")
    st.dataframe(data)

elif option == "2. Avg Distance per Vehicle":
    st.subheader("📏 Average Ride Distance by Vehicle Type")
    data = run_query("SELECT Vehicle_Type, ROUND(AVG(Ride_Distance), 2) AS avg_distance FROM ola_rides GROUP BY Vehicle_Type")
    st.bar_chart(data.set_index('Vehicle_Type'))
    st.table(data)

elif option == "3. Customer Cancellations":
    st.subheader("❌ Rides Cancelled by Customers")
    data = run_query("SELECT COUNT(*) as canceled_count FROM ola_rides WHERE Booking_Status = 'Canceled by Customer'")
    st.metric("Total Customer Cancellations", f"{data['canceled_count'][0]:,}")

elif option == "4. Top 5 Customers":
    st.subheader("🏆 Top 5 High-Value Customers")
    data = run_query("SELECT Customer_ID, COUNT(Booking_ID) as total_rides FROM ola_rides GROUP BY Customer_ID ORDER BY total_rides DESC LIMIT 5")
    st.table(data)

elif option == "5. Driver Cancellations (Issues)":
    st.subheader("🛠️ Driver Cancellations: Personal & Car Issues")
    # Note: Ensure column name matches exactly what's in your DB
    data = run_query("SELECT COUNT(*) as count FROM ola_rides WHERE Canceled_Rides_by_Driver = 'Personal & Car related issue'")
    st.metric("Total Cancellations", data['count'][0])

elif option == "6. Prime Sedan Ratings":
    st.subheader("⭐ Driver Ratings for Prime Sedan")
    data = run_query("SELECT MAX(Driver_Ratings) as max_r, MIN(Driver_Ratings) as min_r FROM ola_rides WHERE Vehicle_Type = 'Prime Sedan'")
    col1, col2 = st.columns(2)
    col1.metric("Maximum Rating", data['max_r'][0])
    col2.metric("Minimum Rating", data['min_r'][0])

elif option == "7. UPI Payment Rides":
    st.subheader("💳 Rides Paid via UPI")
    data = run_query("SELECT * FROM ola_rides WHERE Payment_Method = 'UPI' LIMIT 1000")
    total_upi = run_query("SELECT count(*) as total FROM ola_rides WHERE Payment_Method = 'UPI'")
    st.metric("Total UPI Transactions", f"{total_upi['total'][0]:,}")
    st.dataframe(data)

elif option == "8. Avg Rating per Vehicle":
    st.subheader("📊 Average Customer Rating by Vehicle Type")
    data = run_query("SELECT Vehicle_Type, AVG(Customer_Rating) as avg_rating FROM ola_rides GROUP BY Vehicle_Type")
    st.line_chart(data.set_index('Vehicle_Type'))
    st.dataframe(data)

elif option == "9. Total Successful Revenue":
    st.subheader("💰 Financial Summary")
    data = run_query("SELECT SUM(Booking_Value) as total_value FROM ola_rides WHERE Booking_Status = 'Success'")
    st.metric("Total Successful Revenue", f"₹{data['total_value'][0]:,.2f}")

elif option == "10. Incomplete Rides & Reasons":
    st.subheader("⚠️ Incomplete Rides Analysis")
    data = run_query("SELECT Booking_ID, Incomplete_Rides_Reason FROM ola_rides WHERE Incomplete_Rides = 'Yes'")
    st.write(f"Found {len(data)} incomplete rides.")
    st.dataframe(data)