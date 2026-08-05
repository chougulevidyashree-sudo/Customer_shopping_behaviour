create database customer_behaviour;
use customer_behaviour;

CREATE TABLE customer (
    CustomerID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(20),
    Item_Purchased VARCHAR(100),
    Category VARCHAR(50),
    Purchase_Amount DECIMAL(10,2),
    Location VARCHAR(100),
    Size VARCHAR(10),
    Season VARCHAR(20),
    Review_Rating INT,
    Subscription_Status VARCHAR(10),
    Payment_Method VARCHAR(20),
    Shipping_Type VARCHAR(20),
    Discount_Applied VARCHAR(10),
    PromoCodeUsed VARCHAR(10),
    Previous_Purchases INT,
    Preferred_Payment_Method VARCHAR(20),
    Frequency_Of_Purchases INT
);
show create table customer;

SELECT * FROM customer LIMIT 10;
-- Q.1 what is total renevew genrated  by male vs. female
select `Gender`,sum( `Purchase Amount (USD)`) as revenue from customer
group by Gender;

-- Q.2 which customer used a discount but stll spent more than the purches amount
select `Customer ID` ,`Purchase Amount (USD)` from customer
where  `Discount Applied`='Yes' and `Purchase Amount (USD)` >=(select avg(`Purchase Amount (USD)`) from customer);

-- Q.3 which are the  top 5 product with highest avrage review rating

SELECT 
    `Item Purchased`, 
    ROUND(AVG(`Review Rating`), 2) AS avrage_product_rating
FROM customer
GROUP BY `Item Purchased`
ORDER BY avrage_product_rating DESC
LIMIT 5;

-- Q.4 campare the avrage purchase amount bet standred and exprees shipping
select `Shipping Type` ,round(avg( `Purchase Amount (USD)`),2) AS round_numeric from customer
where `Shipping Type` in('Standard','Express')
group by `Shipping Type` ;

-- Q.5 do subscribed customer paid more?  campare avg and total revenue bet subscribers and non subscribers
select `Subscription Status`,count( `Customer ID`) as total_customers,
round(avg(`Purchase Amount (USD)`),2) as avg_spend,
round(sum(`Purchase Amount (USD)`),2) as Total_revenue from customer
group by `Subscription Status`
order by Total_revenue, avg_spend desc;

-- Q.6  which 5 product have heighest purchesed with discountss applied
select  `Item Purchased`,round (100*sum(case when  `Discount Applied`='Yes' then 1 else 0 end )/count(*),2) as discount_rate
from customer
group by   `Item Purchased`
order by discount_rate desc
limit 5;
-- Q.7 segment customer into new returning and loyal based on their total no.of of their privious purchases
-- and show the count of each segment
with customer_type as(select `customer ID`,`Previous Purchases`,
case when `Previous Purchases`=1 then 'new'
when `Previous Purchases` between 2 and 10 then 'returning'
else 'loyal'
end as customer_segment
from customer
)
select customer_segment,count(*)as "number of customers"
from customer_type
group by customer_segment;

describe customer_behaviour;
-- Q.8 what are the most top 3 purchased products within each catagory
with item_counts as(
select Category,
`Item Purchased`,
count(`customer ID`) as total_orders,
row_number() over(partition by Category order by count(`Customer ID`)desc)as item_rank
from customer
group by Category,`Item Purchased`
)
select item_rank,Category,total_orders, `Item Purchased`
from item_counts
where item_rank<=3;
-- Q.9 are customers who are repet buyrs(more than 5 preious purchases) also likly to subscribe?
select `Subscription Status`,
count(`Subscription Status`) AS repeat_buyers from customer
where `Previous Purchases` >5
group by `Subscription Status`;
describe customer_behaviour;

-- Q.10 what is revenvue contrubution of each age group?
ALTER TABLE customer ADD COLUMN age_group VARCHAR(50);


select `age_group`,
sum(`Purchase_Amount`) as total_revenue
from customer
group by `age_group`
order by total_revenue desc;