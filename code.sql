-- Task 1
-- setup the db, user, table, and grant user permissions
CREATE DATABASE "a2t1";

CREATE USER "andrew" WITH PASSWORD 'andrew';

CREATE TABLE restaurant (id SERIAL, name VARCHAR(60), address
VARCHAR(80), city VARCHAR(30));

\copy restaurant from '~/a2/a2t1/DataLinkage_py/data/restaurant.csv' with csv

GRANT SELECT ON TABLE "restaurant" TO "andrew";

-- All Task 1 questions answered with code in the following directory
cd ~/a2/a2t1/DataLinkage_py
-- command to run the pyhton code
python3 -m src.data.data_statistics

--Task 2 Question 1
-- Create DB
CREATE DATABASE a2t2;

-- Create the table on PSQL
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  TID INT,  -- Transaction ID (the extra column)
  SID INT,
  FNAME VARCHAR(20),
  LNAME VARCHAR(20),
  STATE VARCHAR(10),
  STORE VARCHAR(20),
  DATE DATE,
  PID INT,
  BRAND VARCHAR(40),
  PRODUCT VARCHAR(40),
  UNIT_COST DECIMAL(10,2),
  QUANTITY INT,
  PRICE DECIMAL(10,2)
);

-- Copy the CSV into the table
\copy sales FROM 'Sales.csv' WITH (FORMAT csv, HEADER true)

-- Create and fill staff dimension table
DROP TABLE IF EXISTS staff;
CREATE TABLE staff (
  SID INT PRIMARY KEY,
  FNAME VARCHAR(20),
  LNAME VARCHAR(20),
  STATE VARCHAR(10),
  STORE VARCHAR(20)
);

INSERT INTO staff (SID, FNAME, LNAME, STATE, STORE)
SELECT DISTINCT SID, FNAME, LNAME, STATE, STORE
FROM sales;

-- Create and fill product dimension table
DROP TABLE IF EXISTS product;
CREATE TABLE product (
  PID INT PRIMARY KEY,
  PRODUCT VARCHAR(40),
  BRAND VARCHAR(40),
  UNIT_COST DECIMAL(10,2)
);

INSERT INTO product (PID, PRODUCT, BRAND, UNIT_COST)
SELECT DISTINCT PID, PRODUCT, BRAND, UNIT_COST
FROM sales;

-- Create and fill time_period dimension table
DROP TABLE IF EXISTS time_period;
CREATE TABLE time_period (
  DATE DATE PRIMARY KEY,
  MONTH INT,
  QUARTER INT,
  YEAR INT
);

INSERT INTO time_period (DATE, MONTH, QUARTER, YEAR)
SELECT DISTINCT
  DATE,
  EXTRACT(MONTH FROM DATE)::INT AS MONTH,
  EXTRACT(QUARTER FROM DATE)::INT AS QUARTER,
  EXTRACT(YEAR FROM DATE)::INT AS YEAR
FROM sales;

-- Create and populate sales_fact fact table
DROP TABLE IF EXISTS sales_fact;
CREATE TABLE sales_fact (
  SID INT REFERENCES staff(SID),
  PID INT REFERENCES product(PID),
  DATE DATE REFERENCES time_period(DATE),
  QUANTITY INT,
  PRICE DECIMAL(10,2)
);

INSERT INTO sales_fact (SID, PID, DATE, QUANTITY, PRICE)
SELECT SID, PID, DATE, QUANTITY, PRICE
FROM sales;

-- Task 2 Question 2a
-- Get a count of unique staff members
SELECT count(*) from staff;

-- Task 2 Question 2b
-- Get a count of how many transactions were made in the third quarter of 2022
SELECT count(*) 
FROM sales_fact 
WHERE date IN (
  SELECT date FROM time_period 
  WHERE quarter = 3 
  AND year = 2022 
);

-- Task 2 Question 3
-- Create cube as materialised view based on sales and time.
DROP MATERIALIZED VIEW IF EXISTS sales_time_staff;

