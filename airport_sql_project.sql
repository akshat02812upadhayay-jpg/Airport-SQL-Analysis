SHOW DATABASES;
USE airport_db;

SHOW TABLES;

SELECT * FROM airports; 
-- COLUMNS -> Origin_airport, Destination_airport, Origin_city, Destination_city, 
-- Passengers, Seats, Flights, Distance, Fly_date, Origin_population, Destination_population, 
-- Org_airport_lat, Org_airport_long, Dest_airport_lat, Dest_airport_long

## Problem Statement 1 : 

-- The objective is to calculate the total number of passengers for each pair of origin and destination airports.

SELECT 
	Origin_airport,
    Destination_airport,
    SUM(Passengers) as total_passengers
FROM airports
GROUP BY Origin_airport, Destination_airport
ORDER BY total_passengers DESC;


-- This analysis will provide insights into travel patterns between specific airport pairs,
-- helping to identify the most frequented routes and enhance strategic planning for airline operations.

## Problem Statement 2 :

-- Here the goal is to calculate the average seat utilization for each flight by dividing the number of passengers by the total number of seats available. 

SELECT 
	Origin_airport,
    Destination_airport,
    AVG(Passengers/NULLIF(seats,0))*100.0 AS avg_seat_utilization
FROM airports
GROUP BY Origin_airport, Destination_airport
ORDER BY avg_seat_utilization DESC;

-- The results will be sorted in descending order based on utilization percentage.
-- This analysis will help identify flights with the highest and lowest seat occupancy, 
-- providing valuable insights for optimizing flight capacity and enhancing operational efficiency.

## Problem Statement 3 :

-- The aim is to determine the top 5 origin and destination airport pairs that have the highest total passenger volume. 

SELECT 
	Origin_airport,
	Destination_airport,
    SUM(Passengers) AS passenger_volume
FROM airports
GROUP BY Origin_airport,Destination_airport 
ORDER BY passenger_volume DESC 
limit 5;

-- This analysis will reveal the most frequented travel routes, allowing airlines to optimize resource allocation 
-- and enhance service offerings based on passenger demand trends

## Problem Statement 4 :

-- The objective is to calculate the total number of flights and passengers departing from each origin city. 

SELECT 
	origin_city, 
    SUM(flights) AS num_of_flights,
    SUM(Passengers) AS total_passengers
FROM airports
GROUP BY origin_city
ORDER BY total_passengers DESC;

## Problem Statement 5 : 

-- The aim is to calculate the total distance flown by flights originating from each airport.

SELECT 
	Origin_airport,
    SUM(Distance) AS total_distance,
    SUM(flights) AS total_flights
FROM airports
GROUP BY Origin_airport
ORDER BY total_distance DESC ;

-- This insight help airport to forecast fuel demand and operational reach of an airport.

## Problem Statement 6 :

-- The objective is to group flights by month and year using the Fly_date column to calculate the number of flights,
-- total passengers, and average distance traveled per month.

SELECT 
	YEAR(Fly_date) AS year,
    MONTH(Fly_date) AS month,
    SUM(flights) AS number_of_flights,
    SUM(Passengers) AS total_passengers,
    AVG(Distance) AS avg_distance
FROM airports
GROUP BY year, month
ORDER BY year DESC ;

-- This analysis will provide a clearer understanding of seasonal trends and operational performance over time, 
-- identifying peak vs lean season, resource and staff planning etc.

## Problem Statement 7 : 

-- The goal is to calculate the passenger-to-seats ratio for each origin and destination route
-- and filter the results to display only those routes where this ratio is less than 0.5. 

SELECT 
	Origin_airport,
    Destination_airport,
    SUM(Passengers) * 1.0/ NULLIF(SUM(seats), 0)  AS Passenger_to_Seats_Ratio
FROM airports
GROUP BY Origin_airport, Destination_airport
HAVING Passenger_to_Seats_Ratio <= 0.5
ORDER BY Passenger_to_Seats_Ratio ASC;

-- This analysis will help identify underutilized routes, enabling airlines to make informed decisions about capacity management and potential route adjustments.

## Problem Statement 8 : 

-- The aim is to determine the top 10 origin airports with the highest frequency of flights. 

SELECT
	Origin_airport,
    SUM(Flights) AS flight_frequency
FROM airports
GROUP BY Origin_airport
ORDER BY flight_frequency DESC
LIMIT 10;


-- This analysis will highlight the most active airports in terms of flight operations, 
-- providing valuable insights for airlines and stakeholders to optimize scheduling and improve service offerings at these critical locations.


## Problem Statement 9 :

