CREATE TABLE orders (
    row_id INT,
    order_id TEXT,
    order_date DATE,
    ship_date DATE,
    ship_mode TEXT,
    customer_id TEXT,
    customer_name TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales NUMERIC,
    quantity INT,
    discount NUMERIC,
    profit NUMERIC
);

CREATE TABLE returns (
    returned TEXT,
    order_id TEXT
);





--Duplicate Checks

SELECT * FROM orders
WHERE row_id NOT IN (
    SELECT MIN(row_id)
    FROM orders
    GROUP BY order_id, product_id, sales, quantity
)

DELETE FROM orders
WHERE row_id NOT IN (
    SELECT MIN(row_id)
    FROM orders
    GROUP BY order_id, product_id, sales, quantity
);


--Missing value check
SELECT 
COUNT(*) FILTER (WHERE sales IS NULL) AS sales_nulls,
COUNT(*) FILTER (WHERE profit IS NULL) AS profit_nulls,
COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulls,
COUNT(*) FILTER (WHERE region IS NULL) AS region_nulls
FROM orders;

--Logical issues check
SELECT *
FROM orders
WHERE quantity <= 0
OR discount < 0


--Negative Sales Check
SELECT * FROM orders
WHERE sales <= 0;



--outlier checks
SELECT 
MIN(sales) AS min_sales,
MAX(sales) AS max_sales,
MIN(profit) AS min_profit,
MAX(profit) AS max_profit,
MIN(quantity) AS min_quantity,
MAX(quantity) AS max_quantity
FROM orders




--1 Demand analysis

CREATE TABLE demand_by_region AS(
SELECT region,
       SUM(sales) AS total_sales,
       COUNT(DISTINCT order_id) AS total_orders,
	   SUM(sales)/COUNT(DISTINCT order_id) as aov
FROM orders
GROUP BY region
)


	
--2 Profitabilty

CREATE TABLE profitability_by_region AS(
SELECT region,
       SUM(sales) AS total_sales,
       SUM(profit)/NULLIF(SUM(sales),0)*100 AS profit_margin
FROM orders
GROUP BY region
)





--3 discount analysis
CREATE TABLE discount_analysis AS(
SELECT 
    region,
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount > 0 AND discount <= 0.2 THEN 'Low Discount'
        WHEN discount > 0.2 AND discount <= 0.4 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_level,
    SUM(sales) AS total_sales,
    SUM(profit)/NULLIF(SUM(sales),0)*100 AS profit_margin
FROM orders
GROUP BY region, discount_level
ORDER BY region, discount_level
)



--4 category_performance

CREATE TABLE category_performance AS (
SELECT region,
       category,
       SUM(sales) AS total_sales,
       SUM(profit)/NULLIF(SUM(sales),0)*100 AS profit_margin
FROM orders
GROUP BY region, category
)






--5 return analysis

CREATE TABLE return_analysis AS(
SELECT o.region,
	   o.category,
       COUNT(DISTINCT r.order_id)::NUMERIC /
       COUNT(DISTINCT o.order_id) * 100 AS return_rate,
       SUM(CASE WHEN r.order_id IS NOT NULL THEN sales END) AS returned_revenue
FROM orders o
LEFT JOIN returns r
ON o.order_id = r.order_id
GROUP BY o.category, o.region
ORDER BY return_rate DESC
)


--Final analysis ready tables

SELECT*
FROM demand_by_region
SELECT*
FROM profitability_by_region
SELECT*
FROM discount_analysis
SELECT*
FROM category_performance
SELECT*
FROM return_rate_region
SELECT*
FROM return_rate_category




















