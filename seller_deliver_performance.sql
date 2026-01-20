-- Q2 Which sellers deliver fastest and slowest? (calculated how early the seller send to the carrier)

---------------------------------------------------------------------------------------------------
-- Step 1: Merge Table
---------------------------------------------------------------------------------------------------
SELECT
    a.order_id,
    a.seller_id,
	c.seller_zip_code_prefix,
	c.seller_city,
	c.seller_state,
    a.shipping_limit_date AS carrier_receive_due_date,
    b.order_delivered_carrier_date AS carrier_receive_date,
    DATEDIFF(DAY, b.order_delivered_carrier_date, a.shipping_limit_date) AS carrier_received_early_days
INTO #seller_deliver_date
FROM order_items a
LEFT JOIN orders b
    ON a.order_id = b.order_id
LEFT JOIN sellers c
    ON a.seller_id = c.seller_id
WHERE a.shipping_limit_date IS NOT NULL
  AND b.order_status = 'delivered'
  AND b.order_delivered_carrier_date IS NOT NULL;

---------------------------------------------------------------------------------------------------
-- Step 2: Remove Outlier
---------------------------------------------------------------------------------------------------
-- Check distribution of carrier_received_early_days
SELECT 
	MIN(carrier_received_early_days) AS MIN,
	MAX(carrier_received_early_days) AS MAX,
	AVG(carrier_received_early_days) AS AVG
FROM #seller_deliver_date
SELECT carrier_received_early_days
FROM #seller_deliver_date
ORDER BY carrier_received_early_days DESC;

-- create #seller_deliver_date_percentile table to label down all the p01_carrier_received_early_days and p99_carrier_received_early_days
SELECT
	*,
    PERCENTILE_CONT(0.01)
        WITHIN GROUP (ORDER BY carrier_received_early_days)
        OVER () AS p01_carrier_received_early_days,
    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY carrier_received_early_days)
        OVER () AS p99_carrier_received_early_days
INTO #seller_deliver_date_percentile
FROM #seller_deliver_date;

---------------------------------------------------------------------------------------------------
-- Step 3: Aggregation
---------------------------------------------------------------------------------------------------

