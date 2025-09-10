-- =============================
-- SQL Queries for Shopify Orders Analysis
-- =============================

-- 1. Total revenue by payment gateway
SELECT Gateway, 
       SUM(Total_Price_Usd) AS Total_Revenue
FROM Orders
GROUP BY Gateway
ORDER BY Total_Revenue DESC;

-- 2. Number of distinct orders by state/province
SELECT Billing_Address_Province, 
       COUNT(DISTINCT Order_Number) AS Orders
FROM Orders
GROUP BY Billing_Address_Province
ORDER BY Orders DESC;

-- 3. Top 5 cities by total revenue
SELECT CITY, 
       SUM(Total_Price_Usd) AS Total_Revenue
FROM Orders
GROUP BY CITY
ORDER BY Total_Revenue DESC
LIMIT 5;

-- 4. Customer lifetime value (CLV) approximation
SELECT Customer_Id, 
       SUM(Total_Price_Usd) AS Customer_Revenue, 
       COUNT(DISTINCT Order_Number) AS Orders,
       ROUND(SUM(Total_Price_Usd) / COUNT(DISTINCT Order_Number), 2) AS Avg_Order_Value
FROM Orders
GROUP BY Customer_Id
ORDER BY Customer_Revenue DESC;

-- 5. Revenue by product type and payment gateway
SELECT Product_Type, Gateway, 
       SUM(Quantity) AS Total_Quantity, 
       SUM(Total_Price_Usd) AS Total_Revenue
FROM Orders
GROUP BY Product_Type, Gateway
ORDER BY Total_Revenue DESC;

-- 6. Year-over-Year revenue trend
SELECT YEAR(Invoice_Date) AS Year, 
       SUM(Total_Price_Usd) AS Total_Revenue
FROM Orders
GROUP BY YEAR(Invoice_Date)
ORDER BY Year;

-- 7. Top 10 customers by spending
SELECT Customer_Id, 
       SUM(Quantity) AS Total_Quantity, 
       SUM(Total_Price_Usd) AS Total_Spent
FROM Orders
GROUP BY Customer_Id
ORDER BY Total_Spent DESC
LIMIT 10;

-- 8. Hourly sales trend
SELECT EXTRACT(HOUR FROM Invoice_Date) AS Hour, 
       COUNT(Order_Number) AS Total_Orders,
       SUM(Total_Price_Usd) AS Total_Revenue
FROM Orders
GROUP BY EXTRACT(HOUR FROM Invoice_Date)
ORDER BY Hour;

-- 9. Average order value by state/province
SELECT Billing_Address_Province, 
       ROUND(SUM(Total_Price_Usd) / COUNT(DISTINCT Order_Number), 2) AS Avg_Order_Value
FROM Orders
GROUP BY Billing_Address_Province
ORDER BY Avg_Order_Value DESC;

-- 10. Product type contribution to total revenue (%)
SELECT Product_Type,
       SUM(Total_Price_Usd) AS Revenue,
       ROUND(100.0 * SUM(Total_Price_Usd) / (SELECT SUM(Total_Price_Usd) FROM Orders), 2) AS Revenue_Share_Percent
FROM Orders
GROUP BY Product_Type
ORDER BY Revenue DESC;

-- 11. Customer retention analysis: number of repeat vs single-order customers
SELECT CASE 
           WHEN Order_Count = 1 THEN 'Single Order'
           ELSE 'Repeat Customer'
       END AS Customer_Type,
       COUNT(*) AS Num_Customers,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(DISTINCT Customer_Id) FROM (
                                     SELECT Customer_Id, COUNT(DISTINCT Order_Number) AS Order_Count
                                     FROM Orders
                                     GROUP BY Customer_Id
                                 ) t), 2) AS Percent_Share
FROM (
    SELECT Customer_Id, COUNT(DISTINCT Order_Number) AS Order_Count
    FROM Orders
    GROUP BY Customer_Id
) sub
GROUP BY Customer_Type;

-- 12. RFM Analysis (Recency, Frequency, Monetary)
-- Recency: days since last order
-- Frequency: number of orders
-- Monetary: total spent
SELECT Customer_Id,
       DATEDIFF(DAY, MAX(Invoice_Date), GETDATE()) AS Recency,
       COUNT(DISTINCT Order_Number) AS Frequency,
       SUM(Total_Price_Usd) AS Monetary
FROM Orders
GROUP BY Customer_Id
ORDER BY Monetary DESC;
