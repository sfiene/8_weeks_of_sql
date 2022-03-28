# 1. Select and Sort Data

- [1. Select and Sort Data](#1-select-and-sort-data)
  - [1.1. The SELECT Statement](#11-the-select-statement)
  - [1.2. Selecting all columns](#12-selecting-all-columns)
  - [1.3. Selecting specific columns](#13-selecting-specific-columns)
  - [1.4. Limit output rows](#14-limit-output-rows)
- [2. Sorting Query Results](#2-sorting-query-results)
  - [2.1. Sort by text column](#21-sort-by-text-column)
  - [2.2. Sort by numeric/date column](#22-sort-by-numericdate-column)
- [3. Sort by descending](#3-sort-by-descending)
- [4. Sort by multiple columns](#4-sort-by-multiple-columns)
  - [4.1. Both ascending](#41-both-ascending)
  - [4.2. Ascending and descending](#42-ascending-and-descending)
  - [4.3. Both descending](#43-both-descending)
  - [4.4. Different column order](#44-different-column-order)
- [5. Example sorting questions](#5-example-sorting-questions)
- [6. Exercises](#6-exercises)

## 1.1. The SELECT Statement

The `SELECT` statement is the first thing to learn.

```sql
SELECT column_name 1
 , column_name 2
FROM schema_name.table_name;
```

## 1.2. Selecting all columns

The `*` is called the star. It is used to select everything in a table.

*Show all records from the language table from the dvd_rentals schema.*

```sql
SELECT *
FROM dvd.rentals.language;
```

## 1.3. Selecting specific columns

Similar to the select all, here you just list what columns you want.

*Show only the language_id and name columns from the language table.*

```sql
SELECT language_id
 , name
FROM dvd.rentals.language;
```

## 1.4. Limit output rows

Here we use the `LIMIT` to restrict the output to a specified number of rows.

*Show the first 10 rows from the actor tables.*

```sql
SELECT *
FROM dvd.rentals.actor
LIMIT 10;
```

# 2. Sorting Query Results

## 2.1. Sort by text column

Sorting the query using the `ORDER BY` clause.

*What are the first 5 values in the country column from the country table by alphabetical order?*

```sql
SELECT country
FROM dvd.rentals.country
ORDER BY country
LIMIT 5;
```

## 2.2. Sort by numeric/date column

To sort any columne with number, dates, or timestamps it is done from lowest to highest or latest to earliest

*What are the 5 lowest total_sales values in the sales_by_film_category table?*

```sql
SELECT total_sales
FROM dvd_rentals.sales_by_film_category
ORDER BY 1
LIMIT 5;
```

# 3. Sort by descending

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

# 4. Sort by multiple columns

## 4.1. Both ascending

We can use 2 or more columns in the `ORDER BY` clause to sort within a sort.

```sql
SELECT *
FROM sample_table
ORDER BY column_a, column_b;
```

## 4.2. Ascending and descending

```sql
SELECT *
FROM sample_table
ORDER BY column_a DESC, column_b;
```

## 4.3. Both descending

```sql
SELECT *
FROM sample_table
ORDER BY column_a DESC, column_b DESC;
```

## 4.4. Different column order

```sql
SELECT *
FROM column_b DESC, column_a;
```

# 5. Example sorting questions

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

# 6. Exercises

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
