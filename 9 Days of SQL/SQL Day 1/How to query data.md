# How to Query Data
---
### The SELECT Statement
The `SELECT` statement is the first thing to learn.

*Show all records from the language table from the dvd_rentals schema.*

```sql
SELECT column_name 1
	, column_name 2
FROM schema_name.table_name;
```
--- 
### Selecting all columns
The `*` is called the star. It is used to select everything in a table.

*Show all records from the language table from the dvd_rentals schema.*

```sql
SELECT *
FROM dvd.rentals.language;
```
---
### Selecting specific columns
Similar to the select all, here you just list what columns you want.

*Show only the language_id and name columns from the language table.*

```sql
SELECT language_id
	, name
FROM dvd.rentals.language;
```
---
### Limit output rows
Here we use the `LIMIT` to restrict the output to a specified number of rows.

*Show the first 10 rows from the actor tables.*

```sql
SELECT *
FROM dvd.rentals.actor
LIMIT 10;
```
---
# Sorting Query Results
---
### Sort by text column
Sorting the query using the `ORDER BY` clause.

*What are the first 5 values in the country column from the country table by alphabetical order?*

```sql
SELECT country
FROM dvd.rentals.country
ORDER BY country
LIMIT 5;
```
---
### Sort by numeric/date column
To sort any columne with number, dates, or timestamps it is done from lowest to highest or latest to earliest

*What are the 5 lowest total_sales values in the sales_by_film_category table?*

```sql
SELECT total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY 1
LIMIT 5;
```
---
# Sort by descending
In the `ORDER BY` clause we can use the key word `DESC`

*What are the first 5 values in reverse alphabetical order in the country column from the country table?*

```sql
SELECT country
FROM dvd_rentals.country
ORDER BY country DESC
LIMIT 5;
```

*Which category had the lowest total_sales value according to the sales_by_film_category table? What was the total_sales value?*

```sql
SELECT category
	, total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY total_sales
LIMIT 1;
```
*What was the latest payment_date of all dvd rentals in the payment table?*

```sql
SELECT payment_date
FROM dvd_rentals.payment
ORDER BY payment_date DESC
LIMIT 1;
```
---
# Sort by multiple columns
---
### Both ascending
We can use 2 or more columns in the `ORDER BY` clause to sort within a sort.

```sql
SELECT *
FROM sample_table
ORDER BY column_a, column_b;
```

### Ascending and descending

```sql
SELECT *
FROM sample_table
ORDER BY column_a DESC, column_b;
```

### Both descending

```sql
SELECT *
FROM sample_table
ORDER BY column_a DESC, column_b DESC;
```

### Different column order

```sql
SELECT *
FROM column_b DESC, column_a;
```
---
# Example sorting questions
---
*Which customer_id had the latest rental_date for inventory_id = 1 and 2?*

```sql
SELECT customer_id
  , rental_date
  , inventory_id
FROM dvd_rentals.rental
ORDER BY inventory_id, rental_date DESC;
```

*In the dvd_rentals.sales_by_film_category table, which category has the highest total_sales?*

```sql
SELECT category
  , total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY total_sales DESC;
```
---
# Exercises
---
*What is the name of the category with the highest category_id in the dvd_rentals.category table?*

```sql
SELECT category_id
  , name
FROM dvd_rentals.category
ORDER BY category_id DESC;
```

*For the films with the longest length, what is the title of the “R” rated film with the lowest replacement_cost in dvd_rentals.film table?*

```sql
SELECT title
  , length
  , replacement_cost
  , rating
FROM dvd_rentals.film
ORDER BY length DESC, replacement_cost;
```

*Who was the manager of the store with the highest total_sales in the dvd_rentals.sales_by_store table?*

```sql
SELECT manager
  , total_sales
FROM dvd_rentals.sales_by_store
ORDER BY total_sales DESC;
```

*What is the postal_code of the city with the 5th highest city_id in the dvd_rentals.address table?*

```sql
SELECT postal_code
  , city_id
FROM dvd_rentals.address
ORDER BY city_id DESC;
```