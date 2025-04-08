-- PRODUCT ANALYSIS

-- How many unique product lines does the data have?
SELECT COUNT( DISTINCT `Product line`) FROM walmartdata;

-- What is the most common payment method?
SELECT payment,COUNT(payment) noofpayments FROM walmartdata
GROUP BY payment ORDER BY noofpayments DESC LIMIT 1;

-- What is the most selling product line?
SELECT `Product line`,COUNT(*) eachproductlinecount FROM walmartdata
GROUP BY `Product line` ORDER BY eachproductlinecount DESC LIMIT 1;

-- What is the total revenue by month?
SELECT MONTHNAME(date) months,
ROUND(SUM(total),2) revenue
FROM walmartdata
GROUP BY MONTH(date),MONTHNAME(date)
ORDER BY MONTH(date) ASC;

-- What month had the largest COGS?
SELECT MONTHNAME(date),
cogs FROM walmartdata
ORDER BY cogs DESC LIMIT 1;

-- What product line had the largest revenue?
SELECT `product line`,
ROUND(SUM(total),2) Revenue 
FROM walmartdata
GROUP BY `product line`
ORDER BY revenue DESC LIMIT 1;

-- What is the city with the largest revenue?
SELECT city,
ROUND(SUM(total),2) Revenue 
FROM walmartdata
GROUP BY city
ORDER BY revenue DESC LIMIT 1;

-- What product line had the largest VAT?
SELECT `product line`,
`tax 5%` vat
FROM walmartdata
ORDER BY vat DESC LIMIT 1;

-- Fetch each product line and add a column to those product line showing
-- "Good", "Bad". Good if its greater than average sales

WITH totalsales 
AS ( SELECT `product line` p_line,
     SUM(total) totalsales
     FROM walmartdata
     GROUP BY `product line` )
,avgsales 
AS ( SELECT ROUND(AVG(totalsales),2) avgs
     FROM totalsales )
SELECT t.p_line,
CASE WHEN t.totalsales > avgs THEN "good" ELSE "bad" 
END AS category
FROM avgsales a JOIN totalsales t;

-- Which branch sold more products than average product sold?
WITH branch_sold_quantity
AS ( SELECT branch,
     SUM(quantity) quantitysold
     FROM walmartdata
     GROUP BY branch )
,avg_product_sold
AS ( SELECT AVG(quantitysold) avgsold
     FROM branch_sold_quantity )
SELECT b.branch ,b.quantitysold
FROM branch_sold_quantity b
JOIN avg_product_sold a
WHERE b.quantitysold > a.avgsold;

-- What is the most common product line by gender?
SELECT gender ,`product line`,
COUNT(*) totalcount
FROM walmartdata 
GROUP BY gender,`product line`
ORDER BY totalcount DESC LIMIT 1;

WITH product_line_counts AS (
    SELECT gender, `product line`, COUNT(*) AS totalcount
    FROM walmartdata
    GROUP BY gender, `product line`
)
SELECT gender, `product line`, totalcount
FROM product_line_counts p
WHERE totalcount = (
    SELECT MAX(totalcount) 
    FROM product_line_counts 
    WHERE gender = p.gender
);

-- What is the average rating of each product line?
SELECT `product line`,
ROUND(AVG(rating),2) avg_rating
FROM walmartdata
GROUP BY `product line` ;

-- SALES ANALYSIS

-- Number of sales made in each time of the day per weekday

WITH weekdaydata AS (
  SELECT  
    WEEKDAY(STR_TO_DATE(date, "%Y-%m-%d")) AS weekday,
    TIME_FORMAT(STR_TO_DATE(time, "%H:%i"), "%H:%i") AS time,
    `invoice id` AS id
  FROM walmartdata
)
SELECT 
  weekday,
  COUNT(CASE WHEN time BETWEEN '06:00' AND '11:59' THEN id END) AS Morning,
  COUNT(CASE WHEN time BETWEEN '12:00' AND '17:59' THEN id END) AS Afternoon,
  COUNT(CASE WHEN time BETWEEN '18:00' AND '21:59' THEN id END) AS Evening,
  COUNT(CASE WHEN time BETWEEN '22:00' AND '23:59' OR time BETWEEN '00:00' AND '05:59' THEN id END) AS Night
