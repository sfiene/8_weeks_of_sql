# Health Analytics Mini Case Study

TOC

The Health Co analytics team have shared their SQL script. There are bug in it and we have been asked to fix them.

## Business Questions

1. How many unique users exist in the logs dataset?
2. How many total measurements do we have per user on average?
3. What about the median number of measurements per user?
4. How many users have 3 or more measurements?
5. How many users have 1000 or more measurements?
6. Looking at the logs data - What is the number and percentage of the active user base who:
   1. Have logged blood glucose measurements?
   2. Have at least 2 types of measurements?
   3. Have all 3 measures - blood glucose, weight and blood pressure?
7. For users that have blood pressure measurements:
   1. What is the median systolic/diastolic blood pressure values?

## Debug SQL Script

The following is the script from Health Co analytics team to debug.

```sql
-- 1. How many unique users exist in the logs dataset?
-- 2. 554

SELECT COUNT(DISTINCT(id))
FROM health.user_logs;

-- for questions 2-8 we created a temporary table

DROP TABLE IF EXISTS user_measure_count;

CREATE TEMP TABLE user_measure_count AS
SELECT id
    , COUNT(*) AS measure_count
    , COUNT(DISTINCT(measure)) as unique_measures
FROM health.user_logs
GROUP BY id; 

-- 2. How many total measurements do we have per user on average?
-- 2. 79

SELECT ROUND(AVG(measure_count),0) AS average_value
FROM user_measure_count;

-- 3. What about the median number of measurements per user?
-- 3. 2

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY measure_count) AS median_value
FROM user_measure_count;

-- 4. How many users have 3 or more measurements?
-- 4. 209

SELECT count(*)
FROM user_measure_count
WHERE measure_count >= 3;

-- 5. How many users have 1,000 or more measurements?
-- 5. 5

SELECT COUNT(*)
FROM user_measure_count
WHERE measure_count >= 1000;

-- 6. Have logged blood glucose measurements?
-- 6. 325

SELECT COUNT(DISTINCT(id))
FROM health.user_logs
WHERE measure = 'blood_glucose';

-- 7. Have at least 2 types of measurements?
-- 7. 204

SELECT COUNT(*)
FROM user_measure_count
WHERE unique_measures >= 2;

-- 8. Have all 3 measures - blood glucose, weight and blood pressure?
-- 8. 50

SELECT COUNT(*)
FROM user_measure_count
WHERE unique_measures = 3;

-- 9.  What is the median systolic/diastolic blood pressure values?
-- 9. 126/79

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY systolic) AS median_systolic
  , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY diastolic) AS median_diastolic
FROM health.user_logs
WHERE measure = 'blood_pressure';
```