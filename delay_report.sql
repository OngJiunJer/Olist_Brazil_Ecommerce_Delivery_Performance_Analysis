-- Q3 Which regions experience the most delivery delays?

--------------------------------------------------------------------------------------------------------------
-- Step 1: Merge Table
--------------------------------------------------------------------------------------------------------------
-- delay_days: delay_days <= 0 → On time, delay_days > 0 → Delayed
SELECT
    o.customer_id,
    c.customer_city,
    c.customer_state,
    o.order_delivered_customer_date AS customer_received_date,
    o.order_estimated_delivery_date AS customer_estimated_receive_date,
	DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delay_days,
	YEAR(order_delivered_customer_date) AS deliver_year,
	MONTH(order_delivered_customer_date) AS deliver_month
INTO #customer_delivery_dates
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE
    c.customer_city IS NOT NULL
	AND o.order_status = 'delivered'
    AND c.customer_state IS NOT NULL
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL;

--------------------------------------------------------------------------------------------------------------
-- Step 2: create is_delay: is_delay == 1 → delayed, is_delay == 0 → not delayed
--------------------------------------------------------------------------------------------------------------
ALTER TABLE #customer_delivery_dates 
ADD is_delay INT; 
GO

UPDATE #customer_delivery_dates
SET is_delay = CASE
    WHEN delay_days > 0 THEN 1
    ELSE 0
END;
	
SELECT * FROM #customer_delivery_dates;

--------------------------------------------------------------------------------------------------------------
-- Step 3: Remove Outlier
--------------------------------------------------------------------------------------------------------------
-- Check distribution of carrier_received_early_days
SELECT 
	MIN(delay_days) AS MIN,
	MAX(delay_days) AS MAX,
	AVG(delay_days) AS AVG
FROM #customer_delivery_dates

SELECT delay_days
FROM #customer_delivery_dates
ORDER BY delay_days DESC;

-- create #seller_deliver_date_percentile table to label down all the p01_delay_days and p99_delay_days
SELECT
	*,
    PERCENTILE_CONT(0.01)
        WITHIN GROUP (ORDER BY delay_days)
        OVER () AS p01_delay_days,
    PERCENTILE_CONT(0.99)
        WITHIN GROUP (ORDER BY delay_days)
        OVER () AS p99_delay_days
INTO #customer_delivery_dates_percentile
FROM #customer_delivery_dates;


--------------------------------------------------------------------------------------------------------------
-- Step 4: Aggregation 
--------------------------------------------------------------------------------------------------------------

-- Region-Level Aggregation (State) ***
WITH region_level_aggregation AS(
	SELECT
		customer_state,
		deliver_year,
		deliver_month,
		COUNT(*) AS total_orders,
		SUM(is_delay) AS total_delayed_orders,
		ROUND(SUM(is_delay)*1.0/COUNT(*), 3) AS delay_rate,
		AVG(CAST(CASE WHEN delay_days BETWEEN p01_delay_days AND p99_delay_days AND delay_days > 0 THEN delay_days END AS FLOAT)) AS avg_delay_days
	FROM #customer_delivery_dates_percentile
	GROUP BY customer_state, deliver_year, deliver_month
	HAVING COUNT(*) >= 100
)
SELECT *
FROM region_level_aggregation
ORDER BY delay_rate DESC;  -- Descending: slowest states first

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- City-Level Aggregation (City)
WITH city_level_aggregation AS(
	SELECT
		customer_city,
		COUNT(*) AS total_orders,
		SUM(is_delay) AS total_delayed_orders,
		ROUND(SUM(is_delay)*1.0/COUNT(*), 3) AS delay_rate,
		AVG(CAST(CASE WHEN delay_days BETWEEN p01_delay_days AND p99_delay_days AND delay_days > 0 THEN delay_days END AS FLOAT)) AS avg_delay_days
	FROM #customer_delivery_dates_percentile
	GROUP BY customer_city
	HAVING COUNT(*) > 100
)
SELECT TOP 10 *
FROM city_level_aggregation
ORDER BY delay_rate DESC;  -- Descending: slowest city first



--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

--Trend Over Time (Month-Year)
WITH time_level_aggregation AS(
	SELECT
		customer_state,
		YEAR(customer_received_date) AS receive_year,
		MONTH(customer_received_date) AS receive_month,
		COUNT(*) AS total_orders,
		SUM(is_delay) AS total_delayed_orders,
		ROUND(SUM(is_delay)*1.0/COUNT(*), 3) AS delay_rate,
		AVG(CAST(CASE WHEN delay_days BETWEEN p01_delay_days AND p99_delay_days AND delay_days > 0 THEN delay_days END AS FLOAT)) AS avg_delay_days
	FROM #customer_delivery_dates_percentile
	GROUP BY customer_state, YEAR(customer_received_date), MONTH(customer_received_date)
	HAVING COUNT(*) > 100
)
SELECT Top 10 *
FROM time_level_aggregation
ORDER BY delay_rate DESC -- slowest month and year in state

