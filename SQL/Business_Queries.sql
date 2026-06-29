/* ==============================================================================
   Amazon Sales — Business Queries (30+ Questions)
   Table: amazon_sales_clean
   Each block:  QUESTION → QUERY → INSIGHT → RECOMMENDATION
   ============================================================================== */

/* ==================================================================
   SECTION A — REVENUE & GROWTH
   ================================================================== */

/* --- Q1 ---------------------------------------------------------
   QUESTION: What is the total revenue, profit, and overall margin?
   INSIGHT: Establishes the baseline health of the business.
   RECOMMENDATION: Use as the top headline KPI; benchmark margin ≥30%.
---------------------------------------------------------------- */
SELECT
    ROUND(SUM(total_revenue),2)                     AS total_revenue,
    ROUND(SUM(profit),2)                            AS total_profit,
    ROUND(SUM(profit)/NULLIF(SUM(total_revenue),0)*100,2) AS overall_margin_pct,
    COUNT(*)                                        AS total_orders
FROM amazon_sales_clean;

/* --- Q2 ---------------------------------------------------------
   QUESTION: How did revenue grow Year-over-Year (2022 vs 2023)?
   INSIGHT: YoY growth is ~+0.5% — essentially flat, signalling stagnation.
   RECOMMENDATION: Launch growth initiatives (campaigns, new markets, bundles).
---------------------------------------------------------------- */
SELECT year,
       ROUND(SUM(total_revenue),2) AS revenue,
       ROUND((SUM(total_revenue) - LAG(SUM(total_revenue)) OVER (ORDER BY year))
             / LAG(SUM(total_revenue)) OVER (ORDER BY year)*100,2) AS yoy_growth_pct
FROM amazon_sales_clean GROUP BY year ORDER BY year;

/* --- Q3 ---------------------------------------------------------
   QUESTION: What is the month-over-month revenue trend?
   INSIGHT: Reveals seasonality; Q3 shows a mild seasonal peak.
   RECOMMENDATION: Align inventory & marketing spend to seasonal peaks.
---------------------------------------------------------------- */
SELECT year_month, ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean GROUP BY year_month ORDER BY year_month;

/* --- Q4 ---------------------------------------------------------
   QUESTION: Which quarter delivers the highest revenue?
   INSIGHT: Identifies the strongest quarter to concentrate investment.
   RECOMMENDATION: Front-load Q3 promotions to maximise peak demand.
---------------------------------------------------------------- */
SELECT year, quarter, ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean GROUP BY year, quarter ORDER BY revenue DESC;

/* --- Q5 ---------------------------------------------------------
   QUESTION: What is the Average Order Value (AOV) trend by year?
   INSIGHT: AOV stability indicates consistent basket size.
   RECOMMENDATION: Drive AOV up via cross-sell / bundle offers.
---------------------------------------------------------------- */
SELECT year, ROUND(AVG(total_revenue),2) AS aov
FROM amazon_sales_clean GROUP BY year ORDER BY year;

/* ==================================================================
   SECTION B — CATEGORY ANALYSIS
   ================================================================== */

/* --- Q6 ---------------------------------------------------------
   QUESTION: Which product category generates the most revenue?
   INSIGHT: Beauty leads (~$5.55M) but the spread is tight (~3%).
   RECOMMENDATION: Protect category diversity; cross-sell from Beauty.
---------------------------------------------------------------- */
SELECT product_category, ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean GROUP BY product_category ORDER BY revenue DESC;

/* --- Q7 ---------------------------------------------------------
   QUESTION: Which category is the most profitable (margin %)?
   INSIGHT: Beauty (45%) and Fashion (40%) are margin engines.
   RECOMMENDATION: Prioritise inventory & marketing on high-margin lines.
---------------------------------------------------------------- */
SELECT product_category,
       ROUND(SUM(profit)/SUM(total_revenue)*100,2) AS margin_pct
FROM amazon_sales_clean GROUP BY product_category ORDER BY margin_pct DESC;

/* --- Q8 ---------------------------------------------------------
   QUESTION: Which category has the lowest profit margin?
   INSIGHT: Home & Kitchen (25%) is the lowest-margin category.
   RECOMMENDATION: Renegotiate supplier costs or reprice Home & Kitchen.
---------------------------------------------------------------- */
SELECT product_category,
       ROUND(SUM(profit)/SUM(total_revenue)*100,2) AS margin_pct
