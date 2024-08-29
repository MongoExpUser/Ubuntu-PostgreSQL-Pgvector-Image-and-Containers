-- weather-dql.sql

-- 1.
SELECT 
  wi.details ->> 'name' name,  
  wi.details ->> 'weather' weather_description, 
  wi.details ->> 'wind' wind, 
  wi.createdon, 
  wi.id  
FROM  weather.info wi
ORDER BY name, id;

-- 2.
SELECT DISTINCT  
  wi.details ->> 'name' name,  
  wi.details ->> 'name' AS city_name,
  wi.details ->> 'weather' AS weather_description, 
  wi.details -> 'main' ->> 'temp' AS temp_deg_C,
  wi.details -> 'main' ->> 'humidity' AS humd_percent,
  wi.details -> 'main' ->> 'pressure' AS press_hPa,
  wi.details -> 'wind' ->> 'deg' AS wind_direc_deg,
  wi.details -> 'wind' ->> 'gust' AS wind_gust_meter_p_sec,
  wi.details -> 'wind' ->> 'speed' AS wind_speed_meter_p_sec,
  wi.createdon,
  wi.id  
FROM  weather.info wi
ORDER BY name, id;

-- 3.
SELECT 
  wi.details ->> 'name' AS city_name,
  wi.details -> 'weather' ->0 ->> 'description' AS weather_description, 
  wi.details -> 'main' ->> 'temp' AS temp_deg_C,
  wi.details -> 'main' ->> 'humidity' AS humd_percent,
  wi.details -> 'main' ->> 'pressure' AS press_hPa,
  wi.details -> 'wind' ->> 'deg' AS wind_direc_deg,
  wi.details -> 'wind' ->> 'gust' AS wind_gust_meter_p_sec,
  wi.details -> 'wind' ->> 'speed' AS wind_speed_meter_p_sec,
  wi.createdon,
  wi.id  
FROM  weather.info wi
WHERE details ->> 'name' IN (
  'Gaborone', 'Abuja', 'Akure', 'Cairo', 'Dubai', 
  'Muscat', 'Lagos', 'Katy', 'Houston', 'Tokyo', 
  'Delhi', 'Austin',  'London', 'Moscow', 'Taipei', 
  'Edmonton', 'San Rafael', 'Helsinki', 'New York', 
  'Los Angeles', 'San Antonio', 'Sydney', 'Rijswijk',
  'Bahir Dar', 'Casablanca', 'Toronto', 'Dhaka',
  'Bangui', 'Cape Town', 'Beijing'
)
AND details -> 'main' ->> 'temp' > '10'
ORDER BY name ASC, id;

-- 4.
SELECT COUNT(*) FROM  weather.info;
