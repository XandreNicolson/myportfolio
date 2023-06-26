-- Query 1: first we combined all 12 datasets

SELECT  * FROM `inner-doodad-382022.Capstone1.Apr2023` 
UNION ALL
SELECT * FROM `inner-doodad-382022.Capstone1.Aug2022`
UNION ALL
SELECT * FROM `inner-doodad-382022.Capstone1.Dec2022`
UNION ALL
SELECT * FROM `inner-doodad-382022.Capstone1.Feb2022`
UNION ALL 
SELECT* FROM `inner-doodad-382022.Capstone1.Jan2023`
UNION ALL
SELECT * FROM `inner-doodad-382022.Capstone1.Jul2022`
UNION ALL 
SELECT * FROM `inner-doodad-382022.Capstone1.Jun2022`
UNION ALL
SELECT * FROM `inner-doodad-382022.Capstone1.Mar2023`
UNION ALL 
SELECT * FROM `inner-doodad-382022.Capstone1.May2022`
UNION ALL 
SELECT * FROM `inner-doodad-382022.Capstone1.Nov2022`
UNION ALL 
SELECT * FROM `inner-doodad-382022.Capstone1.Oct2022`
UNION ALL 
SELECT * FROM `inner-doodad-382022.Capstone1.Sep2022`
;

/*
  we saved this as a new table: cyclistic_data_union,
  then proceed to clean column by column as planned.
*/

-- Query 2: finding length of ride_id to ensure uniforminty 
SELECT 
  LENGTH (ride_id) AS string_length
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union` 
GROUP BY
  string_length
;

-- Query 3: checked to see if there were any duplicates in ride_id
SELECT 
  COUNT (ride_id) AS count_id,
  COUNT (DISTINCT ride_id) AS distinct_id
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
;

-- Query 4: changed docked_bike to classic_bike as these referenced the same item
UPDATE
 `inner-doodad-382022.Capstone1.cyclistic_data_union` 
SET
  rideable_type = 'classic_bike'
WHERE
  rideable_type = 'docked_bike'
;

-- Query 5: next we checked for null in the started_at/end_at column but found none
UPDATE
 `inner-doodad-382022.Capstone1.cyclistic_data_union` 
SET
  rideable_type = 'classic_bike'
WHERE
  rideable_type = 'docked_bike'
;

-- Query 6: then eliminated all rides under one minute (removed 140515 rows)
DELETE FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
WHERE
 TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1
;

-- Query 7: looked for null in start_station_name for classic_bikes but found none
SELECT 
  *
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union` 
WHERE
  rideable_type = 'classic_bike'
  AND
  start_station_name IS NULL
;

-- Query 8: elimnated nulls in end_station_name for classic_bikes (removed 6,069 rows)
DELETE FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
WHERE
  rideable_type = 'classic_bike'
  AND
  end_station_name IS NULL
;

-- Query 9: checked consistent naming for start/end_station_name but no issues
SELECT  
  COUNT (DISTINCT start_station_name) AS name,
  COUNT (DISTINCT TRIM (start_station_name)) AS trimmed_name,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
;
SELECT  
  COUNT (DISTINCT end_station_name) AS name,
  COUNT (DISTINCT TRIM (end_station_name)) AS trimmed_name,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
;

-- Query 10: removed station_id as it felt redundent
CREATE OR REPLACE TABLE `inner-doodad-382022.Capstone1.cyclistic_data_union` AS
SELECT
 * EXCEPT (start_station_id, end_station_id) 
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`  
;

/* 
  Query 11 = added columns for trip_duration, day, and month and saved 
  as a new table: cyclistic_data_time_columns
*/
SELECT  
 *,
 CASE
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 1 THEN 'Sun'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 2 THEN 'Mon'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 3 THEN 'Tue'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 4 THEN 'Wed'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 5 THEN 'Thu'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 6 THEN 'Fri'
  WHEN EXTRACT(DAYOFWEEK FROM started_at) = 7 THEN 'Sat'
 END AS day_of_week,
 CASE
  WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'Jan' 
  WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'Feb'
  WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'Mar'
  WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'Apr'
  WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
  WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'Jun'
  WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'Jul'
  WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'Aug'
  WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'Sep'
  WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'Oct'
  WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'Nov'
  WHEN EXTRACT(MONTH FROM started_at) = 12 THEN 'Dec'
 END AS month,
 TIMESTAMP_DIFF (ended_at, started_at, MINUTE) as trip_duration 
FROM `inner-doodad-382022.Capstone1.cyclistic_data_union`
;

-- Query 12 = removed any rides longer than a full day
DELETE FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns` 
WHERE
  trip_duration > 1440
;

-- Query 13 = added a time_of_day column as an update to the table
CREATE OR REPLACE TABLE `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`AS
SELECT  
  *,
  CASE
    WHEN EXTRACT(TIME FROM started_at) <= '03:59:59' THEN 'Night'
    WHEN EXTRACT(TIME FROM started_at) <='11:55:59' THEN 'Morning'
    WHEN EXTRACT(TIME FROM started_at) <= '17:55:59' THEN 'Afternoon'
    WHEN EXTRACT(TIME FROM started_at) <= '21:55:59' THEN 'Evening'
    ELSE 'Night' 
  END as time_of_day,  
FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`
;

-- Query 14 = created separate tables for the top 50 start & end stations used for each rider type
SELECT  
  end_station_name,
  end_lat,
  end_lng,
  member_casual,
  COUNT (end_station_name) AS num_of_trip_end_station,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`
WHERE 
  member_casual = 'casual'
GROUP BY 
  end_station_name,
  end_lat,
  end_lng,
  member_casual
ORDER BY num_of_trip_end_station DESC
LIMIT 50
;

SELECT  
  start_station_name,
  start_lat,
  start_lng,
  member_casual,
  COUNT (start_station_name) AS num_of_trip_start_station,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`
WHERE 
  member_casual = 'casual'
GROUP BY 
  start_station_name,
  start_lat,
  start_lng,
  member_casual
ORDER BY num_of_trip_start_station DESC
LIMIT 50
;

SELECT  
  end_station_name,
  end_lat,
  end_lng,
  member_casual,
  COUNT (end_station_name) AS num_of_trip_end_station,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`
WHERE 
  member_casual = 'member'
GROUP BY 
  end_station_name,
  end_lat,
  end_lng,
  member_casual
ORDER BY num_of_trip_end_station DESC
LIMIT 50
;

SELECT  
  start_station_name,
  start_lat,
  start_lng,
  member_casual,
  COUNT (start_station_name) AS num_of_trip_start_station,
FROM `inner-doodad-382022.Capstone1.cyclistic_data_time_columns`
WHERE 
  member_casual = 'member'
GROUP BY 
  start_station_name,
  start_lat,
  start_lng,
  member_casual
ORDER BY num_of_trip_start_station DESC
LIMIT 50
;

--data cleaning complete