FROM amazon_sales_clean GROUP BY product_category ORDER BY margin_pct ASC;

/* --- Q9 ---------------------------------------------------------
   QUESTION: What is each category's revenue share (%)?
   INSIGHT: Revenue is well-diversified; no single category dominates.
   RECOMMENDATION: Maintain a balanced portfolio to spread risk.
---------------------------------------------------------------- */
SELECT product_category,
       ROUND(SUM(total_revenue)/(SELECT SUM(total_revenue) FROM amazon_sales_clean)*100,2) AS revenue_share_pct
FROM amazon_sales_clean GROUP BY product_category ORDER BY revenue_share_pct DESC;

/* --- Q10 --------------------------------------------------------
   QUESTION: Which category has the highest average rating?
   INSIGHT: All categories hover near 3.0 — a quality-reputation gap.
   RECOMMENDATION: Investigate product quality & fulfilment issues.
---------------------------------------------------------------- */
SELECT product_category, ROUND(AVG(rating),2) AS avg_rating
FROM amazon_sales_clean GROUP BY product_category ORDER BY avg_rating DESC;

/* --- Q11 --------------------------------------------------------
   QUESTION: Which category sells the most units (volume)?
   INSIGHT: Volume leadership by category informs supply planning.
   RECOMMENDATION: Ensure high-volume categories never stock out.
---------------------------------------------------------------- */
SELECT product_category, SUM(quantity_sold) AS units_sold
FROM amazon_sales_clean GROUP BY product_category ORDER BY units_sold DESC;

/* ==================================================================
   SECTION C — PRODUCT PERFORMANCE
   ================================================================== */

/* --- Q12 --------------------------------------------------------
   QUESTION: Top 10 products by total revenue?
   INSIGHT: Identifies hero products that anchor the catalogue.
   RECOMMENDATION: Feature top products prominently & secure stock.
---------------------------------------------------------------- */
SELECT product_id, product_category,
       ROUND(SUM(total_revenue),2) AS revenue, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY product_id, product_category
ORDER BY revenue DESC LIMIT 10;

/* --- Q13 --------------------------------------------------------
   QUESTION: Bottom 10 products by revenue (underperformers)?
   INSIGHT: Long-tail SKUs that may drag profitability.
   RECOMMENDATION: Review for discontinuation or repositioning.
---------------------------------------------------------------- */
SELECT product_id, product_category,
       ROUND(SUM(total_revenue),2) AS revenue, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY product_id, product_category
ORDER BY revenue ASC LIMIT 10;

/* --- Q14 --------------------------------------------------------
   QUESTION: Which products have the highest average rating?
   INSIGHT: Spotlights customer-loved products for social proof.
   RECOMMENDATION: Use high-rated products in marketing testimonials.
---------------------------------------------------------------- */
SELECT product_id, product_category,
       ROUND(AVG(rating),2) AS avg_rating, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY product_id, product_category
HAVING COUNT(*) >= 10
ORDER BY avg_rating DESC LIMIT 10;

/* --- Q15 --------------------------------------------------------
   QUESTION: Which products have the worst ratings?
   INSIGHT: Flags quality / satisfaction risks early.
   RECOMMENDATION: Trigger quality review & vendor follow-up.
---------------------------------------------------------------- */
SELECT product_id, product_category,
       ROUND(AVG(rating),2) AS avg_rating, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY product_id, product_category
HAVING COUNT(*) >= 10
ORDER BY avg_rating ASC LIMIT 10;

/* ==================================================================
   SECTION D — REGIONAL / GEOGRAPHIC ANALYSIS
   ================================================================== */

/* --- Q16 --------------------------------------------------------
   QUESTION: Which region generates the most revenue?
   INSIGHT: Middle East & North America lead marginally; regions balanced.
   RECOMMENDATION: Maintain even regional investment; protect leaders.
---------------------------------------------------------------- */
SELECT customer_region, ROUND(SUM(total_revenue),2) AS revenue,
       ROUND(AVG(total_revenue),2) AS aov, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY customer_region ORDER BY revenue DESC;

