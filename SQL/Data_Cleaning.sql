/* ==============================================================================
   Amazon Sales — Data Cleaning (SQL)
   ------------------------------------------------------------------------------
   Works on PostgreSQL / Snowflake / BigQuery (standard SQL).
   Run order: 1_Create_Raw → 2_Clean → 3_Validate → 4_Feature_Engineering
   ============================================================================== */

/* ---------- 1. LOAD RAW DATA INTO STAGING TABLE ----------
   (If loading from CSV, use your DB's bulk load, e.g. PostgreSQL \copy or
    Snowflake COPY INTO, BigQuery LOAD DATA. Schema shown for reference.)
*/
CREATE TABLE IF NOT EXISTS stg_amazon_sales_raw (
    order_id          BIGINT,
    order_date        VARCHAR(32),
    product_id        BIGINT,
    product_category  VARCHAR(64),
    price             NUMERIC(10,2),
    discount_percent  INT,
    quantity_sold     INT,
    customer_region   VARCHAR(64),
    payment_method    VARCHAR(64),
    rating            NUMERIC(3,1),
    review_count      INT,
    discounted_price  NUMERIC(10,2),
    total_revenue     NUMERIC(12,2)
);

/* ---------- 2. CLEAN: types, trim, dedupe, nulls ---------- */
CREATE TABLE amazon_sales_clean AS
SELECT
    CAST(order_id AS BIGINT)                                AS order_id,
    CAST(order_date AS DATE)                                AS order_date,
    CAST(product_id AS BIGINT)                              AS product_id,
    INITCAP(TRIM(product_category))                         AS product_category,
    CAST(price AS NUMERIC(10,2))                            AS price,
    CAST(discount_percent AS INT)                           AS discount_percent,
    CAST(quantity_sold AS INT)                              AS quantity_sold,
    INITCAP(TRIM(customer_region))                          AS customer_region,
    INITCAP(TRIM(payment_method))                           AS payment_method,
    CAST(rating AS NUMERIC(3,1))                            AS rating,
    CAST(review_count AS INT)                               AS review_count,
    -- Recompute derived fields so they are always consistent
    ROUND(CAST(price AS NUMERIC(10,2)) *
          (1 - CAST(discount_percent AS INT)/100.0), 2)     AS discounted_price,
    ROUND(CAST(price AS NUMERIC(10,2)) *
          (1 - CAST(discount_percent AS INT)/100.0) *
          CAST(quantity_sold AS INT), 2)                    AS total_revenue
FROM stg_amazon_sales_raw
WHERE order_id IS NOT NULL
  AND order_date IS NOT NULL
  AND total_revenue IS NOT NULL;

/* Remove exact + key duplicates (keep most recent) */
DELETE FROM amazon_sales_clean
WHERE order_id IN (
    SELECT order_id FROM (
        SELECT order_id,
               ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date DESC) AS rn
        FROM amazon_sales_clean
    ) x WHERE rn > 1
);

/* ---------- 3. VALIDATION: remove out-of-range rows ---------- */
DELETE FROM amazon_sales_clean
WHERE price            <= 0
   OR quantity_sold    <= 0
   OR discount_percent < 0
   OR discount_percent > 100
   OR rating           < 0
   OR rating           > 5;

/* ---------- 4. FEATURE ENGINEERING ---------- */
ALTER TABLE amazon_sales_clean
    ADD COLUMN IF NOT EXISTS profit_margin  NUMERIC(4,2),
    ADD COLUMN IF NOT EXISTS profit         NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS cost           NUMERIC(12,2),
    ADD COLUMN IF NOT EXISTS year           INT,
    ADD COLUMN IF NOT EXISTS month          INT,
    ADD COLUMN IF NOT EXISTS year_month     VARCHAR(7),
    ADD COLUMN IF NOT EXISTS quarter        INT,
    ADD COLUMN IF NOT EXISTS day_of_week    VARCHAR(12),
    ADD COLUMN IF NOT EXISTS discount_band  VARCHAR(16),
    ADD COLUMN IF NOT EXISTS rating_tier    VARCHAR(12);

/* Category-based gross margin (business assumption) */
UPDATE amazon_sales_clean
SET profit_margin = CASE product_category
        WHEN 'Electronics'   THEN 0.28
        WHEN 'Fashion'       THEN 0.40
        WHEN 'Beauty'        THEN 0.45
        WHEN 'Books'         THEN 0.35
        WHEN 'Sports'        THEN 0.30
        WHEN 'Home & Kitchen' THEN 0.25
        ELSE 0.30 END,
    profit = ROUND(total_revenue * profit_margin, 2),
    cost   = ROUND(total_revenue - (total_revenue * profit_margin), 2);

/* Date dimensions */
UPDATE amazon_sales_clean
SET year        = EXTRACT(YEAR  FROM order_date),
    month       = EXTRACT(MONTH FROM order_date),
    year_month  = TO_CHAR(order_date, 'YYYY-MM'),
    quarter     = EXTRACT(QUARTER FROM order_date),
    day_of_week = TRIM(TO_CHAR(order_date, 'Day'));

/* Discount band */
UPDATE amazon_sales_clean
SET discount_band = CASE
        WHEN discount_percent = 0               THEN 'No Discount'
        WHEN discount_percent BETWEEN 1  AND 10 THEN 'Low (1-10%)'
        WHEN discount_percent BETWEEN 11 AND 20 THEN 'Medium (11-20%)'
        ELSE 'High (21+%)' END;

/* Rating tier */
UPDATE amazon_sales_clean
SET rating_tier = CASE
        WHEN rating <= 2       THEN 'Poor'
        WHEN rating <= 3       THEN 'Average'
        WHEN rating <= 4       THEN 'Good'
        ELSE 'Excellent' END;

/* ---------- 5. FINAL QA ---------- */
SELECT 'Total rows'           AS metric, COUNT(*)::VARCHAR AS value FROM amazon_sales_clean
UNION ALL SELECT 'Null revenue',  COUNT(*)::VARCHAR FROM amazon_sales_clean WHERE total_revenue IS NULL
UNION ALL SELECT 'Duplicates',    COUNT(*)::VARCHAR FROM (SELECT order_id FROM amazon_sales_clean GROUP BY order_id HAVING COUNT(*)>1) d
UNION ALL SELECT 'Total revenue', SUM(total_revenue)::VARCHAR FROM amazon_sales_clean;
