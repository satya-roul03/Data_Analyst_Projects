create database Bank_analysis;
use Bank_analysis;
show tables;
describe customers;
select *from customers;
select *from loans;
select *from transactions;
#Customers by city
select City,count(*) as Total_Customers from customers group by City
order by Total_Customers DESC;
#Avarage income
select avg(Annual_Income) as Avarage_Income from customers;
#Average cradit score
select avg(Credit_Score) as Average_Cradit_Score from customers;
SELECT
    c.Customer_ID,
    c.Customer_Name,
    l.Loan_ID,
    l.Loan_Type,
    l.Loan_Amount
FROM customers c
INNER JOIN loans l
ON c.Customer_ID = l.Customer_ID;
#Find customers with high outstanding loans
select c.Customer_ID,
c.Customer_Name,
sum(l.Outstanding_Amount) as Outstanding_Loan
from customers c
join loans l
on c.Customer_ID=l.Customer_ID
group by c.customer_ID,c.Customer_Name
order by Outstanding_Loan DESC
limit 10;
#Find customers who have no loans
select c.Customer_ID,C.Customer_Name
from customers c
left join loans l
on c.Customer_ID=l.Customer_ID
where l.Customer_ID is null;
#Calculate default rate
select round(100*avg(Loan_Status="Defaulted"),2) as Default_Rate
from loans;
#Monthly transaction analysis
SELECT
    YEAR(Transaction_Date) AS Year,
    MONTH(Transaction_Date) AS Month,
    SUM(Amount) AS Total_Amount
FROM transactions
WHERE Transaction_Status = 'Success'
GROUP BY
    YEAR(Transaction_Date),
    MONTH(Transaction_Date)
ORDER BY
    Year,
    Month;
#What is the total successful revenue generated each month, and how does it compare to the revenue of the previous
WITH monthly AS
(
    SELECT
        DATE_FORMAT(Transaction_Date,'%Y-%m') AS Month,
        SUM(Amount) AS Revenue
    FROM transactions
    WHERE Transaction_Status = 'Success'
    GROUP BY DATE_FORMAT(Transaction_Date,'%Y-%m')
)
SELECT
    Month,
    Revenue,
    LAG(Revenue) OVER(ORDER BY Month) AS Previous_Month
FROM monthly;
#Find the latest transaction for each customer:
WITH ranked AS
(
    SELECT
        t.*,
        ROW_NUMBER() OVER
        (
            PARTITION BY Customer_ID
            ORDER BY Transaction_Date DESC
        ) AS rn
    FROM transactions t
)
SELECT *
FROM ranked
WHERE rn = 1;