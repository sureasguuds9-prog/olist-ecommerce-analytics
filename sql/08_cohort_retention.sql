WITH customer_months AS (
    SELECT DISTINCT
        customer_unique_id,
        purchase_month
    FROM olist.order_mart
    WHERE order_status = 'delivered'
      AND purchase_month IS NOT NULL
),
customer_cohorts AS (
    SELECT
        customer_unique_id,
        MIN(purchase_month) AS cohort_month
    FROM customer_months
    GROUP BY customer_unique_id
),
cohort_activity AS (
    SELECT
        cm.customer_unique_id,
        cc.cohort_month,
        cm.purchase_month,
        (
            EXTRACT(YEAR FROM AGE(cm.purchase_month, cc.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(cm.purchase_month, cc.cohort_month))
        )::INTEGER AS cohort_index
    FROM customer_months AS cm
    JOIN customer_cohorts AS cc USING (customer_unique_id)
),
cohort_counts AS (
    SELECT
        cohort_month,
        cohort_index,
        COUNT(DISTINCT customer_unique_id) AS active_customers
    FROM cohort_activity
    GROUP BY cohort_month, cohort_index
),
cohort_sizes AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_counts
    WHERE cohort_index = 0
)
SELECT
    cc.cohort_month,
    cc.cohort_index,
    cs.cohort_size,
    cc.active_customers,
    ROUND(cc.active_customers::NUMERIC / NULLIF(cs.cohort_size, 0), 4) AS retention
FROM cohort_counts AS cc
JOIN cohort_sizes AS cs USING (cohort_month)
ORDER BY cc.cohort_month, cc.cohort_index;

