use project;
select * from walmartsalesdata;
/* Task 1  Identifying the Top Branch by Sales Growth Rate*/
SELECT Branch, 
       MONTH(`Date`) AS Month, 
       YEAR(`Date`) AS Year, 
       SUM(Total) AS MonthlySales,
       LAG(SUM(Total)) OVER (PARTITION BY Branch ORDER BY YEAR(`Date`), MONTH(`Date`)) AS PreviousMonthSales,
       ((SUM(Total) - LAG(SUM(Total)) OVER (PARTITION BY Branch ORDER BY YEAR(`Date`), MONTH(`Date`))) / 
        LAG(SUM(Total)) OVER (PARTITION BY Branch ORDER BY YEAR(`Date`), MONTH(`Date`))) * 100 AS GrowthRate
FROM walmartsalesdata
GROUP BY Branch, YEAR(`Date`), MONTH(`Date`)
ORDER BY GrowthRate DESC;


/* Task 2 Finding the Most Profitable Product Line for Each Branch*/

WITH ProfitByProductLine AS (
    SELECT Branch, 
           `Product line`, 
           SUM(`gross income` - cogs) AS TotalProfit
    FROM walmartsalesdata
    GROUP BY Branch, `Product line`
)
SELECT Branch, `Product line`, TotalProfit
FROM ProfitByProductLine
WHERE (Branch, TotalProfit) IN (
    SELECT Branch, MAX(TotalProfit)
    FROM ProfitByProductLine
    GROUP BY Branch
);

/* Task 3  Analyzing Customer Segmentation Based on Spending */

SELECT `Invoice ID`, 
       SUM(Total) AS TotalSpent,
       CASE 
           WHEN SUM(Total) > 800 THEN 'High Spender'
           WHEN SUM(Total) BETWEEN 500 AND 800 THEN 'Medium Spender'
           ELSE 'Low Spender'
       END AS SpendingCategory
FROM walmartsalesdata
GROUP BY `Invoice ID`;

/* Task 4  Detecting Anomalies in Sales Transactions*/
SELECT `Invoice ID`, `Product line`, Total,
       (SELECT AVG(Total) 
        FROM walmartsalesdata AS sub 
        WHERE sub.`Product line` = walmartsalesdata.`Product line`) AS AvgSales,
       CASE 
           WHEN Total > (SELECT AVG(Total) * 1.5 
                              FROM walmartsalesdata AS sub 
                              WHERE sub.`Product line` = walmartsalesdata.`Product line`) 
                THEN 'High Anomaly'
           WHEN Total < (SELECT AVG(Total) * 0.5 
                              FROM walmartsalesdata AS sub 
                              WHERE sub.`Product line` = walmartsalesdata.`Product line`) 
                THEN 'Low Anomaly'
           ELSE 'Normal'
END AS AnomalyStatus
FROM walmartsalesdata;


/* Task 5 Most Popular Payment Method by City*/
WITH PaymentCountByCity AS (
    SELECT City, 
           Payment, 
           COUNT(*) AS PaymentCount
    FROM walmartsalesdata
    GROUP BY City, Payment
),
TopPaymentMethodByCity AS (
    SELECT City, 
           Payment, 
           PaymentCount,
           RANK() OVER (PARTITION BY City ORDER BY PaymentCount DESC) AS PaymentRank
    FROM PaymentCountByCity
)
SELECT City, 
       Payment, 
       PaymentCount
FROM TopPaymentMethodByCity
WHERE PaymentRank = 1
ORDER BY City;


/* Task 6 Monthly Sales Distribution by Gender*/

SELECT Gender, 
       MONTH(`Date`) AS Month, 
       YEAR(`Date`) AS Year, 
       SUM(Total) AS MonthlySales
FROM walmartsalesdata
GROUP BY Gender, YEAR(`Date`), MONTH(`Date`)
ORDER BY YEAR(`Date`), MONTH(`Date`), Gender;


/* Task 7 Best Product Line by Customer Type*/
SELECT `Customer type`, `Product line`, 
       SUM(Total) AS TotalSales
FROM walmartsalesdata
GROUP BY `Customer type`, `Product line`
ORDER BY `Customer type`, TotalSales DESC;

/* Task 8  Identifying Repeat Customers */
SELECT `Invoice ID`, COUNT(*) AS PurchaseCount
FROM walmartsalesdata
GROUP BY `Invoice ID`
HAVING MIN(`Date`) <= DATE_ADD(MAX(`Date`), INTERVAL -30 DAY);

/* Task 9  Finding Top 5 Customers by Sales Volume*/

SELECT `Invoice ID`, 
       SUM(Total) AS TotalSpent
FROM walmartsalesdata
GROUP BY `Invoice ID`
ORDER BY TotalSpent DESC
LIMIT 5;


/* Task 10  Analyzing Sales Trends by Day of the Week */

SELECT DAYOFWEEK(Date) AS DayOfWeek, 
       SUM(Total) AS TotalSales
FROM walmartsalesdata
GROUP BY DAYOFWEEK(Date)
ORDER BY TotalSales DESC;








