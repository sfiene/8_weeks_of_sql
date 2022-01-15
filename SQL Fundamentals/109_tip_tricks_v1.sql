---------------------------------------------------------------------
-- PART 8: USEFUL TIPS & TRICKS (VOLUME 1) 
---------------------------------------------------------------------

-------------------------------------------------------
-- USING SUBQUERIES
-------------------------------------------------------

-- if the table had a profit_margin that was the same as another one then this query will return both
select product_area_name 
	, profit_margin 
from grocery_db.product_areas pa
where profit_margin = (select max(profit_margin)
						from grocery_db.product_areas pa2);
			
-- if the table had a profit_margin that was the same as another one then this query will return only the highest value				
select product_area_name 
	, profit_margin 
from grocery_db.product_areas pa
where profit_margin = (select profit_margin 
						from grocery_db.product_areas pa2
						order by profit_margin desc limit 1);
					
-------------------------------------------------------
-- USING LAG & LEAD
-------------------------------------------------------
					
-- able to use the information the the row before or after the current row 
					
create temp table cust_trans as (
select distinct customer_id
	, transaction_id
	, transaction_date
from grocery_db.transactions t
where customer_id in (1, 2)
);

select *
	, lag(transaction_date, 1) over (partition by customer_id order by transaction_date, transaction_id) as transaction_date_lag_1
	, lag(transaction_date, 2) over (partition by customer_id order by transaction_date, transaction_id) as transaction_date_lag_2
	, lead(transaction_date, 1) over (partition by customer_id order by transaction_date, transaction_id) as transaction_date_lead_1
from cust_trans;

-------------------------------------------------------
-- ROUNDING DATA
-------------------------------------------------------

select *
	, round(sales_cost, 1) as sales_cost_round_1
	, round(sales_cost, 0) as sales_cost_round_0
	, round(sales_cost, -1) as sales_cost_rounddown_1
	, round(sales_cost, -2) as sales_cost_rounddown_2
from grocery_db.transactions t 
where customer_id = 1;

-------------------------------------------------------
-- RANDOM SAMPLING
-------------------------------------------------------

select *
from grocery_db.customer_details cd 
order by random()
limit 100;

-------------------------------------------------------
-- EXTRACTING PARTS OF A DATE
-------------------------------------------------------

select distinct transaction_date
	, date_part('day', transaction_date) as column_day
	, date_part('month', transaction_date) as column_month
	, date_part('year', transaction_date) as column_year
	, date_part('dow', transaction_date) as column_dow
from grocery_db.transactions t
order by transaction_date;

-------------------------------------------------------
-- WORKING WITH STRINGS/TEXT
-------------------------------------------------------

select product_area_name
	, upper(product_area_name) as pan_upper
	, lower(product_area_name) as pan_lower
	, char_length(product_area_name) as pan_length
	, concat(product_area_name, ' - ', 'Department') as pan_concat
	, substring(product_area_name, 3, 6) as pan_substring
	, repeat(product_area_name, 2) as pan_repeat
from  grocery_db.product_areas pa;










