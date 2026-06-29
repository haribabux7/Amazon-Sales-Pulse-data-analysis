/* ==============================================================================
   Amazon Sales — Exploratory Data Analysis (SQL)
   Table: amazon_sales_clean
   ============================================================================== */

/* ---------- 1. DATASET SUMMARY ---------- */
SELECT
    COUNT(*)                                 AS total_orders,
    COUNT(DISTINCT product_id)               AS unique_products,
    COUNT(DISTINCT product_category)         AS categories,
    COUNT(DISTINCT customer_region)          AS regions,
    MIN(order_date)                          AS first_order,
    MAX(order_date)                          AS last_order,
    ROUND(SUM(total_revenue), 2)             AS total_revenue,
    ROUND(SUM(profit), 2)                    AS total_profit,
    ROUND(AVG(total_revenue), 2)             AS avg_order_value,
    ROUND(AVG(rating), 2)                    AS avg_rating
FROM amazon_sales_clean;

/* ---------- 2. DESCRIPTIVE STATISTICS ---------- */
SELECT
    ROUND(MIN(total_revenue),2)  AS min_rev,
    ROUND(AVG(total_revenue),2)  AS avg_rev,
    ROUND(MAX(total_revenue),2)  AS max_rev,
    ROUND(STDDEV(total_revenue),2) AS std_rev,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_revenue),2) AS p25,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_revenue),2) AS median,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_revenue),2) AS p75
FROM amazon_sales_clean;

/* ---------- 3. CATEGORY ANALYSIS ---------- */
SELECT product_category,
       COUNT(*)                                   AS orders,
       ROUND(SUM(total_revenue),2)                AS revenue,
       ROUND(SUM(profit),2)                       AS profit,
       ROUND(SUM(profit)/SUM(total_revenue)*100,2) AS margin_pct,
       ROUND(AVG(rating),2)                       AS avg_rating
FROM amazon_sales_clean
GROUP BY product_category
ORDER BY revenue DESC;

/* ---------- 4. TREND ANALYSIS — monthly revenue & profit ---------- */
SELECT year_month,
       COUNT(*)                          AS orders,
       ROUND(SUM(total_revenue),2)       AS revenue,
       ROUND(SUM(profit),2)              AS profit
FROM amazon_sales_clean
GROUP BY year_month
ORDER BY year_month;

/* YoY comparison */
SELECT year,
       ROUND(SUM(total_revenue),2) AS revenue,
       ROUND(SUM(profit),2)        AS profit,
       COUNT(*)                    AS orders,
       ROUND((SUM(total_revenue) - LAG(SUM(total_revenue)) OVER (ORDER BY year))
             / LAG(SUM(total_revenue)) OVER (ORDER BY year) * 100, 2) AS yoy_growth_pct
FROM amazon_sales_clean
GROUP BY year
ORDER BY year;

/* ---------- 5. TOP / BOTTOM PERFORMANCE ---------- */
-- Top 10 products by revenue
SELECT product_id, product_category,
       COUNT(*) AS orders, ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean
GROUP BY product_id, product_category
ORDER BY revenue DESC
LIMIT 10;

-- Bottom 10 products by revenue
SELECT product_id, product_category,
       COUNT(*) AS orders, ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean
GROUP BY product_id, product_category
ORDER BY revenue ASC
LIMIT 10;

/* ---------- 6. REGIONAL / SEGMENTATION ANALYSIS ---------- */
SELECT customer_region,
       COUNT(*)                              AS orders,
       ROUND(SUM(total_revenue),2)           AS revenue,
       ROUND(AVG(total_revenue),2)           AS aov,
       ROUND(AVG(rating),2)                  AS avg_rating
FROM amazon_sales_clean
GROUP BY customer_region
ORDER BY revenue DESC;

/* Payment-method segmentation */
SELECT payment_method,
       COUNT(*)                              AS orders,
       ROUND(SUM(total_revenue),2)           AS revenue,
       ROUND(SUM(total_revenue)/
             (SELECT SUM(total_revenue) FROM amazon_sales_clean)*100,2) AS revenue_share_pct
FROM amazon_sales_clean
GROUP BY payment_method
ORDER BY revenue DESC;

/* Discount-band effectiveness */
SELECT discount_band,
       COUNT(*)                              AS orders,
       ROUND(SUM(total_revenue),2)           AS revenue,
       ROUND(AVG(total_revenue),2)           AS aov,
       ROUND(AVG(rating),2)                  AS avg_rating
FROM amazon_sales_clean
GROUP BY discount_band
ORDER BY discount_band;

/* ---------- 7. PATTERN DETECTION — day of week ---------- */
SELECT day_of_week,
       COUNT(*) AS orders,
       ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean
GROUP BY day_of_week
ORDER BY CASE day_of_week
    WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6 ELSE 7 END;
