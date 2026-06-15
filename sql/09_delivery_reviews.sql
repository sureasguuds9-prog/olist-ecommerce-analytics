SELECT
    CASE
        WHEN is_late THEN 'С опозданием'
        ELSE 'Вовремя'
    END AS delivery_status,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(AVG(delivery_days), 2) AS average_delivery_days,
    ROUND(AVG(delay_days), 2) AS average_delay_days,
    ROUND(AVG(review_score), 2) AS average_review_score,
    ROUND(AVG(bad_review::INTEGER), 4) AS bad_review_share
FROM olist.order_mart
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
  AND review_score IS NOT NULL
GROUP BY is_late
ORDER BY is_late;

-- Штаты с высоким числом заказов и наибольшей долей опозданий.
SELECT
    customer_state,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(AVG(is_late::INTEGER), 4) AS late_delivery_share,
    ROUND(AVG(review_score), 2) AS average_review_score,
    ROUND(AVG(bad_review::INTEGER), 4) AS bad_review_share
FROM olist.order_mart
WHERE order_status = 'delivered'
  AND is_late IS NOT NULL
GROUP BY customer_state
HAVING COUNT(DISTINCT order_id) >= 500
ORDER BY late_delivery_share DESC;

