-- Q1 How long does delivery take on average? (start from customer purchase to customer receive)
--------------------------------------------------------------------------------------------------------------
-- Step 1: Check Outlier
--------------------------------------------------------------------------------------------------------------
-- CHECK MIN, MAX, AVG
WITH base_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS delivery_days
    FROM orders o
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT 
    MIN(delivery_days) AS min_days,
    MAX(delivery_days) AS max_days,
    AVG(delivery_days) AS avg_days
FROM base_orders;

--------------------------------------------------------------------------------------------------------------

-- Observe the delivery_days data
WITH base_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) AS delivery_days
    FROM orders o
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
)
SELECT 
	delivery_days
FROM base_orders
ORDER BY delivery_days;

--------------------------------------------------------------------------------------------------------------
-- Step 2: Create feature, Merge Table, Aggregation (delivery performance by customer state)
--------------------------------------------------------------------------------------------------------------
-- calculate delivery duration (in days) from purchase to customer delivery
WITH base_orders AS (
    SELECT
        order_id,
        customer_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        DATEDIFF(
            DAY,
            order_purchase_timestamp,
            order_delivered_customer_date
        ) AS delivery_days,
		YEAR(order_delivered_customer_date) AS deliver_year,
		MONTH(order_delivered_customer_date) AS deliver_month
    FROM orders
    WHERE order_status = 'delivered'
      AND order_purchase_timestamp IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
),

-- Enrich order data with customer state and city information
-- by joining the base orders with the customers table
orders_with_location AS (
    SELECT
        b.order_id,
        b.customer_id,
		deliver_year,
		deliver_month,
        b.delivery_days,
        c.customer_city,
        c.customer_state
    FROM base_orders b
    LEFT JOIN customers c
        ON b.customer_id = c.customer_id
),

-- Create a p99_delivery_days to prepared to remove to 1% extreme high delivery_days value
orders_with_location_percentile AS (
	SELECT
		*,
		PERCENTILE_CONT(0.99)
			WITHIN GROUP (ORDER BY delivery_days)
			OVER () AS p99_delivery_days
	FROM orders_with_location
),

-- Aggregate delivery performance by customer state ***
-- to analyze total orders and average delivery time per region
customer_state_level_aggregation AS (
	SELECT
		customer_state,
		deliver_year,
		deliver_month,
		COUNT(order_id) AS total_orders,
		AVG(CAST(CASE WHEN delivery_days < p99_delivery_days THEN delivery_days END AS FLOAT)) AS avg_delivery_days
	FROM orders_with_location_percentile
	GROUP BY customer_state, deliver_year, deliver_month
	HAVING COUNT(order_id) >= 100
)
SELECT *
FROM customer_state_level_aggregation
ORDER BY avg_delivery_days DESC;


