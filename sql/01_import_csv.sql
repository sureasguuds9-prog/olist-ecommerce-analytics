\set ON_ERROR_STOP on

\copy olist.customers FROM 'data/raw/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.orders FROM 'data/raw/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.products FROM 'data/raw/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.sellers FROM 'data/raw/olist_sellers_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.category_translation FROM 'data/raw/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true);
\copy olist.order_items FROM 'data/raw/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.payments FROM 'data/raw/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true);
\copy olist.reviews FROM 'data/raw/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true);