/* --- Q17 --------------------------------------------------------
   QUESTION: Which region is the most profitable?
   INSIGHT: Profitability tracks revenue closely across regions.
   RECOMMENDATION: Reinvest regional profit into growth marketing.
---------------------------------------------------------------- */
SELECT customer_region, ROUND(SUM(profit),2) AS profit
FROM amazon_sales_clean GROUP BY customer_region ORDER BY profit DESC;

/* --- Q18 --------------------------------------------------------
   QUESTION: Which region has the highest AOV?
   INSIGHT: AOV differences reveal regional pricing sensitivity.
   RECOMMENDATION: Tailor premium bundles to high-AOV regions.
---------------------------------------------------------------- */
SELECT customer_region, ROUND(AVG(total_revenue),2) AS aov
FROM amazon_sales_clean GROUP BY customer_region ORDER BY aov DESC;

/* --- Q19 --------------------------------------------------------
   QUESTION: Region × Category revenue matrix (heatmap data)?
   INSIGHT: Exposes category-region affinities for localisation.
   RECOMMENDATION: Localise assortment to each region's preferences.
---------------------------------------------------------------- */
SELECT customer_region, product_category,
       ROUND(SUM(total_revenue),2) AS revenue
FROM amazon_sales_clean
GROUP BY customer_region, product_category
ORDER BY customer_region, revenue DESC;

/* --- Q20 --------------------------------------------------------
   QUESTION: Which region has the lowest customer rating?
   INSIGHT: Pinpoints where fulfilment/quality issues concentrate.
   RECOMMENDATION: Audit logistics partners in the weakest region.
---------------------------------------------------------------- */
SELECT customer_region, ROUND(AVG(rating),2) AS avg_rating
FROM amazon_sales_clean GROUP BY customer_region ORDER BY avg_rating ASC;

/* ==================================================================
   SECTION E — PAYMENT & CUSTOMER BEHAVIOUR
   ================================================================== */

/* --- Q21 --------------------------------------------------------
   QUESTION: Which payment method drives the most revenue?
   INSIGHT: Wallet & UPI lead slightly; mix is very even.
   RECOMMENDATION: Incentivise low-cost digital payments (UPI/Wallet).
---------------------------------------------------------------- */
SELECT payment_method, ROUND(SUM(total_revenue),2) AS revenue,
       ROUND(SUM(total_revenue)/(SELECT SUM(total_revenue) FROM amazon_sales_clean)*100,2) AS share_pct
FROM amazon_sales_clean GROUP BY payment_method ORDER BY revenue DESC;

/* --- Q22 --------------------------------------------------------
   QUESTION: What is the revenue share of Cash on Delivery?
   INSIGHT: ~20% COD share adds collection risk & cost.
   RECOMMENDATION: Offer digital-payment discounts to reduce COD.
---------------------------------------------------------------- */
SELECT payment_method,
       ROUND(SUM(total_revenue)/(SELECT SUM(total_revenue) FROM amazon_sales_clean)*100,2) AS share_pct
FROM amazon_sales_clean
WHERE payment_method = 'Cash On Delivery'
GROUP BY payment_method;

/* --- Q23 --------------------------------------------------------
   QUESTION: Which discount band drives the most revenue?
   INSIGHT: Low/Medium discounts drive the bulk of revenue.
   RECOMMENDATION: Avoid deep discounting; preserve margin.
---------------------------------------------------------------- */
SELECT discount_band, ROUND(SUM(total_revenue),2) AS revenue,
       COUNT(*) AS orders, ROUND(AVG(total_revenue),2) AS aov
FROM amazon_sales_clean GROUP BY discount_band ORDER BY revenue DESC;

/* --- Q24 --------------------------------------------------------
   QUESTION: Does deeper discounting lift ratings?
   INSIGHT: No — ratings stay flat (~3.0) across discount bands.
   RECOMMENDATION: Stop using discounts as a satisfaction lever.
---------------------------------------------------------------- */
SELECT discount_band, ROUND(AVG(rating),2) AS avg_rating, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY discount_band ORDER BY discount_band;

