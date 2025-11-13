-- What’s the distribution of customer tenure (based on account opening date)?

SELECT COUNT(DISTINCT customer_id) AS num_customers, 
CASE 
	WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM date_of_account_opening) <= 5 THEN '0-5 yrs' 
	WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM date_of_account_opening) BETWEEN 6 AND 10 THEN '6-10 yrs' 
	WHEN EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM date_of_account_opening) BETWEEN 11 AND 15 THEN '11-15 yrs' 
	ELSE '>15 yrs' 
END AS customer_tenure 
FROM accounts 
GROUP BY customer_tenure 
ORDER BY num_customers DESC;

-- How many customers have been with the bank for over 5 years?

SELECT COUNT(DISTINCT customer_id) AS num_customers 
FROM accounts
WHERE date_of_account_opening < CURRENT_DATE - INTERVAL '5 YEARS';

-- Which customers haven’t transacted in the last 6 months?

SELECT * FROM
(
SELECT customer_id, MAX(transaction_date) AS last_transaction_date
FROM transactions 
GROUP BY customer_id
) 
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '6 MONTHS';

-- Which branches opened the most accounts in the last 6 months?

SELECT b.branch_id, COUNT(a.date_of_account_opening) AS num_accounts_opened
FROM accounts AS a
INNER JOIN transactions AS b
ON a.customer_id = b.customer_id
WHERE EXTRACT(YEAR FROM date_of_account_opening) = 2022
GROUP BY b.branch_id
ORDER BY num_accounts_opened DESC;

-- How many accounts have had no transactions in the last 6 months?

SELECT COUNT(DISTINCT customer_id)
FROM accounts
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '6 MONTHS';

-- What’s the average balance of dormant accounts?

SELECT COUNT(DISTINCT customer_id) AS num_accounts, 
ROUND(AVG(account_balance),2) AS average_account_balance
FROM accounts
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '6 MONTHS';

-- Which account types are most prone to inactivity?

SELECT account_type, COUNT(DISTINCT customer_id) AS num_inactive_accounts
FROM accounts
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '6 MONTHS'
GROUP BY account_type
ORDER BY num_inactive_accounts DESC;

-- Are certain account types more common in specific branches?

SELECT COUNT(DISTINCT a.customer_id) AS num_accounts, a.account_type, b.branch_id
FROM accounts AS a
INNER JOIN transactions AS b
ON a.customer_id = b.customer_id
GROUP BY a.account_type, b.branch_id
ORDER BY num_accounts;

-- Savings Accounts and Current Account Pivot

SELECT b.branch_id,
SUM(CASE 
	WHEN a.account_type = 'Savings' THEN 1
	ELSE 0
	END) AS savings_accounts,
SUM(CASE 
	WHEN a.account_type = 'Current' THEN 1 
	ELSE 0
	END) AS current_accounts
FROM accounts AS a
LEFT JOIN transactions AS b
ON a.customer_id = b.customer_id
GROUP BY b.branch_id
ORDER BY current_accounts DESC, savings_accounts DESC;	

-- Which branches have the highest number of dormant accounts?

SELECT b.branch_id, COUNT(a.customer_id) AS num_customers FROM accounts AS a
LEFT JOIN transactions AS b
ON a.customer_id = b.customer_id
WHERE last_transaction_date < CURRENT_DATE - INTERVAL '6 MONTHS'
GROUP BY b.branch_id
ORDER BY num_customers DESC;

-- List loans with a term longer than 4 years and interest rate above 10%.
SELECT * FROM loans WHERE loan_term > 48 AND interest_rate >9;

-- List customers who took loans but never made a deposit in the last 6 months.
SELECT a.loan_id, a.customer_id AS loan_cust_id, b.transaction_id, b.transaction_type FROM loans AS a INNER JOIN transactions AS b ON a.customer_id = b.customer_id WHERE transaction_type = 'Deposit' AND transaction_date > CURRENT_DATE - INTERVAL '6 MONTHS';




