WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS orders,
        SUM(gmv) AS customer_gmv,
        MIN(order_purchase_timestamp) AS first_order_at,
        MAX(order_purchase_timestamp) AS last_order_at
    FROM olist.order_mart
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
)
SELECT
    COUNT(*) AS customers,
    COUNT(*) FILTER (WHERE orders > 1) AS repeat_customers,
    ROUND(AVG((orders > 1)::INTEGER), 4) AS repeat_customer_rate,
    ROUND(AVG(orders), 2) AS average_orders_per_customer,
    ROUND(AVG(customer_gmv), 2) AS average_customer_gmv
FROM customer_orders;

-- Распределение клиентов по количеству заказов.
WITH customer_orders AS (
    SELECT
        customer_unique_id,
        COUNT(DISTINCT order_id) AS orders
    FROM olist.order_mart
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
)
SELECT
    orders,
    COUNT(*) AS customers
FROM customer_orders
GROUP BY orders
ORDER BY orders;