-- The objective is to identify the cities (excluding Bend, OR) that sends the most flights and passengers to Bend, OR. 

SELECT
	origin_city,
    SUM(Flights) AS total_flights,
    SUM(Passengers) AS total_passengers
FROM airports
WHERE Destination_city = "Bend, OR"
	AND Origin_city <> "Bend, OR"
GROUP BY origin_city
ORDER BY total_flights DESC, total_passengers DESC;


-- This analysis will reveal key contributors to passenger traffic at Bend, OR, 
-- helping airlines and travel authorities understand demand patterns and enhance connectivity from popular originating cities.

## Problem Statement 10 : 

-- The aim is to identify the longest flight route in terms of distance traveled, including both the origin and destination airports. 

SELECT 
	Origin_airport,
    Destination_airport,
    MAX(Distance) AS max_distance
FROM airports
GROUP BY Origin_airport, Destination_airport
ORDER BY max_distance DESC;

-- This analysis will provide insights into the most extensive travel connections,
-- helping airlines assess operational challenges and opportunities for long-haul service planning.

## Problem Statement 11 : 

-- The objective is to determine the most and least busy months by flight count across multiple years. 

WITH flight_details AS (
	SELECT 
		YEAR(Fly_date) AS year, 
		MONTH(Fly_date) AS month,
		SUM(flights) AS total_flight_count,
		ROW_NUMBER() OVER (PARTITION BY YEAR(Fly_date) ORDER BY SUM(flights) DESC) AS "Max_count",
		ROW_NUMBER() OVER (PARTITION BY YEAR(Fly_date) ORDER BY SUM(flights)) AS "Min_count"
	FROM airports
	GROUP BY year, month
	ORDER BY year DESC, month
)
SELECT 
	year,
    month,
    total_flight_count
FROM flight_details
WHERE (Max_count = 1 AND Min_count = 12)
	OR (Max_count = 12 AND Min_count = 1)
ORDER BY year DESC, total_flight_count DESC;

-- This analysis will provide insights into seasonal trends in air travel,
-- helping airlines and stakeholders understand peak and off-peak periods for better operational planning and resource allocation.


## Problem Statement 12 : 

-- The aim is to calculate the year-over-year percentage growth in the total number of passengers for each origin and destination airport pair.

WITH passenger_details AS (
SELECT 
	Origin_airport,
	Destination_airport,
	YEAR(Fly_date) AS year,
	SUM(Passengers) AS total_passenger,
	LAG(SUM(Passengers)) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY YEAR(Fly_date)) AS pre_year_passenger
FROM airports
GROUP BY Origin_airport, Destination_airport, year
)
SELECT 
	Origin_airport,
	Destination_airport,
    year,
    CASE 
    WHEN pre_year_passenger IS NOT NULL THEN
		CONCAT(ROUND(((total_passenger - pre_year_passenger) *100.0 / NULLIF(pre_year_passenger, 0)),2), "%")
    ELSE NULL 
    END AS growth_percent 
FROM passenger_details
ORDER BY Origin_airport, Destination_airport ,year DESC;

-- This analysis will help identify trends in passenger traffic over time,
-- providing valuable insights for airlines to make informed decisions about route development 
-- and capacity management based on demand fluctuations.

## Problem Statement 13 : 

-- The objective is to calculate the total number of flights and passengers for each year, 
-- along with the percentage growth in both flights and passengers compared to the previous year. 

WITH Yearly_Summary AS (
    SELECT 
        YEAR(Fly_date) AS Year, 
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers
    FROM 
        airports
    GROUP BY 
        Year
),

Yearly_Growth AS (
    SELECT 
        Year,
        Total_Flights,
        Total_Passengers,
        LAG(Total_Flights) OVER (ORDER BY Year) AS Prev_Flights,
        LAG(Total_Passengers) OVER (ORDER BY Year) AS Prev_Passengers
    FROM 
        Yearly_Summary
)

SELECT 
    Year,
    Total_Flights,
    Total_Passengers,
    ROUND(((Total_Flights - Prev_Flights) / NULLIF(Prev_Flights, 0) * 100), 2) AS Flight_Growth_Percentage,
    ROUND(((Total_Passengers - Prev_Passengers) / NULLIF(Prev_Passengers, 0) * 100), 2) AS Passenger_Growth_Percentage
FROM 
    Yearly_Growth
ORDER BY 
    Year;

    
-- This analysis will provide a comprehensive overview of annual trends in air travel,
-- enabling airlines and stakeholders to assess growth patterns and 
-- make informed strategic decisions for future operations.

