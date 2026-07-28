create database super_sale_analysis;

use super_sale_analysis;
select * from superstore_mysql;

describe  superstore_mysql;
-- order date and ship date are in text convert it into date foramt
select count(*) as null_values 
from superstore_mysql
where order_date and ship_date is null ;

select order_id , count(*) as total_duplicates
from superstore_mysql
group by order_id
having count(*)>1;

alter table superstore_mysql add column orderdate_clean date;
alter table superstore_mysql add column shipdate_clean date;

SET SQL_SAFE_UPDATES = 0;

update superstore_mysql 
set orderdate_clean = str_to_date(order_date , '%Y-%m-%d'),
    shipdate_clean = str_to_date(ship_date , '%Y-%m-%d');
    
-- sanity check
select 
count(*) as total_rows,
min(orderdate_clean) as earlist_date,
max(orderdate_clean) as latest_date ,
sum(case when profit <0 then 1 else 0 end) as loss_revenue 
from superstore_mysql ;


select
count(*) as total_rows,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc,
count(distinct order_id) as total_customer,
count(distinct customer_id) as total_customer
from superstore_mysql;

select 
year(orderdate_clean) as order_year,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc

from superstore_mysql
group by order_year
order by order_year ;

select 
region ,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc
from superstore_mysql
group by region 
order by region DESC;

select 
state ,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc
from superstore_mysql
group by state 
order by state DESC;

select 
category ,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc
from superstore_mysql
group by category
order by category DESC;

select 
sub_category ,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
(round(sum(profit),2)*100/sum(sales) ) as margin_perc
from superstore_mysql
group by sub_category 
order by sub_category DESC;

select 
sub_category ,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
round(avg(profit),2) as avg_profit,
rank() over(order by sum(profit) ASC) as worst_possible_rank
from superstore_mysql
group by sub_category 
order by total_profit ASC;

-- discount level vs profit 
select 
case 
when discount= 0 then ' 0% NO discount'
 when discount between 0.01 and 0.20 then '1% to 20%'
 when discount between 0.21 and 0.44 then '21% to 44%'
 else '45+ discount' end 
 as discount_bucket,
 count(*) as total_orders,
round(sum(sales),2) as total_revenue,
round(sum(profit),2) as total_profit ,
round(avg(profit),2) as avg_profit
 from superstore_mysql
 group by discount_bucket
 order by min(discount);
 
 select 
 sub_category,
 round(avg(discount),1) as avg_discount,
 round(sum(profit),2) as total_profit,
 round(avg(profit),2) as avg_profit_per_order
 from superstore_mysql
 group by sub_category
 having avg(discount)>.15 and sum(profit)<0
 order by total_profit ASC;

-- customer analysis
-- top 10 customers 
select customer_id , customer_name ,
count(distinct customer_id ) as total_customers,
round(sum(sales),2) as lifetime_revenue,
round(sum(profit),2) as lifetime_profit
from superstore_mysql
group by customer_id , customer_name 
order by lifetime_profit DESC
limit 10;

-- bottom 10 customers
select customer_id , customer_name ,
count(distinct customer_id ) as total_customers,
round(sum(sales),2) as lifetime_revenue,
round(sum(profit),2) as lifetime_profit
from superstore_mysql
group by customer_id , customer_name 
order by lifetime_profit ASC
limit 10;

-- month over month revenue growth using lag
with monthly_revenue as (
select 
date_format(orderdate_clean,'%Y-%m') as order_month,
round(sum(sales),2) as revenue 
from superstore_mysql
group by order_month)

select order_month , revenue ,
lag(revenue) over(order by order_month) as previous_month_revenue ,
round(
(revenue -lag(revenue) over(order by order_month)*100)/
lag(revenue) over(order by order_month),1) as mom_revenue_value
from monthly_revenue
order by order_month;
 

-- running total revenue by month (cumillativev revenue)
with monthly_revenue as (
select 
date_format(orderdate_clean,'%Y-%m') as order_month,
round(sum(sales),2) as revenue 
from superstore_mysql
group by order_month)

select order_month , revenue ,
sum(revenue) over(order by order_month) as runnig_total_revenue
from monthly_revenue
order by order_month;


-- ranking month by revenue each year

WITH monthly_revenue AS (
    SELECT
        YEAR(orderdate_clean) AS order_year,
        MONTH(orderdate_clean) AS order_month,
        ROUND(SUM(sales),2) AS revenue
    FROM superstore_mysql
    GROUP BY
        YEAR(orderdate_clean),
        MONTH(orderdate_clean)
)

SELECT
    order_year,
    order_month,
    revenue,
    DENSE_RANK() OVER (
        PARTITION BY order_year
        ORDER BY order_month
    ) AS month_rank_in_year
FROM monthly_revenue
ORDER BY order_year, month_rank_in_year;

-- shipping operations
-- average order to ship lead time by ship mode
select ship_mode,
count(*) as total_orders,
round(avg(datediff(shipdate_clean , orderdate_clean)),1) as avg_lead_time_by_shipmode
from superstore_mysql
group by ship_mode
order by avg_lead_time_by_shipmode;

-- ship mode vs profit margin , does faster shipping cost more?
SELECT
    ship_mode,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) * 100 / SUM(sales)), 2) AS profit_margin_perc
FROM superstore_mysql
GROUP BY ship_mode
ORDER BY profit_margin_perc DESC;











