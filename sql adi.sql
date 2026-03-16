create database OLA_INSIGHTS_PROJECT
use OLA_INSIGHTS_PROJECT;
CREATE TABLE ola_rides (
    Date DATE,
    Time TIME,
    Booking_ID VARCHAR(50) PRIMARY KEY,
    Booking_Status VARCHAR(50),
    Customer_ID VARCHAR(50),
    Vehicle_Type VARCHAR(50),
    Pickup_Location VARCHAR(255),
    Drop_Location VARCHAR(255),
    V_TAT INT,
    C_TAT INT,
    Canceled_Rides_by_Customer VARCHAR(255),
    Canceled_Rides_by_Driver VARCHAR(255),   
    Incomplete_Rides VARCHAR(50),            
    Incomplete_Rides_Reason VARCHAR(255),
    Booking_Value FLOAT, -- currency so i kept it as float
    Payment_Method VARCHAR(50),
    Ride_Distance FLOAT,
    Driver_Ratings FLOAT,
    Customer_Rating FLOAT
);

select * from ola_rides limit 10;
truncate table ola_rides;
-- loading data via infile commands instead of wizard
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/OLA_DataSet_csvconverted.csv'
INTO TABLE ola_rides
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- This skips the header row in your CSV

ALTER TABLE ola_rides MODIFY COLUMN V_TAT VARCHAR(50);
ALTER TABLE ola_rides MODIFY COLUMN C_TAT VARCHAR(50);
ALTER TABLE ola_rides MODIFY COLUMN Driver_Ratings VARCHAR(50);
ALTER TABLE ola_rides MODIFY COLUMN Customer_Rating VARCHAR(50);

-- Convert the word 'null' to a real empty NULL value
UPDATE ola_rides SET V_TAT = NULL WHERE V_TAT = 'null' OR V_TAT = '';
UPDATE ola_rides SET C_TAT = NULL WHERE C_TAT = 'null' OR C_TAT = '';
-- Change the column type back to Integer
ALTER TABLE ola_rides MODIFY COLUMN V_TAT INT;
ALTER TABLE ola_rides MODIFY COLUMN C_TAT INT;
UPDATE ola_rides 
SET Driver_Ratings = NULL 
WHERE Driver_Ratings = 'null' OR Driver_Ratings = '';

UPDATE ola_rides 
SET Customer_Rating = NULL 
WHERE Customer_Rating = 'null' OR Customer_Rating = '';
ALTER TABLE ola_rides MODIFY COLUMN Driver_Ratings FLOAT;
ALTER TABLE ola_rides MODIFY COLUMN Customer_Rating FLOAT;
select Customer_Rating FROM ola_rides
/*just for verification SELECT Vehicle_Type, AVG(Driver_Ratings) 
FROM ola_rides 
WHERE Driver_Ratings IS NOT NULL 
GROUP BY Vehicle_Type;*/

SHOW VARIABLES LIKE "secure_file_priv";

SELECT COUNT(*) FROM ola_rides;

-- 1.Retrieve all successful bookings
SELECT * FROM ola_rides WHERE Booking_Status = 'Success';
-- 2. Find the average ride distance for each vehicle type
SELECT Vehicle_Type,  ROUND(AVG(Ride_Distance), 2) AS avg_distance
FROM ola_rides
GROUP BY Vehicle_Type;

-- 3.Get the total number of cancelled rides by customers
SELECT COUNT(*) FROM ola_rides 
WHERE Booking_Status = 'Canceled by Customer';

-- 4.List the top 5 customers who booked the highest number of rides
SELECT Customer_ID, COUNT(Booking_ID) as total_rides 
FROM ola_rides 
GROUP BY Customer_ID 
ORDER BY total_rides DESC LIMIT 5;

-- 5. Get the number of rides cancelled by drivers due to "Personal & Car related issues"
SELECT COUNT(*) FROM ola_rides 
WHERE Canceled_Rides_by_Driver = 'Personal & Car related issue';
-- 6. Find the maximum and minimum driver ratings for Prime Sedan bookings
SELECT MAX(Driver_Ratings) as max_rating, MIN(Driver_Ratings) as min_rating 
FROM ola_rides WHERE Vehicle_Type = 'Prime Sedan';

-- 7.Retrieve all rides where payment was made using UPI
SELECT count(*) FROM ola_rides WHERE Payment_Method = 'UPI'; -- 25881 upi methods
SELECT * FROM ola_rides WHERE Payment_Method = 'UPI';

-- 8.Find the average customer rating per vehicle type
SELECT Vehicle_Type, AVG(Customer_Rating) as avg_rating 
FROM ola_rides 
GROUP BY Vehicle_Type;


-- 9.Calculate the total booking value of rides completed successfully
SELECT SUM(Booking_Value) as total_successful_value 
FROM ola_rides 
WHERE Booking_Status = 'Success';
-- 10.List all incomplete rides along with the reason
SELECT Booking_ID, Incomplete_Rides_Reason 
FROM ola_rides 
WHERE Incomplete_Rides = 'Yes';