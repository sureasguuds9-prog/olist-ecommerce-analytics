# Analytical Report: Brazilian Olist Marketplace

## Objective

The purpose of the analysis is to identify the main constraints on marketplace growth and customer experience using sales, customer, delivery, and review data.

## Dataset and Method

The project uses the Brazilian Olist public e-commerce dataset. Seven source tables are aggregated into an order-level analytical mart. The main analytical unit is one order.

The analysis covers:

- data-quality validation;
- sales and category performance;
- repeat-purchase rate;
- monthly cohort retention;
- RFM customer segmentation;
- delivery-quality metrics;
- basic statistical testing.

## Main Results

### Commercial performance

- Delivered orders: **96,478**
- Unique customers: **93,358**
- Product revenue: **13.22M**
- GMV including freight: **15.42M**
- Average order value: **159.83**

### Customer retention

Only **3.00%** of customers placed more than one delivered order. This suggests that the marketplace relies mainly on new-customer acquisition rather than recurring customer value.

Cohort retention declines sharply after month zero. The largest practical CRM opportunity is converting recent first-time buyers into second-time buyers.

### Delivery and customer satisfaction

Orders delivered on time have an average review score of **4.29** and a bad-review share of **9.19%**. Late orders have an average review score of **2.57** and a bad-review share of **53.99%**.

The differences are statistically significant:

- chi-square test rejects the null hypothesis of independence between late-delivery status and bad-review status;
- Welch t-test rejects the null hypothesis of equal average review scores.

These results show a strong association. They do not prove that delivery delay is the only cause of poor reviews because orders were not randomly assigned to delivery-status groups.

## Recommendations

### Improve second-purchase conversion

Create CRM campaigns for customers within 30–60 days of their first order. Campaign effectiveness should be measured through repeat-purchase rate and revenue per customer.

### Introduce delivery-quality monitoring

Track late-delivery share, average delay, average review score, and bad-review share by category, customer state, and seller.

### Communicate proactively about delays

Notify customers before the expected-delivery date when an order is at risk. The effect of notifications or compensation should be validated through a real randomized experiment.

### Protect valuable customer segments

Use RFM segments to separate recent first-time buyers, repeat high-value buyers, and inactive customers. Apply different communication strategies to each group.

## Limitations and Next Steps

- Marketplace margin and customer-acquisition cost are unavailable.
- The analysis cannot measure profitability or customer lifetime value accurately.
- Observational comparisons cannot establish causality.
- A future project version can add SQL queries and a dashboard after the Python analysis is finalized.

