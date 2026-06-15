DROP MATERIALIZED VIEW IF EXISTS olist.order_mart;

CREATE MATERIALIZED VIEW olist.order_mart AS
WITH item_metrics AS (
    SELECT
        order_id,
        COUNT(*) AS items_qty,
        COUNT(DISTINCT product_id) AS products_cnt,
        COUNT(DISTINCT seller_id) AS sellers_cnt,
        SUM(price) AS product_revenue,
        SUM(freight_value) AS freight_value
    FROM olist.order_items
    GROUP BY order_id
),
payment_metrics AS (
    SELECT
        order_id,
        SUM(payment_value) AS payment_value,
        MAX(payment_installments) AS payment_installments,
        COUNT(DISTINCT payment_type) AS payment_types_cnt
    FROM olist.payments
    GROUP BY order_id
),
review_metrics AS (
    SELECT
        order_id,
        AVG(review_score::NUMERIC) AS review_score
    FROM olist.reviews
    GROUP BY order_id
),
ranked_categories AS (
    SELECT
        oi.order_id,
        COALESCE(ct.product_category_name_english, p.product_category_name) AS category_name,
        ROW_NUMBER() OVER (
            PARTITION BY oi.order_id
            ORDER BY oi.price DESC, oi.order_item_id
        ) AS category_rank
    FROM olist.order_items AS oi
    LEFT JOIN olist.products AS p USING (product_id)
    LEFT JOIN olist.category_translation AS ct USING (product_category_name)
),
main_category AS (
    SELECT order_id, category_name
    FROM ranked_categories
    WHERE category_rank = 1
)
SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATE_TRUNC('month', o.order_purchase_timestamp)::DATE AS purchase_month,
    mc.category_name,
    im.items_qty,
    im.products_cnt,
    im.sellers_cnt,
    im.product_revenue,
    im.freight_value,
    COALESCE(im.product_revenue, 0) + COALESCE(im.freight_value, 0) AS gmv,
    pm.payment_value,
    pm.payment_installments,
    pm.payment_types_cnt,
    rm.review_score,
    EXTRACT(EPOCH FROM (
        o.order_delivered_customer_date - o.order_purchase_timestamp
    )) / 86400 AS delivery_days,
    EXTRACT(EPOCH FROM (
        o.order_delivered_customer_date - o.order_estimated_delivery_date
    )) / 86400 AS delay_days,
    CASE
        WHEN o.order_delivered_customer_date IS NULL
          OR o.order_estimated_delivery_date IS NULL THEN NULL
        ELSE o.order_delivered_customer_date > o.order_estimated_delivery_date
    END AS is_late,
    CASE
        WHEN rm.review_score IS NULL THEN NULL
        ELSE rm.review_score <= 2
    END AS bad_review
FROM olist.orders AS o
JOIN olist.customers AS c USING (customer_id)
LEFT JOIN item_metrics AS im USING (order_id)
LEFT JOIN payment_metrics AS pm USING (order_id)
LEFT JOIN review_metrics AS rm USING (order_id)
LEFT JOIN main_category AS mc USING (order_id);

CREATE UNIQUE INDEX idx_order_mart_order_id ON olist.order_mart(order_id);
CREATE INDEX idx_order_mart_status ON olist.order_mart(order_status);
CREATE INDEX idx_order_mart_purchase_month ON olist.order_mart(purchase_month);
CREATE INDEX idx_order_mart_customer ON olist.order_mart(customer_unique_id);
CREATE INDEX idx_order_mart_category ON olist.order_mart(category_name);

-- Контроль: одна строка должна соответствовать одному заказу.
SELECT
    COUNT(*) AS mart_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) = COUNT(DISTINCT order_id) AS one_row_per_order
FROM olist.order_mart;
