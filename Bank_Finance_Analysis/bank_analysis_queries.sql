CREATE DATABASE IF NOT EXISTS bank_financial;
USE bank_financial;

CREATE TABLE customers (
 Customer_ID VARCHAR(20) PRIMARY KEY, Customer_Name VARCHAR(100), Age INT, Gender VARCHAR(20),
 City VARCHAR(50), State VARCHAR(50), Employment_Type VARCHAR(30), Annual_Income DECIMAL(15,2),
 Credit_Score INT, Account_Type VARCHAR(30), Account_Balance DECIMAL(15,2), Customer_Since DATE);

CREATE TABLE loans (
 Loan_ID VARCHAR(20) PRIMARY KEY, Customer_ID VARCHAR(20), Loan_Type VARCHAR(30),
 Loan_Amount DECIMAL(15,2), Interest_Rate DECIMAL(5,2), Loan_Term_Months INT, Loan_Date DATE,
 Loan_Status VARCHAR(30), Monthly_EMI DECIMAL(15,2), Outstanding_Amount DECIMAL(15,2),
 Collateral_Type VARCHAR(30), FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID));

CREATE TABLE transactions (
 Transaction_ID VARCHAR(20) PRIMARY KEY, Customer_ID VARCHAR(20), Transaction_Date DATETIME,
 Transaction_Type VARCHAR(30), Amount DECIMAL(15,2), Channel VARCHAR(30), Branch VARCHAR(20),
 Transaction_Status VARCHAR(20), Year INT, Month INT, Month_Name VARCHAR(10), Quarter VARCHAR(5),
 FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID));

-- 1 Total customers
SELECT COUNT(*) AS Total_Customers FROM customers;
-- 2 Total deposits
SELECT ROUND(SUM(Account_Balance),2) AS Total_Deposits FROM customers;
-- 3 Customers by city
SELECT City,COUNT(*) AS Customers FROM customers GROUP BY City ORDER BY Customers DESC;
-- 4 Loan type performance
SELECT Loan_Type,COUNT(*) AS Loan_Count,ROUND(SUM(Loan_Amount),2) AS Total_Loan_Amount,
ROUND(AVG(Interest_Rate),2) AS Avg_Interest_Rate FROM loans GROUP BY Loan_Type ORDER BY Total_Loan_Amount DESC;
-- 5 Loan approval rate
SELECT ROUND(100*AVG(Loan_Status='Approved'),2) AS Approval_Rate FROM loans;
-- 6 Default rate
SELECT ROUND(100*AVG(Loan_Status='Defaulted'),2) AS Default_Rate FROM loans;
-- 7 Top 10 customers by outstanding loan
SELECT c.Customer_ID,c.Customer_Name,ROUND(SUM(l.Outstanding_Amount),2) AS Outstanding_Loan
FROM customers c JOIN loans l ON c.Customer_ID=l.Customer_ID
GROUP BY c.Customer_ID,c.Customer_Name ORDER BY Outstanding_Loan DESC LIMIT 10;
-- 8 Monthly successful transaction amount
SELECT YEAR(Transaction_Date) AS Year,MONTH(Transaction_Date) AS Month,ROUND(SUM(Amount),2) AS Amount
FROM transactions WHERE Transaction_Status='Success'
GROUP BY YEAR(Transaction_Date),MONTH(Transaction_Date) ORDER BY Year,Month;
-- 9 Channel performance
SELECT Channel,COUNT(*) AS Transactions,ROUND(SUM(Amount),2) AS Total_Amount,ROUND(AVG(Amount),2) AS Avg_Transaction
FROM transactions WHERE Transaction_Status='Success' GROUP BY Channel ORDER BY Total_Amount DESC;
-- 10 Failed transaction rate
SELECT ROUND(100*AVG(Transaction_Status='Failed'),2) AS Failed_Rate FROM transactions;
-- 11 Customers with no loan
SELECT c.Customer_ID,c.Customer_Name FROM customers c LEFT JOIN loans l ON c.Customer_ID=l.Customer_ID WHERE l.Customer_ID IS NULL;
-- 12 High-risk customers
SELECT c.Customer_ID,c.Customer_Name,c.Credit_Score,ROUND(SUM(l.Outstanding_Amount),2) AS Outstanding_Loan
FROM customers c JOIN loans l ON c.Customer_ID=l.Customer_ID WHERE c.Credit_Score<600
GROUP BY c.Customer_ID,c.Customer_Name,c.Credit_Score ORDER BY Outstanding_Loan DESC;
-- 13 Top loan types using DENSE_RANK
WITH x AS (SELECT Loan_Type,SUM(Loan_Amount) Total_Amount FROM loans WHERE Loan_Status<>'Rejected' GROUP BY Loan_Type),
r AS (SELECT *,DENSE_RANK() OVER(ORDER BY Total_Amount DESC) rnk FROM x)
SELECT * FROM r WHERE rnk<=3;
-- 14 MoM transaction growth
WITH m AS (SELECT DATE_FORMAT(Transaction_Date,'%Y-%m') Month,SUM(Amount) Revenue
FROM transactions WHERE Transaction_Status='Success' GROUP BY DATE_FORMAT(Transaction_Date,'%Y-%m'))
SELECT Month,ROUND(Revenue,2) Revenue,
ROUND(100*(Revenue-LAG(Revenue) OVER(ORDER BY Month))/NULLIF(LAG(Revenue) OVER(ORDER BY Month),0),2) MoM_Growth
FROM m ORDER BY Month;
-- 15 Latest transaction per customer
WITH r AS (SELECT t.*,ROW_NUMBER() OVER(PARTITION BY Customer_ID ORDER BY Transaction_Date DESC) rn FROM transactions t)
SELECT * FROM r WHERE rn=1;
-- 16 Customer segmentation
SELECT Customer_ID,Customer_Name,Annual_Income,Account_Balance,
CASE WHEN Annual_Income>=200000 AND Account_Balance>=200000 THEN 'Premium'
WHEN Annual_Income>=100000 OR Account_Balance>=100000 THEN 'High Value'
WHEN Annual_Income>=50000 OR Account_Balance>=50000 THEN 'Mass Affluent'
ELSE 'Standard' END Customer_Segment
FROM customers;
