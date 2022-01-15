---------------------------------------------------------------------
-- PART 3: AGGREGATING OUR DATA
---------------------------------------------------------------------

-- AGGREGATION FUNCTIONS

select sum(sales_cost) as total_sales
	, avg(sales_cost) as average_sales
	, min(sales_cost) as min_sales
	, max(sales_cost) as max_sales
	, count(*) as num_rows
	, count(distinct transaction_id) as num_transactions
from grocery_db.transactions t;

-- GROUP BY

select transaction_date
	, sum(sales_cost) as total_cost
	, sum(num_items) as total_items
	, count(distinct transaction_id) as num_transactions
from grocery_db.transactions t
group by transaction_date 
order by transaction_date;

-- GROUPING ON MULTIPLE VARIABLES

select product_area_id
	, transaction_date
	, sum(sales_cost) as total_cost
	, sum(num_items) as total_items
	, count(distinct transaction_id) as num_transactions
from grocery_db.transactions t
group by product_area_id, transaction_date 
order by product_area_id, transaction_date;

-- HAVING

select product_area_id 
	, sum(sales_cost) as total_sales 
from grocery_db.transactions t 
group by product_area_id
having sum(sales_cost) > 200000;
