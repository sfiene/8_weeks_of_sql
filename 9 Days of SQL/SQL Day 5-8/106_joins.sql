---------------------------------------------------------------------
-- PART 6: JOINING TABLES
---------------------------------------------------------------------

select *
from grocery_db.customer_details cd

select *
from grocery_db.loyalty_scores ls;

-- INNER JOIN

select cd.*
	, ls.customer_loyalty_score 
from grocery_db.customer_details cd
inner join grocery_db.loyalty_scores ls on cd.customer_id = ls.customer_id;

-- LEFT JOIN

select cd.*
	, ls.customer_loyalty_score 
from grocery_db.customer_details cd
left join grocery_db.loyalty_scores ls on cd.customer_id = ls.customer_id;

-- ADDING OTHER LOGIC

select cd.*
	, ls.customer_loyalty_score 
from grocery_db.customer_details cd
left join grocery_db.loyalty_scores ls on cd.customer_id = ls.customer_id
where ls.customer_loyalty_score > 0.5;

-- JOINING MULTIPLE TABLES

select t.*
	, ls.customer_loyalty_score
	, pa.product_area_name
from grocery_db.transactions t
left join grocery_db.loyalty_scores ls on t.customer_id = ls.customer_id
inner join grocery_db.product_areas pa on t.product_area_id = pa.product_area_id;

-- OTHER JOIN TYPES

create temp table table1 (
					id char(1),
					t1_col1 int,
					t1_col2 int);
				
insert into table1 values ('A', 1, 1), ('B', 1, 1);

select *
from table1;

create temp table table2 (
					id char(1),
					t2_col1 int,
					t2_col2 int);
				
insert into table2 values ('A', 2, 2), ('C', 2, 2);

select *
from table2;

-- INNER JOIN

select a.id as id_t1
	, a.t1_col1
	, a.t1_col2
	, b.id as id_t2
	, b.t2_col1
	, b.t2_col2
from table1 a 
inner join table2 b on a.id = b.id;

-- LEFT JOIN

select a.id as id_t1
	, a.t1_col1
	, a.t1_col2
	, b.id as id_t2
	, b.t2_col1
	, b.t2_col2
from table1 a 
left join table2 b on a.id = b.id;

-- OUTER JOIN

select a.id as id_t1
	, a.t1_col1
	, a.t1_col2
	, b.id as id_t2
	, b.t2_col1
	, b.t2_col2
from table1 a 
full outer join table2 b on a.id = b.id;

-- CROSS JOIN

select a.id as id_t1
	, a.t1_col1
	, a.t1_col2
	, b.id as id_t2
	, b.t2_col1
	, b.t2_col2
from table1 a 
cross join table2 b;

