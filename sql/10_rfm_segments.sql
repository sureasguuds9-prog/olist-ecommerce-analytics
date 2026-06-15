WITH customer_metrics AS (
    SELECT
        customer_unique_id,
        (
            MAX(MAX(order_purchase_timestamp)) OVER ()
            + INTERVAL '1 day'
            - MAX(order_purchase_timestamp)
        )::INTERVAL AS recency_interval,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(gmv) AS monetary
    FROM olist.order_mart
    WHERE order_status = 'delivered'
    GROUP BY customer_unique_id
),
rfm_scores AS (
    SELECT
        customer_unique_id,
        EXTRACT(DAY FROM recency_interval)::INTEGER AS recency,
        frequency,
        monetary,
        6 - NTILE(5) OVER (ORDER BY recency_interval) AS r_score,
        CASE
            WHEN frequency = 1 THEN 1
            WHEN frequency = 2 THEN 2
            WHEN frequency = 3 THEN 3
            WHEN frequency = 4 THEN 4
            ELSE 5
        END AS f_score,
        NTILE(5) OVER (ORDER BY monetary) AS m_score
    FROM customer_metrics
),
segmented AS (
    SELECT
        *,
        CASE
            WHEN r_score >= 4 AND f_score >= 2 AND m_score >= 4 THEN 'Чемпионы'
            WHEN r_score >= 4 AND f_score = 1 THEN 'Новые клиенты'
            WHEN r_score <= 2 AND f_score >= 2 THEN 'Под риском'
            WHEN r_score <= 2 THEN 'Неактивные'
            ELSE 'Обычные'
        END AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*) AS customers,
    ROUND(AVG(recency), 2) AS average_recency,
    ROUND(AVG(frequency), 2) AS average_frequency,
    ROUND(AVG(monetary), 2) AS average_monetary
FROM segmented
GROUP BY segment
ORDER BY customers DESC;