-- Example: Seller-Level Aggregation (Fastest/Slowest Sellers) ***
-- Top 10 Fastest Seller
WITH fastest_seller_performance AS(
	SELECT
		seller_id,
		seller_zip_code_prefix,
		seller_city,
		seller_state,
		COUNT(order_id) AS total_orders,
		AVG(CAST(CASE WHEN carrier_received_early_days BETWEEN p01_carrier_received_early_days AND p99_carrier_received_early_days THEN carrier_received_early_days END AS float)) AS avg_carrier_received_early_days,
		SUM(CASE WHEN carrier_received_early_days > 0 THEN 1 ELSE 0 END) AS earliest_orders,
		SUM(CASE WHEN carrier_received_early_days < 0 THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN carrier_received_early_days > 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS early_rate,
		ROUND(SUM(CASE WHEN carrier_received_early_days < 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS late_rate
	FROM #seller_deliver_date_percentile
	GROUP BY seller_id, seller_zip_code_prefix, seller_city, seller_state
	HAVING COUNT(order_id) >= 100 -- At least total send more than 100 orders
)
SELECT TOP 10 *,
	RANK() OVER (ORDER BY avg_carrier_received_early_days DESC) AS fast_rank
FROM fastest_seller_performance
ORDER BY fast_rank ASC, avg_carrier_received_early_days DESC, late_rate ASC;

---------------------------------------------------------------------------------------------------
-- Top 10 Slowest Seller
WITH slowest_seller_performance  AS(
	SELECT
		seller_id,
		seller_zip_code_prefix,
		seller_city,
		seller_state,
		COUNT(order_id) AS total_orders,
		AVG(CAST(CASE WHEN carrier_received_early_days BETWEEN p01_carrier_received_early_days AND p99_carrier_received_early_days THEN carrier_received_early_days END AS float)) AS avg_carrier_received_early_days,
		SUM(CASE WHEN carrier_received_early_days > 0 THEN 1 ELSE 0 END) AS earliest_orders,
		SUM(CASE WHEN carrier_received_early_days < 0 THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN carrier_received_early_days > 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS early_rate,
		ROUND(SUM(CASE WHEN carrier_received_early_days < 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS late_rate
	FROM #seller_deliver_date_percentile
	GROUP BY seller_id, seller_zip_code_prefix, seller_city, seller_state
	HAVING COUNT(order_id) >= 100 -- At least total send more than 100 orders

)
SELECT TOP 10 *,
	RANK() OVER (ORDER BY avg_carrier_received_early_days ASC) AS slow_rank
FROM slowest_seller_performance
ORDER BY slow_rank ASC, avg_carrier_received_early_days ASC, late_rate ASC;


---------------------------------------------------------------------------------------------------
-- Extra: Others Aggreation Table
---------------------------------------------------------------------------------------------------
-- Example: Seller-State Aggregation (Region-Level)
WITH fastest_state_performance  AS(
	SELECT
		seller_state,
		COUNT(order_id) AS total_orders,
		AVG(CAST(CASE WHEN carrier_received_early_days BETWEEN p01_carrier_received_early_days AND p99_carrier_received_early_days THEN carrier_received_early_days END AS float)) AS avg_carrier_received_early_days,
		SUM(CASE WHEN carrier_received_early_days > 0 THEN 1 ELSE 0 END) AS earliest_orders,
		SUM(CASE WHEN carrier_received_early_days < 0 THEN 1 ELSE 0 END) AS late_orders,
		ROUND(SUM(CASE WHEN carrier_received_early_days > 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS early_rate,
		ROUND(SUM(CASE WHEN carrier_received_early_days < 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS late_rate
	FROM #seller_deliver_date_percentile
	GROUP BY seller_id, seller_state
	HAVING COUNT(order_id) >= 50
	
)
SELECT TOP 10 *,
	RANK() OVER (ORDER BY avg_carrier_received_early_days DESC) AS fast_rank
FROM fastest_state_performance
ORDER BY fast_rank ASC, avg_carrier_received_early_days DESC, late_rate ASC;




---------------------------------------------------------------------------------------------------
-- Example: Seller Trend Over Time (Monthly)
WITH fastest_month_year_performance  AS(
	SELECT
		seller_id,
		YEAR(carrier_receive_date) AS receive_year,
		MONTH(carrier_receive_date) AS receive_month,
		COUNT(order_id) AS total_orders,
		AVG(CAST(CASE WHEN carrier_received_early_days BETWEEN p01_carrier_received_early_days AND p99_carrier_received_early_days THEN carrier_received_early_days END AS float)) AS avg_carrier_received_early_days,
		ROUND(SUM(CASE WHEN carrier_received_early_days > 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS early_rate,
		ROUND(SUM(CASE WHEN carrier_received_early_days < 0 THEN 1.0 ELSE 0 END)/COUNT(order_id),3) AS late_rate
	FROM #seller_deliver_date_percentile
	GROUP BY seller_id, YEAR(carrier_receive_date), MONTH(carrier_receive_date)
	HAVING COUNT(order_id) >= 100
	
)
SELECT TOP 10 *,
	RANK() OVER (ORDER BY avg_carrier_received_early_days DESC) AS fast_rank
FROM fastest_month_year_performance
ORDER BY fast_rank ASC, avg_carrier_received_early_days DESC, late_rate ASC;


---------------------------------------------------------------------------------------------------
-- Step 4: drop temporary table (optional)
---------------------------------------------------------------------------------------------------
DROP TABLE #seller_deliver_date;
DROP TABLE #seller_deliver_date_percentile;


SELECT * FROM sellers



