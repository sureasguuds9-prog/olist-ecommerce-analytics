WITH seller_orders AS (
    SELECT DISTINCT
        oi.seller_id,
        om.order_id,
        om.is_late,
        om.bad_review,
        om.review_score,
        om.order_status
    FROM olist.order_items AS oi
    JOIN olist.order_mart AS om USING (order_id)
),
seller_revenue AS (
    SELECT
        oi.seller_id,
        SUM(oi.price) AS product_revenue,
        SUM(oi.freight_value) AS freight_value
    FROM olist.order_items AS oi
    JOIN olist.order_mart AS om USING (order_id)
    WHERE om.order_status = 'delivered'
    GROUP BY oi.seller_id
)
SELECT
    so.seller_id,
    s.seller_state,
    COUNT(DISTINCT so.order_id) AS delivered_orders,
    ROUND(sr.product_revenue, 2) AS product_revenue,
    ROUND(AVG(so.is_late::INTEGER), 4) AS late_delivery_share,
    ROUND(AVG(so.bad_review::INTEGER), 4) AS bad_review_share,
    ROUND(AVG(so.review_score), 2) AS average_review_score
FROM seller_orders AS so
JOIN seller_revenue AS sr USING (seller_id)
LEFT JOIN olist.sellers AS s USING (seller_id)
WHERE so.order_status = 'delivered'
GROUP BY so.seller_id, s.seller_state, sr.product_revenue
HAVING COUNT(DISTINCT so.order_id) >= 100
ORDER BY bad_review_share DESC, late_delivery_share DESC;