FROM weekdaydata
GROUP BY weekday
ORDER BY weekday;

-- Which of the customer types brings the most revenue?
SELECT `customer type` ,
ROUND(SUM(total),2) rev
FROM walmartdata
GROUP BY `customer type`
ORDER BY rev DESC ;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city,MAX(`tax 5%`)
FROM walmartdata
GROUP BY city
ORDER BY MAX(`tax 5%`) DESC;

-- Which customer type pays the most in VAT?

SELECT `customer type` ,
ROUND(SUM(`tax 5%`*cogs),1) AS vat
FROM walmartdata
GROUP BY `customer type`
ORDER BY vat DESC;

-- customer analysis
-- How many unique customer types does the data have?
SELECT DISTINCT `customer type` FROM walmartdata;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment FROM walmartdata;

-- What is the most common customer type?
SELECT `customer type`,
COUNT(*) count 
FROM walmartdata
GROUP BY `customer type` 
ORDER BY count DESC 
LIMIT 1;


-- What is the gender of most of the customers?
SELECT gender ,
COUNT(*) count 
FROM walmartdata
GROUP BY gender 
ORDER BY count DESC 
LIMIT 1;

-- What is the gender distribution per branch?
SELECT gender,branch,
COUNT(*) count
FROM walmartdata
GROUP BY gender,branch;
--  SECOND WAY
SELECT gender,
SUM(CASE WHEN branch = 'A' THEN 1 ELSE 0 END) AS 'BRANCH-A',
SUM(CASE WHEN branch = 'B' THEN 1 ELSE 0  END) AS 'BRANCH-B',
SUM(CASE WHEN branch = 'C' THEN 1 ELSE 0  END) AS 'BRANCH-C'
FROM walmartdata
GROUP BY gender;

-- Which time of the day do customers give most ratings?

WITH timeday AS (
  SELECT  
    TIME_FORMAT(STR_TO_DATE(time, "%H:%i"), "%H:%i") AS time,
    rating 
  FROM walmartdata
)
, bucket 
AS ( SELECT rating , 
        CASE WHEN time BETWEEN '06:00' AND '11:59' THEN  'Morning'
             WHEN time BETWEEN '12:00' AND '17:59' THEN  'afternoon'
             WHEN time BETWEEN '18:00' AND '21:59' THEN  'Evening'
	         WHEN time BETWEEN '22:00' AND '23:59' OR time BETWEEN '00:00' AND '05:59' THEN 'Night'
        END AS Time_bucket
        FROM timeday )
SELECT time_bucket,COUNT(*) FROM bucket GROUP BY time_bucket;

-- Which time of the day do customers give most ratings per branch?
WITH timeday AS (
  SELECT  
    TIME_FORMAT(STR_TO_DATE(time, "%H:%i"), "%H:%i") AS time,
    rating ,branch
  FROM walmartdata
)
, bucket 
AS ( SELECT rating , branch,
        CASE WHEN time BETWEEN '06:00' AND '11:59' THEN  'Morning'
             WHEN time BETWEEN '12:00' AND '17:59' THEN  'afternoon'
             WHEN time BETWEEN '18:00' AND '21:59' THEN  'Evening'
	         WHEN time BETWEEN '22:00' AND '23:59' OR time BETWEEN '00:00' AND '05:59' THEN 'Night'
        END AS Time_bucket
        FROM timeday )
SELECT time_bucket,
SUM(CASE WHEN branch = 'A' THEN 1 ELSE 0 END) AS 'branch-A',
SUM(CASE WHEN branch = 'B' THEN 1 ELSE 0 END) AS 'branch-B',
SUM(CASE WHEN branch = 'C' THEN 1 ELSE 0 END) AS 'branch-C'
FROM bucket GROUP BY time_bucket;



-- Which day fo the week has the best avg ratings?
SELECT t.weekday,
 ROUND(AVG(t.rating),2) weekdayrating
			 FROM ( SELECT WEEKDAY(STR_TO_DATE(date, "%Y-%m-%d")) AS weekday,
				    rating
                    FROM walmartdata ) t
                    GROUP BY t.weekday
                    ORDER BY weekdayrating DESC;



