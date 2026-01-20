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

---

## 🔍 Key Insights
- BA state shows the strongest overall delivery performance with an average delivery time of 17.5 days, followed by GO state (16.9 days) and SC state (14.2 days), indicating comparatively faster deliveries than other states.
- Among the top 10 best-performing sellers (Avg Early Days Between 8.7 - 6.7), 4 sellers are from SP, 3 from PR, 3 from RS, and 1 from RJ, suggesting that high-performing sellers are concentrated in a few key states.
- In contrast, the top 10 worst-performing sellers (Avg Early Days Between 1.32 - "-0.01") are dominated by SP state (8 sellers), with the remaining 2 sellers from RJ and PR, indicating performance inconsistency within the same regions.
- CE state has the highest delivery delay rate at 38%, which is significantly higher compared to the second-highest state, ES (13%), highlighting CE as a critical region requiring operational improvement.
- Orders with delivery delays show a strong concentration of 1-star reviews (52.93%), while on-time deliveries receive a much higher proportion of 5-star reviews (63.18%). This pattern suggests that delivery delays are likely a key factor contributing to lower customer satisfaction.
