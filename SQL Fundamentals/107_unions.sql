---------------------------------------------------------------------
-- PART 6: UNION
---------------------------------------------------------------------

-- UNION
-- appends data but also removes duplicates

select product_area_name 
from grocery_db.product_areas pa
where product_area_id in (1,2)

union

select product_area_name 
from grocery_db.product_areas pa
where product_area_id in (4,5);

-- UNION ALL
-- unions all data regardless of duplicates

select product_area_name 
from grocery_db.product_areas pa
where product_area_id in (1,2)

union all

select product_area_name 
from grocery_db.product_areas pa
where product_area_id in (1,2);