---------------------------------------------------------------------
-- PART 1: THE BASIC SELECT STATEMENT
---------------------------------------------------------------------

-- THE SELECT STATEMENT

select *
from grocery_db.product_areas pa;

-- LIMIT

select *
from grocery_db.product_areas pa 
limit 3;

-- ORDER BY

select *
from grocery_db.customer_details cd 
order by distance_from_store desc;

-- DISTINCT

select distinct gender 
from grocery_db.customer_details cd

-- GIVE COLUMNS AN ALIAS

select DISTANCE_FROM_STORE as DISTANCE_TO_STORE
	, customer_id as CUSTOMER_NUMBER
from grocery_db.customer_details cd 

-- CREATING NEW COLUMNS

select DISTANCE_FROM_STORE as DISTANCE_TO_STORE
	, customer_id as CUSTOMER_NUMBER
	, 1 as NEW_COL
	, distance_from_store * 1.6 as distance_from_store_KM
from grocery_db.customer_details cd 