WITH delivered AS (
    SELECT *
    FROM olist.order_mart
    WHERE order_status = 'delivered'
),
customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS orders
    FROM delivered
    GROUP BY customer_unique_id
)
SELECT
    (SELECT COUNT(DISTINCT order_id) FROM delivered) AS delivered_orders,
    (SELECT COUNT(DISTINCT customer_unique_id) FROM delivered) AS unique_customers,
    ROUND((SELECT SUM(product_revenue) FROM delivered), 2) AS product_revenue,
    ROUND((SELECT SUM(gmv) FROM delivered), 2) AS gmv,
    ROUND(
        (SELECT SUM(gmv) FROM delivered)
        / NULLIF((SELECT COUNT(DISTINCT order_id) FROM delivered), 0),
        2
    ) AS average_order_value,
    ROUND((SELECT AVG(review_score) FROM delivered), 2) AS average_review_score,
    ROUND((SELECT AVG(is_late::INTEGER) FROM delivered), 4) AS late_delivery_share,
    ROUND((SELECT AVG((orders > 1)::INTEGER) FROM customer_orders), 4) AS repeat_customer_rate;

