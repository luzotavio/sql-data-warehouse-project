/*
===============================================================================
Exploratory Data Analysis (EDA) - Retail Sales Project
===============================================================================
Objective: 
    Perform a deep dive into the 'gold' layer to extract actionable insights 
    regarding sales performance, customer demographics, and product trends.

Scope:
    - Customer Behavior & Demographics
    - Key Performance Indicators (KPIs)
    - Product Category Analysis
    - Geographical Sales Distribution
    - Top/Bottom Performers

Database: SQL Server / T-SQL compatible
===============================================================================
*/

-------------------------------------------------------------------------------
-- 1. BASELINE CUSTOMER REACH
-------------------------------------------------------------------------------
-- Objective: Calculate the total volume of unique customers who have made purchases.
-- Business Insight: Establishes the actual size of the active customer base.

SELECT 
    COUNT(DISTINCT customer_key) AS total_unique_customers
FROM gold.fact_sales;


-------------------------------------------------------------------------------
-- 2. EXECUTIVE SUMMARY (KPI DASHBOARD)
-------------------------------------------------------------------------------
-- Objective: Consolidate high-level metrics into a single tabular view.
-- Business Insight: Provides a "Quick Health Check" for the business, 
-- covering revenue, volume, and inventory variety.

SELECT 
    'Total Sales Revenue' AS measure_name,
    SUM(sales_amount)     AS measure_value 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Quantity Sold' AS measure_name,
    SUM(quantity)         AS measure_value 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Average Sales Price' AS measure_name, 
    AVG(sales_amount)     AS measure_value 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Orders Placed' AS measure_name, 
    COUNT(DISTINCT order_number) AS measure_value 
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Unique Products' AS measure_name, 
    COUNT(product_key)      AS measure_value 
FROM gold.dim_products

UNION ALL

SELECT 
    'Total Registered Customers' AS measure_name, 
    COUNT(customer_key)          AS measure_value 
FROM gold.dim_customers;


-------------------------------------------------------------------------------
-- 3. GEOGRAPHICAL SEGMENTATION
-------------------------------------------------------------------------------
-- Objective: Identify customer density across different countries.
-- Business Insight: Helps prioritize regions for logistics and marketing focus.

SELECT 
    country, 
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY 
    country
ORDER BY 
    total_customers DESC;


-------------------------------------------------------------------------------
-- 4. DEMOGRAPHIC ANALYSIS (GENDER)
-------------------------------------------------------------------------------
-- Objective: Breakdown the customer base by gender.
-- Business Insight: Informs product development and personalized communication strategies.

SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY 
    gender
ORDER BY 
    total_customers DESC;


-------------------------------------------------------------------------------
-- 5. PRODUCT CATEGORY DISTRIBUTION
-------------------------------------------------------------------------------
-- Objective: Analyze the variety of products within each category.
-- Business Insight: Visualizes the breadth and depth of the current catalog.

SELECT 
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY 
    category
ORDER BY 
    total_products DESC;


-------------------------------------------------------------------------------
-- 6. COST STRUCTURE BY CATEGORY
-------------------------------------------------------------------------------
-- Objective: Calculate the average manufacturing/acquisition cost per category.
-- Business Insight: Evaluates capital tied up in stock and average unit cost trends.

SELECT 
    category,
    AVG(cost) AS avg_product_cost
FROM gold.dim_products
GROUP BY 
    category
ORDER BY 
    avg_product_cost DESC;


-------------------------------------------------------------------------------
-- 7. REVENUE BY PRODUCT CATEGORY
-------------------------------------------------------------------------------
-- Objective: Correlate sales volume with product categories to find top earners.
-- Business Insight: Identifies the most profitable segments of the business.

SELECT 
    dp.category,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.category
ORDER BY 
    total_revenue DESC;


-------------------------------------------------------------------------------
-- 8. CUSTOMER PROFITABILITY RANKING
-------------------------------------------------------------------------------
-- Objective: Rank customers based on their total historical spend.
-- Business Insight: Enables targeted loyalty programs for "Whale" or VIP customers.

SELECT 
    dc.customer_number,
    dc.first_name,
    dc.lastname,
    SUM(fs.sales_amount) AS total_lifetime_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.customer_number, 
    dc.first_name, 
    dc.lastname
ORDER BY 
    total_lifetime_revenue DESC;


-------------------------------------------------------------------------------
-- 9. SALES VOLUME BY GEOGRAPHY
-------------------------------------------------------------------------------
-- Objective: Quantify the total number of items sold per country.
-- Business Insight: Highlights physical demand, independent of currency value.

SELECT 
    dc.country,
    SUM(fs.quantity) AS total_quantity_sold
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_customers AS dc
    ON fs.customer_key = dc.customer_key
GROUP BY 
    dc.country
ORDER BY 
    total_quantity_sold DESC;


-------------------------------------------------------------------------------
-- 10. BEST SELLERS (TOP 5 PRODUCTS BY REVENUE)
-------------------------------------------------------------------------------
-- Objective: List the top 5 individual products driving the most revenue.
-- Business Insight: Focus on high-impact products for inventory replenishment.

SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.product_name
ORDER BY 
    total_revenue DESC;


-------------------------------------------------------------------------------
-- 11. LOW PERFORMERS (BOTTOM 5 PRODUCTS BY REVENUE)
-------------------------------------------------------------------------------
-- Objective: Identify products with the lowest financial contribution.
-- Business Insight: Highlights potential stock to be liquidated or discontinued.

SELECT TOP 5
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales AS fs
LEFT JOIN gold.dim_products AS dp
    ON dp.product_key = fs.product_key
GROUP BY 
    dp.product_name
ORDER BY 
    total_revenue ASC;
