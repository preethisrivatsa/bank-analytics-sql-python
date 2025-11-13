-- How many customers do we have in each city?

SELECT city, COUNT(DISTINCT customer_id) AS num_customers FROM customers
GROUP BY city
ORDER BY num_customers DESC;

-- What’s the gender distribution across our customer base?

SELECT gender, COUNT(DISTINCT customer_id) AS num_cust
FROM customers
GROUP BY gender
ORDER BY num_cust DESC;

-- What’s the average age of customers by city?

SELECT city, ROUND(AVG(age)) AS average_age FROM customers
GROUP BY city
ORDER BY average_age DESC;

-- What’s the average age of customers by gender?

SELECT gender, ROUND(AVG(age)) AS average_age FROM customers
GROUP BY gender
ORDER BY average_age DESC;

-- How many unique customers are associated with each branch?

SELECT branch_id, COUNT(DISTINCT customer_id) AS num_customers
FROM transactions
GROUP BY branch_id
ORDER BY num_customers DESC;

-- Which branches serve the most female customers?

SELECT a.branch_id, COUNT(DISTINCT a.customer_id) AS num_female FROM 
transactions AS a
INNER JOIN customers AS b
ON a.customer_id = b.customer_id
WHERE b.gender = 'Female'
GROUP BY a.branch_id
ORDER BY num_female DESC;

-- Who are our top 10 customers by total account balance?

SELECT customer_id, account_balance
FROM accounts
ORDER BY account_balance DESC
LIMIT 10;

-- What’s the average balance per customer?

SELECT customer_id, ROUND(AVG(account_balance),2) AS average_balance
FROM accounts
GROUP BY customer_id 
ORDER BY average_balance DESC;

-- How many customers have balances above 5000?

SELECT COUNT(DISTINCT customer_id) AS cust_more_than_5000 FROM accounts
WHERE account_balance > 5000;

-- How many customers opened accounts in the last 6 months?

SELECT COUNT(DISTINCT customer_id) AS num_customers
FROM accounts
WHERE date_of_account_opening >= CURRENT_DATE - INTERVAL '6 months';

-- What’s the average transaction amount per customer?

SELECT customer_id, ROUND(AVG(transaction_amount),2) AS avg_transaction_amount
FROM transactions
GROUP BY customer_id
ORDER BY avg_transaction_amount DESC;

-- What’s the average balance across all accounts?

SELECT ROUND(AVG(account_balance),2) AS average_balance
FROM accounts;

-- How many accounts have a balance above ₹5000?

SELECT COUNT(DISTINCT customer_id) AS num_accounts_above_5000_balance
FROM accounts
WHERE account_balance >5000;

-- What’s the distribution of account balances (e.g., low, medium, high)?

SELECT
CASE 
	WHEN account_balance < 1000 THEN 'Low'
	WHEN account_balance BETWEEN 1000 AND 5000 THEN 'Medium'
	ELSE 'High'
END AS account_balance_dist,
COUNT(customer_id) AS num_accounts
FROM accounts
GROUP BY account_balance_dist
ORDER BY num_accounts DESC;

-- Which account type is most common?

SELECT account_type, COUNT(DISTINCT customer_id) AS num_accounts
FROM accounts
GROUP BY account_type
ORDER BY num_accounts DESC;

-- What’s the average balance per account type?

SELECT account_type, ROUND(AVG(account_balance),2) AS average_balance_account_type
FROM accounts
GROUP BY account_type
ORDER BY average_balance_account_type DESC;

-- How many accounts were opened each month this year?

SELECT EXTRACT(MONTH FROM date_of_account_opening) AS month,
COUNT(date_of_account_openin) AS num_accounts_opened
FROM accounts
WHERE EXTRACT(YEAR FROM date_of_account_opening) = 2022
GROUP BY month
ORDER BY month;

-- What’s the trend in account openings over time?

SELECT COUNT(date_of_account_opening) AS num_accounts_opened, EXTRACT(YEAR FROM date_of_account_opening) AS year_account_opened
FROM accounts
GROUP BY year_account_opened
ORDER BY year_account_opened;

-- Which account type has the highest average balance?

SELECT account_type, ROUND(AVG(account_balance),2) AS average_balance 
FROM accounts
GROUP BY account_type
ORDER BY average_balance DESC;


