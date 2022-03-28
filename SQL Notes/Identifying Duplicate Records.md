# 1. Identifying Duplicate Records

- [1. Identifying Duplicate Records](#1-identifying-duplicate-records)
- [2. Introduction to Health Data](#2-introduction-to-health-data)
  - [2.1. Dataset Inspection](#21-dataset-inspection)
  - [2.2. Record Counts](#22-record-counts)
  - [2.3. Unique Column Counts](#23-unique-column-counts)
  - [2.4. Single Column Frequency Counts](#24-single-column-frequency-counts)
- [3. Individual Column Distributions](#3-individual-column-distributions)
  - [3.1. Measure Column](#31-measure-column)
  - [3.2. Systolic](#32-systolic)
  - [3.3. Diastolic](#33-diastolic)
  - [3.4. Deeper Look Into Specific Values](#34-deeper-look-into-specific-values)
  - [3.5. Optional Exercise](#35-optional-exercise)
- [4. How To Deal With Duplicates](#4-how-to-deal-with-duplicates)
  - [4.1. Detecting Duplicate Records](#41-detecting-duplicate-records)
  - [4.2. Remove All Duplicates](#42-remove-all-duplicates)
    - [4.2.1. Subqueries](#421-subqueries)
    - [4.2.2. Common Table Expression (CTE)](#422-common-table-expression-cte)
    - [4.2.3. Temporary Tables](#423-temporary-tables)
  - [4.3. Helpful Recommendations](#43-helpful-recommendations)
- [5. Identifying Duplicate Records](#5-identifying-duplicate-records)
  - [5.1. Group By Counts On All Columns](#51-group-by-counts-on-all-columns)
  - [5.2. Having Clause For Unique Duplicates](#52-having-clause-for-unique-duplicates)
  - [5.3. Retaining Duplicate Counts](#53-retaining-duplicate-counts)
  - [5.4. Ignoring Duplicate Values](#54-ignoring-duplicate-values)
- [6. Exercises](#6-exercises)

# 2. Introduction to Health Data

This dataset was captured from users logging their measurements via and oline portal throughout the day. This is messy and more like real-world data.

## 2.1. Dataset Inspection

Take a look at the table. Rows include id, log_date, measure, measure_value, systolic, and diastolic

```sql
SELECT *
FROM health.user_logs;
```

## 2.2. Record Counts

A record counts simply counts all of the records in the dataset.

```sql
SELECT COUNT(*)
FROM health.user_logs;
```

## 2.3. Unique Column Counts

A unique column count will only return the distinct values of the specified column.

```sql
SELECT COUNT(DISTINCT id)
FROM health.user_logs;
```

## 2.4. Single Column Frequency Counts

Inspecting the most frequent values from the measure column.

```sql
SELECT measure
  , COUNT(*) AS frequency
  , ROUND(
      100 * COUNT(*) / SUM(COUNT(*)) OVER (),
      2
    ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;
```

Inspecting the top 10 most frequent id from the id column.

```sql
SELECT measure
  , COUNT(*) AS frequency
  , ROUND(
      100 * COUNT(*) / SUM(COUNT(*)) OVER (),
      2
    ) AS percentage
FROM health.user_logs
GROUP BY measure
ORDER BY frequency DESC;
```

# 3. Individual Column Distributions

## 3.1. Measure Column

```sql
SELECT measure_value
  , COUNT(*) AS frequncy
FROM health.user_logs
GROUP BY measure_value
ORDER BY COUNT(*) DESC
LIMIT 10;
```

## 3.2. Systolic

```sql
SELECT systolic
  , COUNT(*) AS frequncy
FROM health.user_logs
GROUP BY systolic
ORDER BY COUNT(*) DESC
LIMIT 10;
```

## 3.3. Diastolic

```sql
SELECT diastolic
  , COUNT(*) AS frequncy
FROM health.user_logs
GROUP BY diastolic
ORDER BY COUNT(*) DESC
LIMIT 10;
```

## 3.4. Deeper Look Into Specific Values

To filter the data, lets introduce the `WHERE` clause. Using this you can specify what values you want to see in the results.

```sql
SELECT measure
  , COUNT(*)
FROM health.user_logs
WHERE measure_value = 0
GROUP BY measure;
```

Most of the values where measure is equal to 0 happens to be when the measure type is blood pressure.

```sql
SELECT *
FROM health.user_logs
WHERE measure_value = 0
  AND measure = 'blood_pressure'
LIMIT 10;
```

The above query shows that there is in fact valid measurements for blood pressure under systolic and diastolic. What happens when we look data where measure is not equal to 0.

```sql
SELECT *
FROM health.user_logs
WHERE measure_value != 0
  AND measure = 'blood_pressure'
LIMIT 10;
```

Looking at data where there is no systolic or diastolic measurements recorded, respectively.

```sql
SELECT measure
  , COUNT(*)
FROM health.user_logs
WHERE systolic IS NULL
GROUP BY measure;
```

```sql
SELECT measure
  , COUNT(*)
FROM health.user_logs
WHERE diastolic IS NULL
GROUP BY measure;
```

## 3.5. Optional Exercise

Dear colleague,

There is a little problem with data that you sent me. The measure column shows
the correct value for most of the columns, but some of the columns actually have a 0 for the value.

This seems a little off to me.

Thank you,

Scott

# 4. How To Deal With Duplicates

Different ways to deal with duplicate data:

* Remove them in a `SELECT` statement
* Recreating a “clean” version of our dataset
* Identify exactly which rows are duplicated for further investigation
* Simply ignore the duplicates and leave the dataset alone

## 4.1. Detecting Duplicate Records

Check the row count of the table. Comes out to 43891 rows.

```sql
SELECT COUNT(*)
FROM health.user_logs;
```

## 4.2. Remove All Duplicates

To remove all the duplicates we simply use the `DISTINCT` keyword.

```sql
SELECT COUNT(DISTINCT(*))
FROM health.user_logs;
```

Unfortunately we cannot perform this `COUNT(DISTINCT(*))` in most databases. So how do we get around it?

### 4.2.1. Subqueries

A subquery is a query within a query. This returns 31004 rows.

```sql
SELECT COUNT(*)
FROM (
    SELECT DISTINCT *
    FROM health.user_logs
  ) AS subquery;
```

### 4.2.2. Common Table Expression (CTE)

When comparing a CTE to excel we can think of CTEs as the transformations done to raw data inside and existing excel sheet. A CTE manipulates existing data and stores the data outputs as a new reference. We can create CTEs from existing data or from exisitng CTEs. This query returns 31004 rows as well.

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT COUNT(*)
FROM deduped_logs;
```

### 4.2.3. Temporary Tables

Unlike using CTEs to capture the output in a single query, we can use temp tables with only unique values from out original dataset. Temporary tables are nice becuase they are treated like a permanant tables and can be partitioned and indexed to optimize performance. However, temp tables do take more time to create.

>Temporary Tables are called as such becuase once the session is closed they disappear.

Before we begin we want to make sure that there is not table present with the same name so we use `DROP TABLE IF EXISTS` before moving forward.

```sql
-- Drop the table is it exists
DROP TABLE IF EXISTS deduplicated_user_logs;

-- Create the temp table with only distinct values
CREATE TEMP TABLE deduplicated_user_logs AS
SELECT DISTINCT *
FROM health.user_logs;

-- Query the temp table
SELECT COUNT(*)
FROM deduplicated_user_logs;
```

In closing if we run a `COUNT(*)` on the original table the number of rows is 43,891. However, when we use some of the techniques above we see there are in fact duplicates and the uniquevalue count is 31,004.

## 4.3. Helpful Recommendations

There are many ways to accomplish removing duplicates, but why and which one is best. It depends on what you need to accomplish.

*If you need to use this deduplicated data again later - a temp table is best - if not then use a CTE*

# 5. Identifying Duplicate Records

A lot of the time, we will be interested how many times a record is duplicated. There are different way to approach this problem and the one to use will be dependent on the end goal.

## 5.1. Group By Counts On All Columns

We can identify this by using `GROUP BY` and `COUNT` on all columns. This will allow us to tally the number of times a row has been duplicated in out dataset.

```sql
SELECT id
  , log_date
  , measure
  , measure_value
  , systolic
  , diastolic
  , COUNT(*) as frequency
FROM health.user_logs
GROUP BY id
  , log_date
  , measure
  , measure_value
  , systolic
  , diastolic
ORDER BY frequency DESC
```

## 5.2. Having Clause For Unique Duplicates

We can further slim down the query to only the values that have a count greater than 1 using `HAVING`.

```sql
-- Clean up existing temp tables
DROP TABLE IF EXISTS duplicated_record_counts;

-- Create Temp table
CREATE TEMPORARY TABLE unique_duplicated_records AS
SELECT *
FROM health.user_logs
GROUP BY id
  , log_date
  , measure
  , measure_value
  , systolic
  , diastolic
HAVING COUNT(*) > 1;

-- Inspect the top 10 rows
SELECT *
FROM unique_duplicated_records
LIMIT 10;
```

## 5.3. Retaining Duplicate Counts

To be able to know exactly which records were duplicated and also know how many times they were duplicated we can use the following query.

```sql
WITH groupby_counts AS (
  SELECT id
    , log_date
    , measure
    , measure_value
    , systolic
    , diastolic
    , COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY id
    , log_date
    , measure
    , measure_value
    , systolic
    , diastolic
)
SELECT *
FROM groupby_counts
WHERE frequency > 1
ORDER BY frequency DESC
LIMIT 10;
```

## 5.4. Ignoring Duplicate Values

We can simply ignore the duplicate values. There are many tools that can help us look past the duplicate issue, such as Tableau and Alteryx, and not spend so much time deduplicating the table.

# 6. Exercises

*Which `id` value has the most number of duplicate records in the `health.user_logs` table?*

```sql
DROP TABLE IF EXISTS groupby_counts;

WITH groupby_counts AS (
  SELECT id
    , log_date
    , measure
    , measure_value
    , systolic
    , diastolic
    , COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY id
    , log_date
    , measure
    , measure_value
    , systolic
    , diastolic
)
SELECT id
  , SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY id
ORDER BY total_duplicate_rows DESC
LIMIT 10;
```

*Which `log_date` value had the most duplicate records after removing the max duplicate `id` value from question 1?*

```sql
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  WHERE id != '054250c692e07a9fa9e62e345231df4b54ff435d'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  log_date,
  SUM(frequency) AS total_duplicate_rows
FROM groupby_counts
WHERE frequency > 1
GROUP BY log_date
ORDER BY total_duplicate_rows DESC
LIMIT 10;
```

*Which `measure_value` had the most occurances in `health.user_logs` value when `measure = 'weights'`?*

```sql
SELECT
  measure_value,
  COUNT(*) AS frequency
FROM health.user_logs
WHERE measure = 'weight'
GROUP BY measure_value
ORDER BY frequency DESC
LIMIT 10;
```

*How many single duplicated rows exists when `measure = 'blood pressure'` in the `health.user_logs`? How about the total number of duplicate records in the same table?*

```sql
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  COUNT(*) as single_duplicate_rows,
  SUM(frequency) as total_duplicate_records
FROM groupby_counts
WHERE frequency > 1;
```

*What percentage of records `measure_value = 0` when `measure = 'blood_pressure'` in the `health.user_logs` table? How many records are there also for this same lesson?*

```sql
WITH all_measure_values AS (
  SELECT measure_value
    , COUNT(*) AS total_records
    , SUM(COUNT(*)) OVER () AS overall_total
  FROM health.user_logs
  WHERE measure = 'blood_pressure'
  GROUP BY measure_value
)
SELECT measure_value
  , total_records
  , overall_total
  , ROUND(100 * total_records::NUMERIC / overall_total, 2) AS percentage
FROM all_measure_values
WHERE measure_value = 0
```

*For a bonus - what happens when you move the `measure_value = 0` to another place in this query?*

If you move the `measure_value = 0` to the CTE, it will trim the CTE down to only include `measure_value = 0 and measure = 'blood_pressure'`, instead of having all the rows with a blood pressure measurement.

*For an extra bonus - is there a way to implement the same query without using a CTE?*

*What percentage of records are duplicates on `the health.user_log`?*

```sql
WITH groupby_counts AS (
  SELECT
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic,
    COUNT(*) AS frequency
  FROM health.user_logs
  GROUP BY
    id,
    log_date,
    measure,
    measure_value,
    systolic,
    diastolic
)
SELECT
  -- Need to subtract 1 from the frequency to count actual duplicates!
  -- Also don't forget about the integer floor division!
  ROUND(
    100 * SUM(CASE
        WHEN frequency > 1 THEN frequency - 1
        ELSE 0 END
    )::NUMERIC / SUM(frequency),
    2
  ) AS duplicate_percentage
FROM groupby_counts;
```

There is another way to do this, which is dividing the two values by hand.

```sql
WITH deduped_logs AS (
  SELECT DISTINCT *
  FROM health.user_logs
)
SELECT
  ROUND(
    100 * (
      (SELECT COUNT(*) FROM health.user_logs) -
      (SELECT COUNT(*) FROM deduped_logs)
    )::NUMERIC /
    (SELECT COUNT(*) FROM health.user_logs),
    2
  ) AS duplicate_percentage;
```
