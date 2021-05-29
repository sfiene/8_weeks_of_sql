# Aggregates
---
## How many records?
---
### How many records are there?
The first aggregate is called the `COUNT` function. It is used to count how many rows are in the dataset.

This also contains an alias, which is simply another way of renaming the column. You use `AS` keyword to define an alias.

*How many rows are there in the film_list table?*

```sql
SELECT COUNT(*) AS row_count
FROM dvd_rentals.film_list;
```
---
## Unique Values
---
### Unique column values
To show the distinct values in a column the `DISTINCT` function is used. This will remove duplicates.

*What are the unique values for the rating column in the film table?*

```sql
SELECT DISTINCT rating
FROM dvd_rentals.film_list;
```

You can combine `COUNT` and `DISTINCT` to count all the unique values in a dataset.

*How many unique category values are there in the film_list table?*

```sql
SELECT COUNT(DISTINCT category) AS unique_category_count
FROM dvd_rentals.film_list;
```
---
## Group by counts
---
### Grouping counts
We can add a grouping to the counts using `GROUP BY` and `COUNT`.

*What is the frequency of values in the rating column in the film_list table?*

Prep for the example is using a temp table built from a bigger table.

```sql
WITH example_table AS (
  SELECT
    fid,
    title,
    category,
    rating,
    price
  FROM dvd_rentals.film_list
  LIMIT 10
)
SELECT
  rating,
  COUNT(*) as record_count
FROM example_table
GROUP BY rating
ORDER BY record_count DESC;
```
Main table query

```sql
SELECT rating
	, COUNT(*) as record_count
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY record_count DESC;
```
---
## Single Value Column Counts
---
In this example, it shows how `GROUP BY` returns a single column value for the values in the varibale being grouped on.

*What is the frequency of values in the rating column in the film table?*

```sql
SELECT rating
  , COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating;
```

High level overview of adding a percentage columns. This is using `::NUMERIC` and `OVER` which have not been discussed yet.

```sql
SELECT rating
	, COUNT(*) AS frequency
	, COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC;
```

Or this query makes the percentages look a little better. This is similar to the above, but is using `ROUND` which rounds the results to the nearest decimal specified.

```sql
SELECT rating
	, COUNT(*) AS frequency
	, ROUND(
			100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (),
		2) AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC;
```
---
## Counts for multiple columns
---
The `GROUP  BY` function will still be used, but this time 2 or more columns will be used.

With 2 or more columns, `GROUP BY` will group all the different combinations of values not just on 1 columns.

*What are the 5 most frequent rating and category combinations in the film_list table?*

```sql
SELECT rating
	, category
	, COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating, category
ORDER BY frequency DESC
LIMIT 5;
```
---
## Exercises
---
*Which actor_id has the most number of unique film_id records in the dvd_rentals.film_actor table?*

```sql
SELECT actor_id
  , COUNT(DISTINCT film_id) as number_of_films
FROM dvd_rentals.film_actor
GROUP BY actor_id
ORDER BY number_of_films DESC;
```

*How many distinct fid values are there for the 3rd most common price value in the dvd_rentals.nicer_but_slower_film_list table?*

```sql
SELECT price
  , COUNT(DISTINCT fid)
FROM dvd_rentals.nicer_but_slower_film_list
GROUP BY price
ORDER BY 2 DESC;
```

*How many unique country_id values exist in the dvd_rentals.city table?*

```sql
SELECT COUNT(DISTINCT country_id)
FROM dvd_rentals.city
```

*What percentage of overall total_sales does the Sports category make up in the dvd_rentals.sales_by_film_category table?*

```sql
SELECT category
  , ROUND(
        100 * total_sales::NUMERIC / SUM(total_sales) OVER (),
      2
    ) AS percentage
FROM dvd_rentals.sales_by_film_category
```

*What percentage of unique fid values are in the Children category in the dvd_rentals.film_list table?*

```sql
SELECT category
  , ROUND(
          100 * COUNT(DISTINCT fid)::NUMERIC / SUM(COUNT(DISTINCT fid)) OVER (),
        2
      ) AS percentage
FROM dvd_rentals.film_list
GROUP BY category
ORDER BY category;
```
---
## Appendix
---
SQL uses something called interger floor division, which rounds down to the nearest whole number automatically.

In the following example you woukd expect to see 33.33333... but what you get is 33

```sql
SELECT 100 / 3 AS integer_division
```

Another example of this is where you would expect to get 0.75 but get 0 instead

```sql
SELECT 15 / 20 AS integer_division
```

This automatically happens in SQL and the way to get around this is to cast the number as a numeric data type.

The long way to do this is to use the `CAST` function and pass the column name as a new data type.

This example will yield the proper number of 33.3333

```sql
SELECT CAST(100 AS numeric) / 3 AS top_numeric_division
```

Likewise for the other example, but there is a faster way to cast the column as a new data type.

That is using the `column_name::new_data_type` syntax such as in the following example.

```sql
SELECT 15::NUMERIC / 20 AS top_numeric_division
```

The use of this syntax can be used on either top or bottom of the equation...it does not matter.












































