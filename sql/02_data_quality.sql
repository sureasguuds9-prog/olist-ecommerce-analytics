-- Размер исходных таблиц.
SELECT 'customers' AS table_name, COUNT(*) AS rows_count FROM olist.customers
UNION ALL
SELECT 'orders', COUNT(*) FROM olist.orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM olist.order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM olist.payments
UNION ALL
SELECT 'reviews', COUNT(*) FROM olist.reviews
UNION ALL
SELECT 'products', COUNT(*) FROM olist.products
UNION ALL
SELECT 'sellers', COUNT(*) FROM olist.sellers
ORDER BY rows_count DESC;

-- Проверка уникальности основных ключей.
SELECT
    COUNT(*) AS orders_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(DISTINCT order_id) AS duplicate_orders
FROM olist.orders;

-- Статусы заказов и наличие фактической даты доставки.
SELECT
    order_status,
    COUNT(*) AS orders,
    COUNT(order_delivered_customer_date) AS orders_with_delivery_date
FROM olist.orders
GROUP BY order_status
ORDER BY orders DESC;

-- Заказы без товаров и без отзывов.
SELECT
    COUNT(*) FILTER (WHERE oi.order_id IS NULL) AS orders_without_items,
    COUNT(*) FILTER (WHERE r.order_id IS NULL) AS orders_without_reviews
FROM olist.orders AS o
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM olist.order_items
) AS oi USING (order_id)
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM olist.reviews
) AS r USING (order_id);

