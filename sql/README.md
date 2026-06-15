# SQL-анализ Olist

SQL-часть проекта реализована под **PostgreSQL 14+** и повторяет основные расчёты Python-анализа.

## Что демонстрируют запросы

- создание схемы и таблиц;
- импорт CSV через `\copy`;
- контроль качества данных;
- безопасное объединение таблиц «один ко многим»;
- `JOIN`, `GROUP BY`, `HAVING`;
- Common Table Expressions (`CTE`);
- оконные функции `LAG`, `ROW_NUMBER`, `NTILE`;
- расчёт GMV, AOV, retention и RFM;
- анализ качества доставки, отзывов и продавцов.

## Структура

| Файл | Назначение |
|---|---|
| `00_create_tables.sql` | создание схемы, таблиц и индексов |
| `01_import_csv.sql` | импорт исходных CSV |
| `02_data_quality.sql` | проверки качества данных |
| `03_create_order_mart.sql` | materialized view на уровне заказа и индексы |
| `04_executive_kpis.sql` | основные KPI |
| `05_monthly_gmv.sql` | GMV, AOV и темпы роста по месяцам |
| `06_top_categories.sql` | показатели товарных категорий |
| `07_repeat_customers.sql` | повторные клиенты |
| `08_cohort_retention.sql` | когортный retention |
| `09_delivery_reviews.sql` | доставка и отзывы |
| `10_rfm_segments.sql` | RFM-сегментация |
| `11_seller_quality.sql` | качество продавцов |

## Запуск

Команды необходимо выполнять из корня репозитория, где находится папка `data/raw/`.

Создайте базу:

```bash
createdb olist_analytics
```

Создайте таблицы и импортируйте данные:

```bash
psql -d olist_analytics -f sql/00_create_tables.sql
psql -d olist_analytics -f sql/01_import_csv.sql
psql -d olist_analytics -f sql/03_create_order_mart.sql
```

Запустите аналитические запросы:

```bash
psql -d olist_analytics -f sql/04_executive_kpis.sql
psql -d olist_analytics -f sql/08_cohort_retention.sql
psql -d olist_analytics -f sql/10_rfm_segments.sql
```

Запустить все запросы последовательно:

```bash
for file in sql/[0-9][0-9]_*.sql; do
    psql -d olist_analytics -f "$file"
done
```

## Контрольные результаты

После создания витрины:

- строк в витрине: `99 441`;
- уникальных заказов: `99 441`;
- одна строка соответствует одному заказу: `true`;
- доставленных заказов: `96 478`;
- уникальных клиентов среди доставленных заказов: `93 358`;
- GMV с учётом доставки: около `15,42 млн`;
- доля повторных клиентов: около `3,00%`.

Небольшие различия в округлении между SQL и Python допустимы.

Витрина реализована как `MATERIALIZED VIEW`, чтобы аналитические запросы не пересчитывали все агрегации исходных таблиц при каждом запуске. После обновления исходных данных её можно пересоздать командой:

```sql
REFRESH MATERIALIZED VIEW olist.order_mart;
```
