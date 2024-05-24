-- weather-dql.sql

-- 1.
SELECT details ->> 'name' name,  
  details ->> 'weather' weather_description, 
  details ->> 'wind' wind, 
  createdon, id  
FROM  weather.info
ORDER BY name, id;

-- 2.
SELECT DISTINCT  details ->> 'name' name,  
  details ->> 'name' name,
  details ->> 'weather' weather_description, 
  details -> 'main' ->> 'temp' as temp_deg_C,
  details -> 'main' ->> 'humidity' as humd_percent,
  details -> 'main' ->> 'pressure' as press_hPa,
  details -> 'wind' ->> 'deg' as wind_direc_deg,
  details -> 'wind' ->> 'gust' as wind_gust_meter_p_sec,
  details -> 'wind' ->> 'speed' as wind_speed_meter_p_sec,
  createdon,
  id  
FROM  weather.info 
ORDER BY name, id;

-- 3.
SELECT wi.details ->> 'name' name,  
  wi.details -> 'weather' ->0 ->> 'description' AS weather_description, 
  wi.details -> 'main' ->> 'temp' temp_deg_C,
  wi.details -> 'main' ->> 'humidity' AS humd_percent,
  wi.details -> 'main' ->> 'pressure' AS press_hPa,
  wi.details -> 'wind' ->> 'deg' AS wind_direc_deg,
  wi.details -> 'wind' ->> 'gust' AS wind_gust_meter_p_sec,
  wi.details -> 'wind' ->> 'speed' AS wind_speed_meter_p_sec,
  wi.createdon,
  id  
FROM  weather.info wi
WHERE details ->> 'name' IN (
  'Gaborone', 'Abuja', 'Akure', 'Cairo', 'Dubai', 
  'Muscat', 'Lagos', 'Katy', 'Houston', 'Tokyo', 
  'Delhi', 'Austin',  'London', 'Moscow', 'Taipei', 
  'Edmonton', 'San Rafael', 'Helsinki', 'New York', 
  'Los Angeles'                  
)
AND details -> 'main' ->> 'temp' > '10'
ORDER BY name, id;

-- 4.
SELECT COUNT(*) FROM  weather.info;
