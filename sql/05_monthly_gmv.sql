WITH monthly_sales AS (
    SELECT
        purchase_month,
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_unique_id) AS customers,
        SUM(gmv) AS gmv
    FROM olist.order_mart
    WHERE order_status = 'delivered'
    GROUP BY purchase_month
),
with_previous_month AS (
    SELECT
        *,
        LAG(gmv) OVER (ORDER BY purchase_month) AS previous_month_gmv
    FROM monthly_sales
)
SELECT
    purchase_month,
    orders,
    customers,
    ROUND(gmv, 2) AS gmv,
    ROUND(gmv / NULLIF(orders, 0), 2) AS average_order_value,
    ROUND(
        (gmv / NULLIF(previous_month_gmv, 0) - 1) * 100,
        2
    ) AS gmv_growth_percent
FROM with_previous_month
ORDER BY purchase_month;

