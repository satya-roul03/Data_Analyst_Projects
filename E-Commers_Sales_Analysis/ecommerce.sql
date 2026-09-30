show databases;
use ecommerce;
show tables;
select *from orders;
#Total orders
select count(*) as Total_Orders from orders;
#Total_sales
select sum(Unit_Price) as Total_sales from orders;
#Top Products
select product,sum(Unit_Price) as sales
from orders
group by product
order by sales desc;
#Top cityes
select city,sum(Unit_Price) as sales
from orders
group by city
order by sales desc;
#Monthly sales
/*select month,sum(Unit_Price) as salas
from orders
group by month;*/
#Payment mode destribution
select Payment_Mode,count(*) as Total_orders
from orders
group by Payment_Mode
order by Total_orders desc;
#Cancelled orders
select *from orders where Order_Status="Cancelled";
