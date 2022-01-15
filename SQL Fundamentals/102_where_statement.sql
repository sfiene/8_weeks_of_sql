---------------------------------------------------------------------
-- PART 2: APPLYING SELECTION CONDITIONS USING THE WHERE STATEMENT
---------------------------------------------------------------------

-- THE WHERE STATEMENT

select *
from grocery_db.customer_details cd
where distance_from_store < 2;

-- MULTIPLE CONDITIONS

-- AND

select *
from grocery_db.customer_details cd
where distance_from_store < 2
and gender = 'M';

-- OR

select *
from grocery_db.customer_details cd
where distance_from_store < 2
or gender = 'M';

-- OTHER OPERATORS

/*
Equal to =
not equal to <>
greater than/less than/equal >, <, >=, <=
*/

select *
from grocery_db.campaign_data cd;

-- IN

select *
from grocery_db.campaign_data cd
where mailer_type in ('Mailer1', 'Mailer2');

-- LIKE

select *
from grocery_db.campaign_data cd
where mailer_type like '%Mailer%';