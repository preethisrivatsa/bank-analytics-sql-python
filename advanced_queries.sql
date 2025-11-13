-- Identify the top 5 customers per branch by total account balance.

WITH c AS (SELECT a.customer_id, a.account_balance, b.branch_id,
DENSE_RANK() OVER(PARTITION BY branch_id ORDER BY account_balance DESC) AS rank_cust
FROM accounts AS a
INNER JOIN transactions AS b
ON a.customer_id = b.customer_id)

SELECT customer_id, account_balance, branch_id FROM c
WHERE rank_cust BETWEEN 1 AND 5;

-- Rank customers by transaction volume within each account type.

-- Number of transactions
With c AS (SELECT a.customer_id, COUNT(DISTINCT a.transaction_id) AS num_transactions,
b.account_type,
DENSE_RANK() OVER(PARTITION BY b.account_type ORDER BY COUNT(DISTINCT a.transaction_id) DESC) AS rank_cust
FROM transactions AS a
INNER JOIN accounts AS b
ON a.customer_id = b.customer_id
GROUP BY a.customer_id, b.account_type)

SELECT customer_id, num_transactions, account_type
FROM c
WHERE rank_cust BETWEEN 1 AND 5;

-- Sum of transactions
WITH c AS (SELECT a.customer_id, SUM(a.transaction_amount) AS sum_transactions,
b.account_type,
DENSE_RANK() OVER(PARTITION BY b.account_type ORDER BY SUM(a.transaction_amount) DESC) AS rank_cust
FROM transactions AS a
INNER JOIN accounts AS b
ON a.customer_id = b.customer_id
GROUP BY a.customer_id, b.account_type)

SELECT customer_id, sum_transactions, account_type
FROM c
WHERE rank_cust BETWEEN 1 AND 5;

-- Compute the month-over-month growth rate in total deposits.

WITH a AS (SELECT EXTRACT(YEAR FROM transaction_date) AS year,
EXTRACT(MONTH FROM transaction_date) AS month,
SUM(transaction_amount) AS total_amount_deposited
FROM transactions
WHERE transaction_type = 'Deposit'
GROUP BY year, month)

SELECT a.*,
LAG(total_amount_deposited,1) OVER(PARTITION BY year ORDER BY month) AS prior_month_amount_deposited,
ROUND(((total_amount_deposited - LAG(total_amount_deposited,1) OVER(PARTITION BY year ORDER BY month))/LAG(total_amount_deposited,1) OVER(PARTITION BY year ORDER BY month))*100,2) AS growth_rate
FROM a;

-- Find the running total of withdrawals per customer, ordered by transaction date.

SELECT customer_id, transaction_date, transaction_amount,
SUM(transaction_amount) OVER(PARTITION BY customer_id ORDER BY transaction_date) AS transaction_amount_running_total
FROM transactions
WHERE transaction_type = 'Withdrawal';

-- Identify the quarter in which each branch had its peak transaction volume.

WITH a AS(SELECT 
EXTRACT(YEAR FROM transaction_date) AS year,
EXTRACT(MONTH FROM transaction_date) AS month,
CASE 
	WHEN EXTRACT(MONTH FROM transaction_date) BETWEEN 1 AND 3 THEN 'Q1'
	WHEN EXTRACT(MONTH FROM transaction_date) BETWEEN 4 AND 6 THEN 'Q2'
	WHEN EXTRACT(MONTH FROM transaction_date) BETWEEN 7 AND 9 THEN 'Q3'
	ELSE 'Q4'
END AS quarter,
branch_id, transaction_amount
FROM transactions),

b AS (SELECT a.year, a.quarter, a.branch_id, SUM(a.transaction_amount) AS total_transac_amount,
DENSE_RANK()OVER(PARTITION BY a.branch_id ORDER BY SUM(a.transaction_amount) DESC) AS branch_rank
FROM a
GROUP BY a.year, a.quarter, a.branch_id)

SELECT year, quarter, branch_id, total_transac_amount FROM b
WHERE branch_rank =1;

-- Determine the average balance per account type over a rolling 3-month window.

WITH a AS (SELECT EXTRACT(YEAR FROM a.transaction_date) AS year,
EXTRACT(MONTH FROM a.transaction_date) AS month,
AVG(a.account_balance_after_transaction) AS avg_balance, b.account_type
FROM transactions AS a
INNER JOIN accounts AS b
ON a.customer_id = b.customer_id
GROUP BY year, month, account_type)

SELECT year, month, account_type,
ROUND(AVG(avg_balance) OVER(PARTITION BY account_type ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_avg_3month
FROM a;

--  Identify customers whose average withdrawal amount is increasing month-over-month.

WITH a AS(SELECT customer_id, EXTRACT(YEAR FROM transaction_date) AS year, EXTRACT(MONTH FROM transaction_date) AS month,
AVG(transaction_amount) AS avg_transaction_amount,
LAG(AVG(transaction_amount),1) 
OVER(PARTITION BY customer_id
ORDER BY EXTRACT(YEAR FROM transaction_date), EXTRACT(MONTH FROM transaction_date)) AS prior_avg_transaction_amount
FROM transactions
WHERE transaction_type = 'Withdrawal'
GROUP BY customer_id, year, month)

SELECT * FROM a
WHERE avg_transaction_amount > prior_avg_transaction_amount;

-- Find the top 3 branches with the highest deposit-to-withdrawal ratio in Q2.

WITH a AS (SELECT branch_id, transaction_type, EXTRACT(YEAR FROM transaction_date) AS year,
SUM(transaction_amount) AS total_transaction_amount,
LAG(SUM(transaction_amount)) OVER(PARTITION BY branch_id ORDER BY branch_id, transaction_type) AS deposit_amount,
ROUND((LAG(SUM(transaction_amount)) OVER(PARTITION BY branch_id ORDER BY branch_id, transaction_type)/SUM(transaction_amount)),2) AS dep_withdraw_ratio
FROM transactions
WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5,6) AND 
(transaction_type = 'Deposit' OR transaction_type = 'Withdrawal')
GROUP BY branch_id, transaction_type, year
ORDER by branch_id)

SELECT year, branch_id, total_transaction_amount AS withdrawal_amount, deposit_amount, dep_withdraw_ratio
FROM a
WHERE dep_withdraw_ratio IS NOT NULL
ORDER BY dep_withdraw_ratio DESC
LIMIT 3;

-- List customers who made deposits in every month of the current year.

SELECT customer_id, COUNT(DISTINCT(EXTRACT(MONTH FROM transaction_date))) AS num_months
FROM transactions
WHERE transaction_type = 'Deposit' AND EXTRACT(YEAR FROM transaction_date) = 2023
GROUP BY customer_id
HAVING COUNT(DISTINCT(EXTRACT(MONTH FROM transaction_date))) = 12;

-- Identify loans with interest rates above the average for their loan type.
WITH a AS (SELECT loan_id, loan_type, interest_rate, ROUND(AVG(interest_rate) OVER(PARTITION BY loan_type),2) AS avg_loan_interest_rate FROM loans)
SELECT * FROM a WHERE interest_rate > avg_loan_interest_rate;

-- Calculate average interest rate per loan type per branch.
SELECT b.branch_id, a.loan_type, ROUND(AVG(a.interest_rate),2) AS avg_interest_rate FROM loans AS a INNER JOIN transactions AS b ON a.customer_id = b.customer_id GROUP BY loan_type, branch_id ORDER BY branch_id, loan_type;








