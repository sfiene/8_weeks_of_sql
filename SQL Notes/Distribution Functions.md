# 1. Distribution Functions

- [1. Distribution Functions](#1-distribution-functions)
  - [1.1. Beyond Summary Statistics](#11-beyond-summary-statistics)
  - [1.2. Cumulative What?](#12-cumulative-what)
    - [1.2.1. Reverse Engineering](#121-reverse-engineering)
    - [1.2.2. Algorithmic Thinking](#122-algorithmic-thinking)
    - [1.2.3. SQL Implementation](#123-sql-implementation)
      - [1.2.3.1. Order and Assign](#1231-order-and-assign)
      - [1.2.3.2. Bucket Calculations](#1232-bucket-calculations)
    - [1.2.4. What Do I Do With This?](#124-what-do-i-do-with-this)
    - [1.2.5. Critial Thinking](#125-critial-thinking)
    - [1.2.6. Deep Dive Into the 100th Percentile](#126-deep-dive-into-the-100th-percentile)
    - [1.2.7. Large Outliers](#127-large-outliers)
    - [1.2.8. Small Outliers](#128-small-outliers)
    - [1.2.9. Removing Outliers](#129-removing-outliers)
    - [1.2.10. Data Visualization](#1210-data-visualization)
      - [1.2.10.1. Histogram](#12101-histogram)

## 1.1. Beyond Summary Statistics

The following query was the final query describing all the summary statistics:

```sql
SELECT ROUND(MIN(measure_value), 2) AS minimum_value
  , ROUND(MAX(measure_value), 2) AS maximum_value
  , ROUND(AVG(measure_value), 2) AS mean_value
  , ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC
        CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
        2
    ) AS median_value
  , ROUND(
        MODE() WITHIN GROUP (ORDER BY measure_value),
        2
    ) AS mode_value
  , ROUND(STDDEV(measure_value), 2) AS standard_deviation
  , ROUND(VARIANCE(measure_value), 2) AS variance_value
FROM health.user_logs
WHERE measure = 'weight';
```

<div align="center">*Results formatted in long format to be more readable*</div>
<br>

|Column Name|Data Value|
|:---------:|:--------:|
|minimum_value|0.00|
|maximum_value|39642120.00|
|mean_value|28786.85|
|median_value|75.98|
|mode_value|68.49|
|standard_deviation|1062759.55|
|variance_value|1129457862383.41|

A few questions come to mind from these results:

1. Does it make sense to have such low minimum values and such high maximum values?
2. Why is the average value 28,786 kg but the median is 75.98 kg?
3. The standard deviation of values is WAY too large at 1,062,759 kg.

What do you do now? Next we are going to introduce cumulative distribution functions.

## 1.2. Cumulative What?

We previously talked about normal distributions and that they are shaped like a bell curve.

A cumulative distribution function, in mathematical terms, takes a value and returns the percentile. In other words, the probability of any value between the minimum value of a dataset `X` and the value `V` as shown in the following equation.

$$F(V) = \int_{\min(X)}^{V} {f(x) dx} = Pr[\min(X) \le x \le V]$$

### 1.2.1. Reverse Engineering

We want something that looks like this.

The percentile is the probability or percentage of how many other test-takers we beat with our test score.

We also have the floor and ceiling values for each percentile and a count of how many records exist in each percentile.

|percentile|floor_value|ceiling_value|percentile_counts|
|:--------:|:---------:|:-----------:|:---------------:|
|1|0|29.029888|28|
|2|29.48348|32.0689544|28|
|3|32.205032|35.380177|28|
|4|35.380177|36.74095|28|
|5|36.74095|37.194546|28|
|6|37.194546|38.101727|28|
|…|…|…|…|
|9|130.54207|131.570999146|27|
|9|131.670013428|132.776|27|
|9|132.776000977|133.832000732|27|
|9|133.89095|136.531192|27|
|10|136.531192|39642120|27|

### 1.2.2. Algorithmic Thinking

Lets reverse engineer the above output.

1. Order all of the values from smallest to largest.
2. Split them into 100 equal buckets - and assign a number from 1 through to 100 for each bucket.
   * The actual function we will use is `NTILE` but this is interchangable with bucketing as well as percentiles.
   * Splitting these values into buckets have given us new groupd of data to work with.
3. For each bucket:
   * Calculate the minimum value and the maximum value for the ceiling and floor values.
   * Count how many records there are.
4. Combine all the aggregated bucket results into a final summary table.

### 1.2.3. SQL Implementation

So how is this done in SQL?

We will use `OVER` and `ORDER BY` and `NTILE`.

#### 1.2.3.1. Order and Assign

1. Order all of the values from smallest to largest.
2. Split them into 100 equal buckets - and assign a number from 1 through to 100 for each bucket.

We can achieve both of these in a single step in SQL with the **analytical function**.

There are `OVER` and `ORDER BY` clauses used which help us to re-order the dataset by the `measure_value` column in ascending order. The `NTILE` function is a window function that assigns numbers 1 through 100 for each row in the records for each `measure_value`.

```sql
SELECT measure_value
  , NTILE(100) OVER (
    ORDER BY
      measure_value
  ) AS percentile
FROM health.user_logs
WHERE measure = 'weight'
```

#### 1.2.3.2. Bucket Calculations

3. For each bucket:
   * Calculate the minimum value and the maximum value for the ceiling and floor values.
   * Count how many records there are.

We now have percentile values in our dataset split into 100 buckets. We can use `GROUP BY` on the `percentile` column to calculate `MAX` and `MIN` values for the `measure_value` column. We can then use `COUNT` to see how many are in each.

```sql
WITH percentile_values AS (
  SELECT measure_value
    , NTILE(100) OVER (
      ORDER BY
        measure_value
    ) AS percentile
  FROM health.user_logs
  WHERE measure = 'weight'
)
SELECT percentile
  , MIN(measure_value) AS floor_value
  , MAX(measure_value) AS ceiling_value
  , COUNT(*) AS percentile_counts
FROM percentile_values
GROUP BY percentile
ORDER BY percentile;
```

### 1.2.4. What Do I Do With This?

Notice the tails of the data, specifically `percentile = 1` and `percentile = 100`.

1. 28 values lie between 0 and ~29KG
2. 27 values lie between 136.53KG and 39,642,120KG

### 1.2.5. Critial Thinking

What could fall within the above mentioned percentiles?

for the 1st percentile:

1. Maybe there were some incorrectly measured values - leading to some 0kg weight measurements.
2. Perhaps some of the low weights under 29kg were actually valid measurements from young children who were part of the customer base.

For the 100th percentile:

1. Does that 136KG floor value make sense?
2. How many error values were there actually in the dataset?

### 1.2.6. Deep Dive Into the 100th Percentile

Let start by sorting the previous query in descending order, as well as introducing some more window functions, `ROW_NUMBER`, `RANK`, and `DENSE_RANK`. 

```sql
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER (
      ORDER BY
        measure_value
    ) AS percentile
  FROM health.user_logs
  WHERE measure = 'weight'
)
SELECT
  measure_value,
  -- these are examples of window functions below
  ROW_NUMBER() OVER (ORDER BY measure_value DESC) as row_number_order,
  RANK() OVER (ORDER BY measure_value DESC) as rank_order,
  DENSE_RANK() OVER (ORDER BY measure_value DESC) as dense_rank_order
FROM percentile_values
WHERE percentile = 100
ORDER BY measure_value DESC;
```

*What is the difference between the 3 window functions in the above query?*

* The `ROW_NUMBER` function simply add a row number to each row in the partition or set of data.
* The `RANK` function ranks rows based on where they are in the partition. They break ties by giving each value the same number and skipping the next number in line.
  * For instance, if a partition has two #1 values then the next value would be #3.
* The `DENSE_RANK` function does the same as `RANK`. The only difference is how it breaks ties, which is not skipping the next number in line.
  * For instance, if a partition has two #1 values then the next value will be #2.

### 1.2.7. Large Outliers

What do we do with the large weight values?

These are the top 4 large numbers. 200 kg could be a real measurement and we would use our judgement on that, but the other ones are too large, so we can just remove them.

|measure_value|row_number_order|rank_order|dense_rank_order|
|:-----------:|:--------------:|:--------:|:--------------:|
|39642120|1|1|1|
|39642120|2|1|1|
|576484|3|3|2|
|200.487664|4|4|3|

### 1.2.8. Small Outliers

In our data there are few values where 0 kg is a weight, which is too small, even for babies bore too early

### 1.2.9. Removing Outliers

We can accomplish this very easily with a temp table and the `WHERE` clause.

```sql
DROP TABLE IF EXISTS clean_weight_logs;
CREATE TEMP TABLE clean_weight_logs AS (
  SELECT *
  FROM health.user_logs
  WHERE measure = 'weight'
    AND measure_value > 0
    AND measure_value < 201
);
```

After we have removed the outliers, we can recreate the summary table.

```sql
SELECT
  ROUND(MIN(measure_value), 2) AS minimum_value,
  ROUND(MAX(measure_value), 2) AS maximum_value,
  ROUND(AVG(measure_value), 2) AS mean_value,
  ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
    2
  ) AS median_value,
  ROUND(
    MODE() WITHIN GROUP (ORDER BY measure_value),
    2
  ) AS mode_value,
  ROUND(STDDEV(measure_value), 2) AS standard_deviation,
  ROUND(VARIANCE(measure_value), 2) AS variance_value
FROM clean_weight_logs;
```

### 1.2.10. Data Visualization

Next we can show the cumulative distribution function with the cleaned data also.

```sql
WITH percentile_values AS (
  SELECT
    measure_value,
    NTILE(100) OVER (
      ORDER BY
        measure_value
    ) AS percentile
  FROM clean_weight_logs
)
SELECT
  percentile,
  MIN(measure_value) AS floor_value,
  MAX(measure_value) AS ceiling_value,
  COUNT(*) AS percentile_counts
FROM percentile_values
GROUP BY percentile
ORDER BY percentile;
```

From this you can visualize a chart for presentation from the downloaded data.

#### 1.2.10.1. Histogram

Histograms try and mimic the bell curve of the normal distribution.

In PostgreSQL there is a `WIDTH_BUCKET` clause that allows us to create buckets for our histogram

```sql
SELECT
  WIDTH_BUCKET(measure_value, 0, 200, 50) AS bucket,
  AVG(measure_value) AS measure_value,
  COUNT(*) AS frequency
FROM clean_weight_logs
GROUP BY bucket
ORDER BY bucket;
```







































