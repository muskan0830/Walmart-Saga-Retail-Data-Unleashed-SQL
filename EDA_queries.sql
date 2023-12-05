SELECT * FROM walmart_sales

-- explore unique elemennts in columns
SELECT DISTINCT branch FROM walmart_sales

SELECT DISTINCT city FROM walmart_Sales

SELECT DISTINCT customer_type FROM walmart_sales

SELECT DISTINCT gender FROM walmart_sales

SELECT DISTINCT product_line FROM walmart_sales

-- Add a column for month

ALTER TABLE walmart_sales
ADD COLUMN month VARCHAR(20); 
UPDATE walmart_sales
SET month = TO_CHAR(date, 'Month');

-- Add a column for week of the month

ALTER TABLE walmart_sales
ADD COLUMN week_of_month VARCHAR(20); 
UPDATE walmart_sales
SET week_of_month = EXTRACT(WEEK FROM date) - EXTRACT(WEEK FROM DATE_TRUNC('MONTH', date)) + 1;

--Add a column for time of the day

ALTER TABLE walmart_sales
ADD COLUMN time_of_day VARCHAR(20); 
UPDATE walmart_sales
SET time_of_day = CASE 
                    WHEN EXTRACT(HOUR FROM time) >= 5 AND EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
                    WHEN EXTRACT(HOUR FROM time) >= 12 AND EXTRACT(HOUR FROM time) < 17 THEN 'Afternoon'
                    WHEN EXTRACT(HOUR FROM time) >= 17 AND EXTRACT(HOUR FROM time) < 21 THEN 'Evening'
                    ELSE 'Night'
				  END;
				  
-- Add a column for the days

ALTER TABLE walmart_sales
ADD COLUMN day VARCHAR(20); 
UPDATE walmart_sales
SET day =  TO_CHAR(date, 'Day')
			  
-- ANALYSIS
--1. SALES, REVENUE and PROFIT ANALYSIS

--a. total revenue, profit and sales
SELECT 
       SUM(total) AS total_revenue,
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
-- TOTAL REVENUE: 322966.7490, total sales: 307587.38, total profit: 15379.3690

--b. total revenue,profit and sales by branch
SELECT 
       branch,
	   SUM(total) AS total_revenue,
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY branch
ORDER BY SUM(total) DESC
-- Branch C is at top whereas Branch B is at the bottom.

--c. total revenue, profit and sales by productline
SELECT 
      product_line,
	  SUM(total) AS total_revenue, 
	  SUM(gross_income) AS total_profit,
	  SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY product_line
ORDER BY SUM(total) DESC
--Food and Beverages is leading while health and beauty generated least total revenue

--d. total revenue, profit and sales by city
SELECT 
      city,
	  SUM(total) AS total_revenue,
	  SUM(gross_income) AS total_profit,
	  SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY city
ORDER BY SUM(total) DESC
--Naypyitaw-top, Mandalay-bottom, Yangon and Mandalay doesn't have significant difference in the total revenue

--e. Revenue, profit and sales over time (Time series analysis)
SELECT 
      month,
	  SUM(total) AS total_revenue,
	  SUM(gross_income) AS total_profit,
	  SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY month
ORDER BY SUM(total) DESC
-- january is leading, feb generated least

--f. average transaction value
SELECT
  AVG(total) AS average_transaction_value
FROM walmart_sales;
-- ATV: 322.97

--g. total revenue, profit,sales by customer_type
SELECT 
       customer_type,
	   SUM(total) AS total_revenue,
	   SUM(gross_income) AS total_profit,
	  SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY customer_type
ORDER BY SUM(total) DESC
-- Members contribute significantly more as compared to non-member customers.

--h. Product Contribution Margin:
-- Analyze the profitability of individual products by calculating the contribution margin.
-- Contribution Margin (%) = [(Revenue - Cost of Goods Sold) / Revenue]*100
SELECT
  product_line,
  AVG((total - cogs) / total) * 100 AS contribution_margin
FROM walmart_sales
GROUP BY product_line;

--i. total revenue, profit, sales by payment
SELECT 
       payment,
	   SUM(total) AS total_revenue,
	   SUM(gross_income) AS total_profit,
	  SUM(unit_price*quantity) AS total_sales
FROM walmart_sales
GROUP BY payment
ORDER BY SUM(total) DESC
--customers prefer cash over credit card and e-wallet

--2. CUSTOMER SEGMENTATION
-- a. Demographic segmentation
SELECT
  gender,
  customer_type,
  COUNT(*) AS customer_count
FROM walmart_sales
GROUP BY gender, customer_type
ORDER BY customer_count DESC;
--Females have most membership while no. of the normal customers are more men

--b. Geographic segmentation
SELECT
  city, branch,
  COUNT(*) AS customer_count
FROM walmart_sales
GROUP BY city, branch
ORDER BY customer_count DESC;
-- Yangon, branch A has most no. of customers

--c. loyalty segmentation
SELECT
  CASE 
    WHEN rating BETWEEN 4 AND 6 THEN 'Poor rating'
    WHEN rating BETWEEN 6 AND 8 THEN 'Average rating'
    ELSE 'High rating'
  END AS "Rating_performance",
  customer_type,
  COUNT(*) AS customer_count
FROM walmart_sales
WHERE rating IS NOT NULL
GROUP BY customer_type, "Rating_performance"
ORDER BY customer_count DESC;
--Regular customers tended to provide average ratings, while those with memberships often gave lower ratings. 
--However, a greater number of members gave high ratings compared to non-members.


--TIME ANALYSIS
--a. monthly analysis
SELECT month, 
       SUM(total) AS total_revenue, 
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales,
	   COUNT(*) AS customer_count,
	   SUM(quantity) AS total_items_sold,
	   SUM(cogs) AS total_cost_of_goods_sold
FROM walmart_sales
GROUP BY month
ORDER BY total_revenue DESC;
--january at the top while feb at the bottom

--b. daily analysis
SELECT day,
       SUM(total) AS total_revenue, 
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales,
	   COUNT(*) AS customer_count,
	   SUM(quantity) AS total_items_sold,
	   SUM(cogs) AS total_cost_of_goods_sold
FROM walmart_sales
GROUP BY day
ORDER BY total_revenue DESC;
--saturday - highest , tuesday - second highest, wed and mon at bottom

--c. week_of_month analysis
SELECT week_of_month,
       SUM(total) AS total_revenue, 
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales,
	   COUNT(*) AS customer_count,
	   SUM(quantity) AS total_items_sold,
	   SUM(cogs) AS total_cost_of_goods_sold
FROM walmart_sales
GROUP BY week_of_month
ORDER BY total_revenue DESC;
--2nd week of month- highest while 1st week of month-least

-- d. time_of_day analysis
SELECT time_of_day,
       SUM(total) AS total_revenue, 
	   SUM(gross_income) AS total_profit,
	   SUM(unit_price*quantity) AS total_sales,
	   COUNT(*) AS customer_count,
	   SUM(quantity) AS total_items_sold,
	   SUM(cogs) AS total_cost_of_goods_sold
FROM walmart_sales
GROUP BY time_of_day
ORDER BY total_revenue DESC;
--afternoon-highest and morning-least

--saving the file
COPY walmart_sales TO 'D:\MY-DATA\PROFESSION\POWERBI\updated_walmart_sales.csv' WITH CSV HEADER;
