# 1. Record Counts & Distinct Values

- [1. Record Counts & Distinct Values](#1-record-counts--distinct-values)
- [2. How Many Records](#2-how-many-records)
  - [2.1. Column Aliases](#21-column-aliases)
- [3. DISTINCT For Unique Values](#3-distinct-for-unique-values)
  - [3.1. Show Unique Column Values](#31-show-unique-column-values)
  - [3.2. Count of Unique Values](#32-count-of-unique-values)
- [4. Group By Counts](#4-group-by-counts)
  - [4.1. Dividing Rows](#41-dividing-rows)
  - [4.2. Apply Aggregate Count Function](#42-apply-aggregate-count-function)
  - [4.3. Single Column Value Counts](#43-single-column-value-counts)
  - [4.4. Adding a Percentage Column](#44-adding-a-percentage-column)
- [5. Counts for Multiple Column Combinations](#5-counts-for-multiple-column-combinations)
  - [5.1. Using Positional Numbers Instead of Columns Name](#51-using-positional-numbers-instead-of-columns-name)
- [6. Exercises](#6-exercises)

# 2. How Many Records

One of the most important things to know is how many rows are there in a dataset? The size of the data often has an impact on performance.

To check the number of rows we use the `COUNT` command.

*How many rows are there in the film_list table?*

```sql
SELECT COUNT(*)
FROM dvd_rentals.film_list;
```

## 2.1. Column Aliases

To assign a column a new name, you need to use the `AS` keyword. Most everything can be ailiased and some things like joins and CTE's need to be aliased to work.

```sql
SELECT COUNT(*) AS row_count
FROM dvd_rentals.film_list;
```

# 3. DISTINCT For Unique Values

## 3.1. Show Unique Column Values

The `Distinct` keyword can be used to obtain only the unique values from the target column.

*What are the unique values for the rating column in the film table?*

```sql
SELECT DISTINCT(rating)
FROM dvd_rentals.film_list;
```

## 3.2. Count of Unique Values

You can use the `COUNT` keyword and `DISTINCT` keyword together to provide the number of records in each group of unique values.

*How many unique category values are there in the film_list table?*

```sql
SELECT COUNT(DISTINCT(category)) AS unique_category_count
FROM dvd_rentals.film_list;
```

# 4. Group By Counts

Using the `GROUP BY` and the `COUNT` keywords can be much more helpful than the query above. This combo will return the result of how many records in the dataset grouped by the specific column.

>The following uses a CTE which will be explained in greater detail later

```sql
-- Group by query using common table expression
WITH example_table AS (
  SELECT fid
    , title
    , category
    , rating
    , price
  FROM dvd_rentals.film_list
  LIMIT 10
)
SELECT rating
  , COUNT(*) as record_count
FROM example_table
GROUP BY rating
ORDER BY record_count DESC;
```

## 4.1. Dividing Rows

The above is using the `GROUP BY` keyword to group by the rating columns which has 5 unique values within (G, PG, PG-13, R, NC-17).

## 4.2. Apply Aggregate Count Function

Once the data is split using `GROUP BY` we can use the `COUNT` keyword to count how many records each group has in it and return that value.

>You can use other functions instead of COUNT like SUM, MEAN, MAX and MIN

## 4.3. Single Column Value Counts

Using what we now know about `GROUP BY` we can finally answer the question:

*What is the frequency of values in the rating column in the film_list table?*

```sql
SELECT rating
    , COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating;
```

We can take this a step further and use a `ORDER BY` keyword to order the data based on a certain column.

```sql
SELECT rating
    , COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC;
```

## 4.4. Adding a Percentage Column

Sometime we really need to know what percentage of data is in each group. Using the following technique we can find out just that.

>This uses a technique to avoid floor division

```sql
SELECT rating
  , COUNT(*) AS frequency
  , COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER () AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC;
```

This gives a decimal percentage which can be rounded and multiplied by 100 to get a nicer looking percentage number.

```sql
SELECT rating
  , COUNT(*) AS frequency
  , ROUND(
      100 * COUNT(*)::NUMERIC / SUM(COUNT(*)) OVER (),
      2
   ) AS percentage
FROM dvd_rentals.film_list
GROUP BY rating
ORDER BY frequency DESC;
```

# 5. Counts for Multiple Column Combinations

Up until now we have only used 1 column for unique values. We can di that same for multiple columns as well.

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

## 5.1. Using Positional Numbers Instead of Columns Name

You can use positional numbers to refere to columns in the `GROUP BY` or `ORDER BY` statements. It is a stylsitic choice and becomes very hard to read when the queries get bigger.

>Use the column names instead...always!

```sql
SELECT rating
    , category
    , COUNT(*) AS frequency
FROM dvd_rentals.film_list
GROUP BY 1, 2
```

# 6. Exercises

*Which `actor_id` has the most number of unique `film_id` records in the `dvd_rentals.film_actor` table?*

```sql
SELECT actor_id
    , COUNT(DISTINCT(film_id))
from dvd_rentals.film_actor
GROUP BY actor_id
ORDER BY COUNT(DISTINCT(film_id)) DESC
LIMIT 5;
```

*How many distinct `fid` values are there for the 3rd most common price value in the `dvd_rentals.nicer_but_slower_film_list` table?*

```sql
SELECT price
  , COUNT(DISTINCT(fid))
from dvd_rentals.nicer_but_slower_film_list
GROUP BY price
ORDER BY COUNT(DISTINCT(fid)) DESC
LIMIT 5;
```

*How many unique `country_id` values exist in the `dvd_rentals.city` table?*

```sql
SELECT COUNT(DISTINCT(country_id))
FROM dvd_rentals.city;
```

*What percentage of overall `total_sales` does the Sports `category` make up in the `dvd_rentals.sales_by_film_cetegory` table?*

```sql
SELECT category
  , ROUND(
      100 * total_sales::NUMERIC / SUM(total_sales) OVER (),
      2
   ) AS percentage
FROM dvd_rentals.sales_by_film_category;
```

*What percentage of unique `fid` values are in the Children `category` in the `dvd_rentals.film_list` table?*

```sql
SELECT category
  , COUNT(*) AS frequency
  , ROUND(
      100 * COUNT(DISTINCT(fid))::NUMERIC / SUM(COUNT(DISTINCT(fid))) OVER (),
      2
   ) AS percentage
FROM dvd_rentals.film_list
GROUP BY category
ORDER BY category;
```