-- ----------------------------------------------------------
--    CUSTOMER BEHAVIOUR ANALYSIS 
-- ----------------------------------------------------------

CREATE DATABASE IF NOT EXISTS Customer_behaviour;
USE Customer_behaviour;



-- ----------------------------------------------------------
-- Preview Data
-- ----------------------------------------------------------
SELECT * FROM customer LIMIT 2;

-- Total number of rows
SELECT COUNT(*) FROM customer;

-- ____________________________________________________________________
-- Section 1: Business Overview
-- ----------------------------------------------------------
# Query 1 - Revenue by Gender Category 

SELECT 
    gender, 
    SUM(purchase_amount) AS Revenue
FROM customers
GROUP BY gender;

# Query 2: Revenue by Product Category
 
SELECT
    category,
    COUNT(*) AS Total_orders,
    ROUND(SUM(purchase_amount),2) AS Total_revenue,
    ROUND(AVG(purchase_amount),2) AS Avg_order_value
FROM customers
GROUP BY category
ORDER BY total_revenue DESC;



# Query 3: Revenue by Age Group

SELECT
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END AS age_group,
    COUNT(*) AS customers,
    ROUND(SUM(purchase_amount), 2) AS total_revenue,
    ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM customer
GROUP BY
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        ELSE '46+'
    END
ORDER BY total_revenue DESC;


# Query 4: Customer Segmentation (New, Returning, Loyal)

WITH customer_type AS (
    SELECT 
        customer_id,
        previous_purchases,
        CASE 
            WHEN previous_purchases = 1 THEN 'New'
            WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
            ELSE 'Loyal'
        END AS customer_segment
    FROM customers
)
SELECT 
    customer_segment,
    COUNT(*) AS number_of_customers
FROM customer_type
GROUP BY customer_segment;




-- _________________________________________________________
-- Section 2: Customer Value Analysis
-- ----------------------------------------------------------

-- Query 1: Subscription Impact Analysis

SELECT 
    subscription_status,
    COUNT(customer_id) AS total_customers,
    ROUND(AVG(purchase_amount), 2) AS average_spend,
    SUM(purchase_amount) AS total_revenue
FROM customers
GROUP BY subscription_status
ORDER BY total_revenue DESC, average_spend DESC;


# query 2: Which customers spend more than the average purchase amount?

SELECT 
    customer_id, 
    purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);


-- Q3 : Top Revenue Customers Ranking
#  customers generate the highest revenue, and how do they rank based on spending.

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(purchase_amount) AS total_revenue,
        RANK() OVER(
            ORDER BY SUM(purchase_amount) DESC
        ) AS customer_rank
    FROM customers
    GROUP BY customer_id
)
SELECT *
FROM customer_revenue
WHERE customer_rank <= 10;


-- Query 4 - Customer Lifetime Value (CLV)
# Which customers generate the highest estimated lifetime value?

SELECT
    customer_id,
    ROUND(
        AVG(purchase_amount) *
        MAX(previous_purchases),
        2
    ) AS estimated_clv
FROM customers
GROUP BY customer_id
ORDER BY estimated_clv DESC
LIMIT 10;

-- _______________________________________________________________________
-- Section 3: Customer Retention Analysis 
-- ---------------------------------------------------------

-- Query 1: Subscription Adoption Among Repeat Buyers
SELECT
    subscription_status,
    COUNT(*) AS repeat_buyers,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM customers
WHERE previous_purchases > 5
GROUP BY subscription_status;


-- Query 2 : RFM-Based Customer Segmentation
# Which customers belong to high-value, loyal, and at-risk segments?

WITH customer_rfm AS (
    SELECT
        customer_id,
        SUM(purchase_amount) AS total_spent,
        MAX(previous_purchases) AS purchase_frequency
    FROM customers
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_spent,
    purchase_frequency,
    CASE
        WHEN total_spent >= 500
             AND purchase_frequency >= 20
        THEN 'Champions'

        WHEN total_spent >= 300
        THEN 'Loyal Customers'

        ELSE 'At Risk'
    END AS customer_segment
FROM customer_rfm;


-- Query 3: Churn Risk Analysis
# Which customer groups are at the highest risk of churn?

SELECT
    CASE
        WHEN previous_purchases <= 2
        THEN 'High Risk'

        WHEN previous_purchases <= 10
        THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS churn_risk,

    COUNT(*) AS customers,
    ROUND(AVG(purchase_amount),2) AS avg_spend
FROM customers
GROUP BY churn_risk;


-- _________________________________________________
-- Section 4: Product Performance Analysis
-- -----------------------------------------------

-- Query 1: Top-Rated Products Analysis

SELECT 
    item_purchased,
    COUNT(*) AS total_reviews,
    ROUND(AVG(review_rating),2) AS average_rating
FROM customers
GROUP BY item_purchased
HAVING COUNT(*) >= 5
ORDER BY average_rating DESC, total_reviews DESC
LIMIT 5;


-- Q2: Best-Selling Products

SELECT
    item_purchased,
    COUNT(*) AS total_orders,
    ROUND(SUM(purchase_amount),2) AS total_revenue
FROM customers
GROUP BY item_purchased
ORDER BY total_revenue DESC
LIMIT 10;

-- Q3: Product Revenue vs Customer Rating

SELECT
    item_purchased,
    ROUND(AVG(review_rating),2) AS avg_rating,
    ROUND(SUM(purchase_amount),2) AS revenue
FROM customers
GROUP BY item_purchased
ORDER BY revenue DESC;

-- Query 4: Discount Dependency Analysis

# Which products have the highest percentage of discounted purchases?

SELECT
    item_purchased,
    COUNT(*) AS total_orders,
    ROUND(
        100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS discount_rate
FROM customers
GROUP BY item_purchased
HAVING COUNT(*) >= 10
ORDER BY discount_rate DESC, total_orders DESC
LIMIT 5;


-- __________________________________________________________________________________________________________________



