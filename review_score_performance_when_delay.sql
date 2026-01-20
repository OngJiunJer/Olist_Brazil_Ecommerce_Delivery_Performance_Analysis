-- Q4 Does slow delivery correlate with lower review scores?

---------------------------------------------------------------------------------------------------
-- Step 1: Create a view to calculate customer delivery delays and review scores
---------------------------------------------------------------------------------------------------
CREATE OR ALTER VIEW vw_customer_delivery_reviews AS
SELECT
    o.order_id,
    o.order_status,
    o.order_delivered_customer_date AS customer_received_date,
    o.order_estimated_delivery_date AS customer_estimated_receive_date,
    DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS delay_days,
    CASE 
        WHEN DATEDIFF(DAY, o.order_estimated_delivery_date, o.order_delivered_customer_date) > 0 
        THEN 1 ELSE 0 
    END AS is_delay,
	YEAR(order_delivered_customer_date) AS deliver_year,
	MONTH(order_delivered_customer_date) AS deliver_month,
    r.review_score
FROM orders o
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id
WHERE
    o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
    AND r.review_score IS NOT NULL;

---------------------------------------------------------------------------------------------------
-- Step 2: Aggregate by delay status
---------------------------------------------------------------------------------------------------
SELECT
    is_delay,
	deliver_year,
	deliver_Month,
    COUNT(order_id) AS total_orders,
    AVG(delay_days) AS avg_delay_days,
    AVG(review_score) AS avg_review_score,
    
    -- Count of each review score
    SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END) AS review_score_1,
    SUM(CASE WHEN review_score = 2 THEN 1 ELSE 0 END) AS review_score_2,
    SUM(CASE WHEN review_score = 3 THEN 1 ELSE 0 END) AS review_score_3,
    SUM(CASE WHEN review_score = 4 THEN 1 ELSE 0 END) AS review_score_4,
    SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END) AS review_score_5,
    
    -- Percentage of each review score
    ROUND(SUM(CASE WHEN review_score = 1 THEN 1 ELSE 0 END)*1.0/COUNT(order_id)*100,2) AS pct_review_score_1,
    ROUND(SUM(CASE WHEN review_score = 2 THEN 1 ELSE 0 END)*1.0/COUNT(order_id)*100,2) AS pct_review_score_2,
    ROUND(SUM(CASE WHEN review_score = 3 THEN 1 ELSE 0 END)*1.0/COUNT(order_id)*100,2) AS pct_review_score_3,
    ROUND(SUM(CASE WHEN review_score = 4 THEN 1 ELSE 0 END)*1.0/COUNT(order_id)*100,2) AS pct_review_score_4,
    ROUND(SUM(CASE WHEN review_score = 5 THEN 1 ELSE 0 END)*1.0/COUNT(order_id)*100,2) AS pct_review_score_5
FROM vw_customer_delivery_reviews
GROUP BY is_delay
ORDER BY is_delay DESC;