CREATE MATERIALIZED VIEW sales_time_staff AS
SELECT
  s.sid,
  s.state,
  s.store,
  t.date,
  t.month,
  t.quarter,
  t.year,
  SUM(sf.quantity) AS quantity,
  SUM(sf.price) AS price
FROM sales_fact sf
JOIN staff s ON sf.sid = s.sid
JOIN time_period t ON sf.date = t.date
GROUP BY CUBE (
  s.sid, s.state, s.store,
  t.date, t.month, t.quarter, t.year
);

-- Task 2 Question 4
-- Create the view
DROP VIEW IF EXISTS time_staff_sales_view;
CREATE VIEW time_staff_sales_view AS 
SELECT state, quarter, year, SUM(price) AS profit
FROM sales_time_staff
WHERE state IS NOT null AND year IS NOT NULL
GROUP BY state, year, quarter;

-- Query for view to answer first table
select state, year, quarter, profit 
from time_staff_sales_view 
where year = 2021 and quarter is not null;

-- Query for veiw to answer second table
select state, year, quarter, profit 
from time_staff_sales_view 
where quarter is null;

-- Task 2 Question 5
-- Making a cube with sales and product heirarchies
DROP MATERIALIZED VIEW IF EXISTS sales_product_staff;

CREATE MATERIALIZED VIEW sales_product_staff AS
SELECT
  s.sid,
  s.state,
  s.store,
  p.pid,
  p.product,
  p.brand,
  p.unit_cost,
  SUM(sf.quantity) AS quantity,
  SUM(sf.price) AS sale_price
FROM sales_fact sf
JOIN staff s ON sf.sid = s.sid
JOIN product p ON sf.pid = p.pid
GROUP BY CUBE (
  s.sid, s.state, s.store,
  p.pid, p.product, p.brand, p.unit_cost
);

-- Task 2 Question 5a
-- Create view to get top 3 gross profit stores
DROP VIEW IF EXISTS top_three_gross_profit_stores;

CREATE VIEW top_three_gross_profit_stores AS
SELECT sid, store, SUM(gross_profit) AS gross_profit
FROM (
  SELECT sid, store, pid, quantity, unit_cost, sale_price, 
  (quantity * (sale_price - unit_cost)) AS gross_profit
  FROM sales_product_staff
  WHERE pid IS NOT NULL
    AND store IS NOT NULL
    AND quantity IS NOT NULL
    AND unit_cost IS NOT NULL
    AND sale_price IS NOT NULL
    AND sid IS NOT NULL
    AND state IS NOT NULL
    AND product IS NOT NULL
    AND brand IS NOT NULL
) AS product_gross_profits
GROUP BY sid, store
ORDER BY gross_profit DESC
LIMIT 3;

-- Task 2 Question 5b
DROP VIEW IF EXISTS top_product_per_store;

CREATE VIEW top_product_per_store AS
SELECT sid, store, pid
FROM (
  SELECT
    sid,
    store,
    pid,
    (quantity * (sale_price - unit_cost)) AS gross_profit,
    -- Partitions unique PID's, orders them by gross_profit, and then 
    -- ranks them from 1 to n
    ROW_NUMBER() OVER (
      PARTITION BY sid
      ORDER BY (quantity * (sale_price - unit_cost)) DESC
    ) AS rn
  FROM (
    SELECT sid, store, pid, quantity, unit_cost, sale_price
    FROM sales_product_staff
    WHERE pid IS NOT NULL
      AND store IS NOT NULL
      AND quantity IS NOT NULL
      AND unit_cost IS NOT NULL
      AND sale_price IS NOT NULL
      AND sid IS NOT NULL
      AND state IS NOT NULL
      AND product IS NOT NULL
      AND brand IS NOT NULL
  ) AS temp
) AS ranked
-- Take only the top value from the previously partitioned groups to 
-- Get the highest grossing product for each store
WHERE rn = 1
ORDER BY sid;