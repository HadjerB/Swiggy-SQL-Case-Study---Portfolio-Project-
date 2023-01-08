CREATE DATABASE Swiggy_Portofolio_Project

/* Find customers who have never ordered  */

select u.user_id, u.name, o.order_id 
from [dbo].[swiggy-schema - users] u
left join [dbo].[swiggy-schema - orders] o
on u.user_id = o.user_id
where order_id IS  NULL

/* Average dish price by restaurant  */

SELECT r_id, avg(price) as avg_price
from [dbo].[swiggy-schema - menu] m 
join  [dbo].[swiggy-schema - food] f
on m.f_id=f.f_id 
group by r_id 
order by avg_price 

/* Find top restaurant in terms of number of orders */

select r.r_name, o.r_id, count(order_id) no_of_orders
from [dbo].[swiggy-schema - orders] o
join [dbo].[swiggy-schema - restaurants] r
on o.r_id=r.r_id
group by  o.r_id, r.r_name
order by 3 desc

/* Find top restaurant in terms of number of orders for a given month (June for this example) */

select top 1 r.r_name, o.r_id, count(order_id) no_of_orders
from [dbo].[swiggy-schema - orders] o
join [dbo].[swiggy-schema - restaurants] r
on o.r_id=r.r_id
where month(date)=6
group by  o.r_id, r.r_name
order by 3 desc


/* Restaurants with monthly sales > x for  */

select r.r_id, sum(o.amount) sales 
from [dbo].[swiggy-schema - orders] o 
join [dbo].[swiggy-schema - restaurants] r 
on o.r_id=r.r_id
where month(date)=6
group by  r.r_id
HAVING sum(o.amount)> 500
order by 1 


/* Show all orders with order details for a particular customer in a particular date range */


select * 
from [dbo].[swiggy-schema - orders]o
join [dbo].[swiggy-schema - order_details] od
on o.order_id=od.order_id
join [dbo].[swiggy-schema - users] u
on o.user_id=u.user_id
where o.user_id = 1 and month(date) between 6 and 7


/* Find restaurants with max repeated customers */

select TOP 1 r.r_name, r.r_id, count(*) as 'loyal customers'
from 
 (select r_id, user_id, count(*) as visits 
from [dbo].[swiggy-schema - orders]
group by r_id, user_id
having count(*) > 1
 ) t 
 join [dbo].[swiggy-schema - restaurants] r
 on t.r_id= r.r_id 
 group by r.r_name, r.r_id
 order by 'loyal customers' desc 

 /* Month over month revenue growth of Swiggy */

drop table if exists #sales 
;with sales AS
    (
        select month(date) as month, sum(amount) as revenue 
        from [dbo].[swiggy-schema - orders]
        group by month(date)
    ), sales_calc as
    (
        select *, LAG(revenue,1) over (order by revenue) as prev from sales
    )
        select c.*,   (((convert(float,revenue))-prev)/prev)*100 as revenue_growth 
        from sales_calc c


/* Customer's favorite food */


drop table if exists #ff
;with ff as 
(
select o.user_id, od.f_id, count(*) as visits 
from [dbo].[swiggy-schema - orders] o
join [dbo].[swiggy-schema - order_details] od 
on o.order_id= od.order_id 
group by o.user_id, od.f_id 
)
select * from ff t1
where t1.visits = (select max(visits) from ff t2 where t1.user_id=t2.user_id)
