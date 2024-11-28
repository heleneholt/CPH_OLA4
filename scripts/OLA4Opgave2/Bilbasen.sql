CREATE DATABASE bilbasen;
USE bilbasen;

# DROP TABLES dealers, cars, car_variant_data;

CREATE TABLE dealers (
    dealer_id INT PRIMARY KEY,
    dealer VARCHAR(100) NOT NULL,
    street VARCHAR(100) DEFAULT'Unknown',
    post_code INT,
    city VARCHAR(30) DEFAULT'Unknown',
    country VARCHAR(30) NOT NULL,
    cvr_no INT DEFAULT 0);

CREATE TABLE cars (
    car_id INT PRIMARY KEY,
    make VARCHAR(30) NOT NULL,
    model VARCHAR(30) NOT NULL,
    doors INT DEFAULT 4,
    first_registration VARCHAR(30) DEFAULT 'Unknown',
    km INT DEFAULT 0,
    reach DECIMAL(10, 2) DEFAULT 0,
    gear VARCHAR(30) DEFAULT'Unknown',
    fuel_type VARCHAR(30) DEFAULT'Unknown',
    horsepower VARCHAR(30) DEFAULT 'Unknown',
    link varchar(255),
    dealer_id INT NOT NULL,
    FOREIGN KEY (dealer_id) REFERENCES dealers(dealer_id));

CREATE TABLE car_variant_data (
    variant_id INT PRIMARY KEY,
    car_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    age_in_months INT DEFAULT 0,
    Sales_text TEXT,
    sold BOOLEAN DEFAULT FALSE,
    latest BOOLEAN,
    timestamp TIMESTAMP,
    FOREIGN KEY (car_id) REFERENCES cars(car_id));
    
UPDATE car_variant_data cvd
JOIN (
    SELECT car_id, variant_id
    FROM (
        SELECT car_id, variant_id,
               ROW_NUMBER() OVER (PARTITION BY car_id ORDER BY timestamp DESC) AS row_num
        FROM car_variant_data
    ) ranked
    WHERE row_num = 1
) latest_entry ON cvd.car_id = latest_entry.car_id
SET cvd.latest = CASE
                    WHEN cvd.variant_id = latest_entry.variant_id THEN TRUE
                    ELSE FALSE
                 END;
                 
SELECT *
FROM car_variant_data
WHERE car_id IN (
    SELECT car_id
    FROM car_variant_data
    GROUP BY car_id
    HAVING COUNT(*) > 1
);