/* --- Q25 --------------------------------------------------------
   QUESTION: Average review count by category (engagement)?
   INSIGHT: Gauges which categories spark customer engagement.
   RECOMMENDATION: Request reviews in low-engagement categories.
---------------------------------------------------------------- */
SELECT product_category, ROUND(AVG(review_count),0) AS avg_reviews
FROM amazon_sales_clean GROUP BY product_category ORDER BY avg_reviews DESC;

/* ==================================================================
   SECTION F — PROFITABILITY & OPERATIONAL
   ================================================================== */

/* --- Q26 --------------------------------------------------------
   QUESTION: Total profit by year (trend)?
   INSIGHT: Profit is flat YoY, mirroring flat revenue.
   RECOMMENDATION: Pursue margin expansion, not just volume.
---------------------------------------------------------------- */
SELECT year, ROUND(SUM(profit),2) AS profit
FROM amazon_sales_clean GROUP BY year ORDER BY year;

/* --- Q27 --------------------------------------------------------
   QUESTION: Category × Region profit matrix (where do we make money)?
   INSIGHT: Identifies the most profitable category-region cells.
   RECOMMENDATION: Double down on the top profit cells.
---------------------------------------------------------------- */
SELECT customer_region, product_category, ROUND(SUM(profit),2) AS profit
FROM amazon_sales_clean
GROUP BY customer_region, product_category
ORDER BY profit DESC;

/* --- Q28 --------------------------------------------------------
   QUESTION: Revenue by day of week (operational scheduling)?
   INSIGHT: Reveals which weekdays convert best.
   RECOMMENDATION: Time promotions & stock replenishment to peak days.
---------------------------------------------------------------- */
SELECT day_of_week, ROUND(SUM(total_revenue),2) AS revenue, COUNT(*) AS orders
FROM amazon_sales_clean GROUP BY day_of_week
ORDER BY CASE day_of_week WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3 WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6 ELSE 7 END;

/* --- Q29 --------------------------------------------------------
   QUESTION: What share of revenue comes from high-rated (≥4) products?
   INSIGHT: Measures how much revenue rests on customer satisfaction.
   RECOMMENDATION: Grow the high-rated revenue share via QA programs.
---------------------------------------------------------------- */
SELECT
    ROUND(SUM(CASE WHEN rating>=4 THEN total_revenue ELSE 0 END)/SUM(total_revenue)*100,2) AS high_rating_rev_pct
FROM amazon_sales_clean;

/* --- Q30 --------------------------------------------------------
   QUESTION: Which category-region combo has the LOWEST margin?
   INSIGHT: Flags the least profitable intersections.
   RECOMMENDATION: Target these for cost reduction or repricing.
---------------------------------------------------------------- */
SELECT customer_region, product_category,
       ROUND(SUM(profit)/SUM(total_revenue)*100,2) AS margin_pct
FROM amazon_sales_clean
GROUP BY customer_region, product_category
ORDER BY margin_pct ASC LIMIT 10;

/* --- Q31 --------------------------------------------------------
   QUESTION: What is the revenue concentration (Pareto — top 20% products)?
   INSIGHT: Tests the 80/20 rule for SKU rationalisation.
   RECOMMENDATION: Protect hero SKUs; rationalise the long tail.
---------------------------------------------------------------- */
SELECT
    ROUND(SUM(CASE WHEN rnk <= 0.20*(SELECT COUNT(DISTINCT product_id) FROM amazon_sales_clean)
                   THEN revenue ELSE 0 END)/SUM(revenue)*100,2) AS top20pct_rev_share
FROM (
    SELECT product_id, SUM(total_revenue) AS revenue,
           ROW_NUMBER() OVER (ORDER BY SUM(total_revenue) DESC) AS rnk
    FROM amazon_sales_clean GROUP BY product_id
) x, (SELECT SUM(total_revenue) AS revenue FROM amazon_sales_clean) t;

/* --- Q32 --------------------------------------------------------
   QUESTION: What is the cumulative revenue run-rate by month?
   INSIGHT: Tracks momentum toward annual targets.
   RECOMMENDATION: Use to set monthly forecasts & alerts.
---------------------------------------------------------------- */
SELECT year_month,
       ROUND(SUM(total_revenue),2) AS monthly_revenue,
       ROUND(SUM(SUM(total_revenue)) OVER (ORDER BY year_month),2) AS cumulative_revenue
FROM amazon_sales_clean GROUP BY year_month ORDER BY year_month;
