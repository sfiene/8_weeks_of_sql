# 1. Summary Statistics

- [1. Summary Statistics](#1-summary-statistics)
- [2. Statistics 101](#2-statistics-101)
  - [2.1. Central Location Statistics](#21-central-location-statistics)
    - [2.1.1. Arithmetic Mean or Average](#211-arithmetic-mean-or-average)
    - [2.1.2. Median & Mode](#212-median--mode)
      - [2.1.2.1. The Median Concept](#2121-the-median-concept)
      - [2.1.2.2. Basic Example of Mean, Median & Mode](#2122-basic-example-of-mean-median--mode)
      - [2.1.2.3. Ordered Set Aggregate Functions](#2123-ordered-set-aggregate-functions)
  - [2.2. Spread of the Data](#22-spread-of-the-data)
    - [2.2.1. Min, Max, & Range](#221-min-max--range)
  - [2.3. Variance & Standard Deviation](#23-variance--standard-deviation)
    - [2.3.1. Variance Algorithm](#231-variance-algorithm)
    - [2.3.2. Interpreting Spread](#232-interpreting-spread)
      - [2.3.2.1. Spread for Normal Distribution](#2321-spread-for-normal-distribution)
      - [2.3.2.2. The Empirical Rule or Confidence Intervals](#2322-the-empirical-rule-or-confidence-intervals)
  - [2.4. Calculation All The Summary Statistic](#24-calculation-all-the-summary-statistic)
  - [2.5. Exercises](#25-exercises)
    - [2.5.1. Average, Median & Mode](#251-average-median--mode)

We are going to analyze and further explore raw data through the use of some summary statistics.

Summary statistics in SQL can be computed on single columns, but that more useful when functions are combined and used. 

# 2. Statistics 101

## 2.1. Central Location Statistics

These are values like mean, median, and mode and they describe where the center of the data is located.

### 2.1.1. Arithmetic Mean or Average

>The sum of all values divided by the total count of values for a set of numbers

This is commonly used to show central tendancy for a set of observations.

The equation for arithmetic mean is:

$$\mu = \frac{\sum_{i=1}^{N} X_i} {N}$$

* The greek letter $mu$ represented as $μ$ on the left is the most commonly used mathematical symbol to represent the mean.
* For a set of observations containing a total of N numbers: $x_1,x_2,x_3,...,x_N$ - the mean equals the [ sum of all $x_i$ from i = 1 to i = N ] divided by N.
* The little `i` subscript of the x value is what is known as a dummy variable and any letter can be used in this equation. Often `i` and `j` are used for most mathematical equations you’ll encounter, as well as in for loops in programming languages.

To calculate this in SQL is relatively straightforward.

```sql
SELECT AVG(measure_value)
FROM health.user_logs;
```

### 2.1.2. Median & Mode

These are two other central tendancy statistics different than the mean.

* The **median** value shows the central location based on the middle values in a set of numbers.
* The **mode** is simple the value with most occurances.

#### 2.1.2.1. The Median Concept

To come to the correct median number, first all number have to be ordered from smallest to largest in a single line. The median is the number directly in the middle.

Where $N$ is odd in this line up then there will only be 1 middle number, however when $N$ is even then you must average the 2 middle to numbers to arrive at the median number.

In probability theory, median is know as the 50th percentile and it separated the bottom and top halves of all values.

#### 2.1.2.2. Basic Example of Mean, Median & Mode

We will use this set of numbers:

$$\{82,51,144,84,120,148,148,108,160,86\}$$

The mean is calculated as such:

$$\mu = \frac{82 + 51 + 144 + 84 + 120 + 148 + 148 + 108 + 160 + 86} {10} = 113.1$$

To calculate the median, we first need to order the values from smallest to largets:

$$\{51, 82, 84, 86, 108, 120, 144, 148, 148, 160\}$$

The median is the average of 108 and 120:

$$Median = (108 + 120)/2 = 114$$

To calculate the mode, we simply need to look at the most frequent number: 

$$Mode = 148$$

>You can have more than one mode.

#### 2.1.2.3. Ordered Set Aggregate Functions

1. Median Algorithm
   * Sort all $N$ values from smallest to largest.
   * Inspect the central values for the sorted set:
     * If $N$ is odd:
       * The median is the value in the $\frac{N+1}{2}th$ position.
     * If $N$ is even:
       * The median is the average of the values in the $(N/2)th$ and $1+(N/2)th$ positions.

2. Mode Algorithm
   * Calculate the tally of values similar to a `GROUP BY` and `COUNT`.
   * The mode is the value with the highest number of occurances.

To implement these we need to use Ordered Set Aggregate Functions. Here is an example.

```sql
WITH sample_data (example_values) AS (
 VALUES
 (82), (51), (144), (84), (120), (148), (148), (108), (160), (86)
)
SELECT AVG(example_values) AS mean_value
  , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY example_values) AS median_value
  , MODE() WITHIN GROUP (ORDER BY example_values) AS mode_value
from sample_data;
```

The following is used on real data:

```sql
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS median_value
  , MODE() WITHIN GROUP (ORDER BY measure_value) AS mode_value
  , AVG(measure_value) as mean_value
FROM health.user_logs
WHERE measure = 'weight';
```

## 2.2. Spread of the Data

The spread of the data refers to how how our data is distributed.

### 2.2.1. Min, Max, & Range

The minimum and maximum explain where the edges of our data is. While the range is the difference between the minimum and maximum value.

```sql
SELECT MIN(measure_value) AS minimum_value
  , MAX(measure_value) AS maximum_value
  , MAX(measure_value) - MIN(measure_value) AS range_value
FROM health.user_logs
WHERE measure = 'weight';
```

The following query is slightly more efficient becuase it is not duplicating searching for the min and max values:

```sql
EXPLAIN ANALYZE
WITH min_max_values AS (
  SELECT
    MIN(measure_value) AS minimum_value,
    MAX(measure_value) AS maximum_value
  FROM health.user_logs
  WHERE measure = 'weight'
)
SELECT minimum_value
  , maximum_value
  , maximum_value - minimum_value AS range_value
FROM min_max_values;
```

## 2.3. Variance & Standard Deviation

These two values are used to describe the "spread" of the data. Variance is the square of standard deviation.

### 2.3.1. Variance Algorithm

The mathematical symbol for standard deviation is $\sigma$ and the variance symbol is $\sigma^2$.

The following is the equation for variance:

$$\sigma^2 = \frac{\displaystyle\sum_{i=1}^{n}(x_i - \mu)^2} {n-1}$$

Vairance is the sum of the differences (differences between each X value and the mean) squared, divided by $N-1$.

If we use the sample data that we did for mean, we have 10 numbers:

$$\{82, 51, 144, 84, 120, 148, 148, 108, 160, 86\}$$

Then we calculate the mean:

$$\mu = \frac{82 + 51 + 144 + 84 + 120 + 148 + 148 + 108 + 160 + 86} {10} = 113.1$$

And for this example we will use 82 to find the variance:

$$(82 - 113.1)^2 = 967.21$$

But we have to do this for all the values and that would be tiring by hand:

$$\sigma^2 = \displaystyle\sum_{i=1}^{n}(x_i - \mu)^2$$

$$\frac{(82 - 113.1)^2 + (51 - 113.1)^2 + ... + (86 - 113.1)^2} {10 - 1} = 1340.99$$

Then we can find the standard deviation by taking the square root of the variance:

$$\sigma = 36.62$$

And here is what it looks like in SQL:

```sql
WITH sample_data (example_values) AS (
 VALUES
 (82), (51), (144), (84), (120), (148), (148), (108), (160), (86)
)
SELECT
  ROUND(VARIANCE(example_values), 2) AS variance_value,
  ROUND(STDDEV(example_values), 2) AS standard_dev_value,
  ROUND(AVG(example_values), 2) AS mean_value,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY example_values) AS median_value,
  MODE() WITHIN GROUP (ORDER BY example_values) AS mode_value
FROM sample_data;
```

### 2.3.2. Interpreting Spread

There are 2 ways to interpret spread, normal distribution and empirical rule.

#### 2.3.2.1. Spread for Normal Distribution

The spread for a normal distribution is simply a bell curve. However, in the real world, data is rarely like this until after it is cleaned and processed.

To generate a normal distribution all you need are two things:

1. The average or mean scores of the data.
2. The spread or standard deviation/variance of the data.

As the standard deviation increases so does the spread and vice-versa.

#### 2.3.2.2. The Empirical Rule or Confidence Intervals

If the data is roughly normally distributed, we can make rough generalizations about how much percentage of the total lies between different ranges related to our standard deviation rules.

These are known as confidence intervals or bands - ranges where we are sure the data will lie within.

|**Percentage of Values**|**Range of Values**|
|:----------:|:----------:|
|68%|$\mu \pm \sigma$|
|95%|$\mu \pm 2 \times \sigma$|
|99.7%|$\mu \pm 3 \times \sigma$|

The way to read this table is one standard deviation about the mean contains 68% of values.

## 2.4. Calculation All The Summary Statistic

```sql
SELECT 'weight' AS measure
  , ROUND(MIN(measure_value), 2) AS minimum_value
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

## 2.5. Exercises

### 2.5.1. Average, Median & Mode

*What is the average, median and mode values of blood glucose values to 2 decimal places?*

```sql
SELECT 'blood_glucose' AS measure
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
FROM health.user_logs
WHERE measure = 'blood_glucose';
```

*What is the most frequently occuring `measure_value` value for blood glucose measurements?*

```sql
SELECT measure_value
  , COUNT(*) as frequency
FROM health.user_logs
WHERE measure = 'blood_glucose'
GROUP BY measure_value
ORDER BY COUNT(*) DESC;
```

*Calculate the 2 Pearson Coefficient of Skewness for blood glucose measures given the following formulas:*

Coefficient 1: $Mode Skewness = \frac{Mean - Mode} {Standard Deviation}$

Coefficient 2: $Median Skewness = 3 * \frac{Mean - Median} {Standard Deviation}$

```sql
WITH calc_table AS (
  SELECT ROUND(AVG(measure_value), 2) AS mean
  , ROUND(
    -- this function actually returns a float which is incompatible with ROUND!
    -- we use this cast function to convert the output type to NUMERIC
    CAST(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_value) AS NUMERIC),
    2
  ) AS median
  , ROUND(
    MODE() WITHIN GROUP (ORDER BY measure_value),
    2
  ) AS mode
  , ROUND(STDDEV(measure_value), 2) AS standard_deviation
  FROM health.user_logs
  WHERE measure = 'blood_glucose'
)
SELECT (mean - mode) / standard_deviation AS mode_skewness
  , 3 * (mean - median) / standard_deviation AS median_skewness
FROM calc_table;
```