# Olist_Brazil_Ecommerce_Delivery_Performance_Analysis

## 📌 Project Overview
This project analyzes **Olist_Brazil_Ecommerce_Delivery_Performance_Analysis** to understand how delivery speed, seller behavior, and regional delays impact overall customer experience and satisfaction.

Using **SQL for data preparation** and **Power BI for visualization**, the project answers key business questions related to delivery efficiency and customer reviews.

---

## 🎯 Business Questions Addressed

### Q1. How long does delivery take on average?
- Measures delivery duration from **customer purchase to receive**
- Analyzes trends over time (monthly)
- Compares delivery performance across customer regions

### Q2. Which sellers deliver fastest and slowest?
- Evaluates how early sellers hand over orders to carriers
- Identifies **top 10 fastest and slowest sellers**
- Considers reliability using minimum order thresholds (Total Order must be more than 100)

### Q3. Which regions experience the most delivery delays?
- Calculates delay rate and average delay duration by region
- Highlights regions with frequent and severe delays

### Q4. Does slow delivery correlate with lower review scores?
- Compares delayed vs on-time deliveries
- Analyzes customer review score distribution
- Examines the impact of delivery delays on customer satisfaction

---

## 🛠 Tools & Technologies
- **SQL (T-SQL)** – Data cleaning, aggregation, percentile-based outlier handling
- **Power BI** – Interactive dashboards and data visualization

---

## 📊 Key Analytical Techniques
- Percentile filtering (p01–p99) to remove extreme outliers
- Minimum volume thresholds to ensure reliable comparisons (Seller Total Order must be more than 100)
- Aggregation at multiple levels:
  - Time (year, month)
  - Seller
  - Region (state)
- KPI-driven dashboard design
- Trend, distribution, and comparison analysis

---
## SQL Code Included

### order_delivery_performance.sql (Q1)
- Calculates delivery duration (delivery_days) from "order_purchase_timestamp" to "order_delivered_customer_date".
- Checks min, max, and average to detect outliers.
- Joins orders with customer location (city, state) for regional analysis.
- Applies 99th percentile (P99) to remove extreme delivery delays.
- Aggregates data by:
  - Customer state (year + month) → regional performance
  - Year and month → delivery trends over time
- Includes only groups with ≥100 orders for reliability.
- Removed "order_status" not equal to "delivered".
- Supports logistics evaluation, trend monitoring, and regional comparison.

### seller_deliver_performance.sql (Q2)
- Merges "order", "sellers", and "order_items" table to calculate how early sellers send orders to carriers (carrier_received_early_days).
- Performs basic checks (min, max, average) to detect outliers.
- Applies percentile filtering (p01–p99) to remove extreme "carrier_received_early_days" values.
- Aggregates data by:
  - Seller level → identify the 10 fastest and slowest sellers
  - Seller-state level → regional seller performance
  - Year-month level → seller trend over time
- Calculates metrics:
  - Average early days, earliest/late order counts, and early/late rates
- Filters out low-volume sellers (≥100 orders for reliability; ≥50 for regional aggregation).
- Optional cleanup: drops temporary tables to maintain a clean workspace.
- Supports logistics monitoring, seller ranking, and operational improvement insights.

### delay_report.sql (Q3)
- Merges "orders" and "customers" tables to calculate "delay_days" for each state.
- Creates is_delay flag: 1 → delayed, 0 → on-time.
- Performs basic checks (min, max, average) and applies percentile filtering (p01–p99) to remove extreme "delay_days" values.
- Aggregates data by:
  - State level → identify regions with the highest delay rates
  - City level → top cities with frequent delays
  - Time level (month-year) → track delay trends over time
- Calculates metrics:
  - Total orders, total delayed orders, delay rate, and average delay days
- Filters out groups with <100 total orders for statistical reliability.
- Supports regional logistics monitoring, operational improvement, and trend analysis.

### review_score_performance_when_delay.sql (Q4)
- Creates a view combining "order_reviews" with "orders".
- Calculates delivery delay (delay_days) and flags delayed orders (is_delay = 1 → delayed, 0 → on-time).
- Aggregates data by delay status, year, and month to analyze the impact on customer satisfaction.
  - Metrics calculated:
  - Total orders and average delay days
  - Average review score
- Count and percentage of each review score (1–5)
- Supports analysis of whether slower deliveries correlate with lower review scores, helping link operational performance to customer satisfaction.

---

## 📈 Dashboards Included

### 1️⃣ State Delivery Performance Overview (Q1)
- Average delivery time
- Monthly delivery trends
- State-level delivery comparison

### 2️⃣ Seller Delivery Performance (Q2)
- Top 10 fastest and slowest sellers
- Early vs late delivery rates
- Comparison between seller speed and late delivery rate
- Seller reliability analysis

### 3️⃣ Regional Delivery Delay Analysis (Q3)
- Delay rate by region
- Delay severity vs frequency
- Monthly delay trends

### 4️⃣ Delivery Delay vs Customer Reviews (Q4)
- Review score comparison (delayed vs on-time)
- Review score distribution
- Customer satisfaction impact analysis

### 📄 Dashboards (PDF):  
👉 [Download / View PDF](Olist_Brazil_Ecommerce_Delivery_Performance_Dashboard.pdf)

---

## 🔍 Key Insights
- BA state shows the strongest overall delivery performance with an average delivery time of 17.5 days, followed by GO state (16.9 days) and SC state (14.2 days), indicating comparatively faster deliveries than other states.
- Among the top 10 best-performing sellers (Avg Early Days Between 8.7 - 6.7), 4 sellers are from SP, 3 from PR, 3 from RS, and 1 from RJ, suggesting that high-performing sellers are concentrated in a few key states.
- In contrast, the top 10 worst-performing sellers (Avg Early Days Between 1.32 - "-0.01") are dominated by SP state (8 sellers), with the remaining 2 sellers from RJ and PR, indicating performance inconsistency within the same regions.
- CE state has the highest delivery delay rate at 38%, which is significantly higher compared to the second-highest state, ES (13%), highlighting CE as a critical region requiring operational improvement.
- Orders with delivery delays show a strong concentration of 1-star reviews (52.93%), while on-time deliveries receive a much higher proportion of 5-star reviews (63.18%). This pattern suggests that delivery delays are likely a key factor contributing to lower customer satisfaction.
