SELECT
    category_name,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT customer_unique_id) AS customers,
    ROUND(SUM(gmv), 2) AS gmv,
    ROUND(SUM(gmv) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value,
    ROUND(AVG(review_score), 2) AS average_review_score,
    ROUND(AVG(is_late::INTEGER), 4) AS late_delivery_share,
    ROUND(AVG(bad_review::INTEGER), 4) AS bad_review_share
FROM olist.order_mart
WHERE order_status = 'delivered'
  AND category_name IS NOT NULL
GROUP BY category_name
HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY gmv DESC;

