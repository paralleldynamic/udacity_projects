city_data
year
city
country
avg_temp

global_data
year
avg_temp

SELECT count(*)
FROM city_data
WHERE avg_temp Is Null;
--2547 / 71311


SELECT city, count(*)
FROM city_data
WHERE avg_temp Is Null
GROUP BY city
ORDER BY count(*) asc;


SELECT T1.year,
       T1.city,
       T1.avg_temp as city_average_temp,
       T2.avg_temp as global_average_temp,
       AVG(T1.avg_temp)
            OVER(ORDER BY T1.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_city_average_temp,
       AVG(T2.avg_temp)
            OVER(ORDER BY T2.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_global_average_temp
FROM city_data T1
FULL OUTER JOIN global_data T2 ON T1.year = T2.year
WHERE T1.city IN ('Chicago')
ORDER BY T1.city, T1.year;


-- test data set sample

SELECT T1.year,
       T1.city,
       T1.avg_temp as city_average_temp,
       T2.avg_temp as global_average_temp,
       AVG(T1.avg_temp)
            OVER(PARTITION BY T1.city ORDER BY T1.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_city_average_temp,
       AVG(T2.avg_temp)
            OVER(PARTITION BY T1.city ORDER BY T2.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_global_average_temp
FROM city_data T1
FULL OUTER JOIN global_data T2 ON T1.year = T2.year
WHERE T1.city IN ('Chicago', 'Sydney', 'Copenhagen', 'Munich', 'Shenzhen', 
                  'New Delhi', 'Manila', 'Moscow', 'Stockholm', 'Johannesburg')
ORDER BY T1.city, T1.year;


-- global moving average was off b/c not every city shared the same years of data
-- min year of 1749, excluding New Dehli from calculations
SELECT T1.year,
       T1.city,
       T1.avg_temp as city_average_temp,
       T2.avg_temp as global_average_temp,
       AVG(T1.avg_temp)
            OVER(PARTITION BY T1.city ORDER BY T1.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_city_average_temp,
       AVG(T2.avg_temp)
            OVER(PARTITION BY T1.city ORDER BY T2.year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_global_average_temp
FROM city_data T1
FULL OUTER JOIN global_data T2 ON T1.year = T2.year
WHERE T1.city IN ('Chicago', 'Sydney', 'Copenhagen', 'Munich', 'Shenzhen',
                  'Manila', 'Moscow', 'Stockholm', 'Johannesburg')
      AND T1.year > 1749
ORDER BY T1.city, 
         T1.year;
         
         
-- restructuring data to work with Excel
SELECT year,
       city,
       avg_temp,
       AVG(avg_temp)
            OVER(PARTITION BY city ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
            as moving_average_temp
FROM city_data T1
WHERE city IN ('Chicago', 'Sydney', 'Copenhagen', 'Munich', 'Shenzhen',
                  'Manila', 'Moscow', 'Stockholm', 'Johannesburg')
      AND year > 1749
UNION SELECT year,
       'Global',
       avg_temp,
       AVG(avg_temp)
            OVER(ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM global_data
WHERE year > 1749
ORDER BY city, 
         year;