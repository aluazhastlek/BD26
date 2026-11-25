-- ============================================================
-- Laboratory Work 9: Stored Procedures and User-Defined Functions
-- Part 1: Database Setup  (CityBike rental network)
-- ============================================================

DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;

-- Create table: stations
CREATE TABLE stations (
    station_id   INT PRIMARY KEY,
    station_name VARCHAR(50) NOT NULL,
    city         VARCHAR(40) NOT NULL,
    capacity     INT NOT NULL
);

-- Create table: bikes
CREATE TABLE bikes (
    bike_id    INT PRIMARY KEY,
    model      VARCHAR(50) NOT NULL,
    station_id INT REFERENCES stations(station_id),
    daily_rate NUMERIC(8,2) NOT NULL
);

-- Create table: members
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    full_name VARCHAR(60) NOT NULL,
    city      VARCHAR(40) NOT NULL,
    joined_on DATE NOT NULL
);

-- Create table: rentals
CREATE TABLE rentals (
    rental_id  INT PRIMARY KEY,
    member_id  INT REFERENCES members(member_id),
    bike_id    INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
    end_date   DATE,
    fee        NUMERIC(8,2)
);

INSERT INTO stations VALUES
 (10, 'Central Park', 'Almaty',   4),
 (20, 'Riverside',    'Almaty',   3),
 (30, 'Expo Gate',    'Astana',   5),
 (40, 'Old Town',     'Shymkent', 2),
 (50, 'Depot',        'Astana',   0);

INSERT INTO bikes VALUES
 (101, 'City Cruiser', 10,  4.50),
 (102, 'City Cruiser', 10,  4.50),
 (103, 'Mountain X',   20,  7.00),
 (104, 'Mountain X',   30,  7.00),
 (105, 'Road Sprint',  30,  9.25),
 (106, 'Folding Mini', 40,  3.75),
 (107, 'Cargo Hauler', 20, 12.00),
 (108, 'Road Sprint',  10,  9.25);

INSERT INTO members VALUES
 (1, 'Aisha Nurlanova', 'Almaty',   DATE '2023-03-14'),
 (2, 'Daniyar Serik',   'Almaty',   DATE '2023-07-02'),
 (3, 'Marta Kowalski',  'Astana',   DATE '2024-01-20'),
 (4, 'Chen Wei',        'Astana',   DATE '2024-05-11'),
 (5, 'Omar Haddad',     'Shymkent', DATE '2024-09-30'),
 (6, 'Elena Petrova',   'Almaty',   DATE '2025-02-05');

INSERT INTO rentals VALUES
 ( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
 ( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
 ( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
 ( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
 ( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02',  4.50),
 ( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
 ( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
 ( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
 ( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
 (10, 3, 104, DATE '2025-01-09', DATE '2025-01-10',  7.00),
 (11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
 (12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
 (13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
 (14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
 (15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
 (16, 5, 106, DATE '2025-01-18', DATE '2025-01-20',  7.50),
 (17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
 (18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
 (19, 1, 101, DATE '2025-10-10', NULL,              NULL),
 (20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
 (21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
 (22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);


-- Part 1: Verify Database Setup
SELECT
    (SELECT COUNT(*) FROM stations) AS stations,
    (SELECT COUNT(*) FROM bikes) AS bikes,
    (SELECT COUNT(*) FROM members) AS members,
    (SELECT COUNT(*) FROM rentals) AS rentals;

--Part 2: Your(My) First Function
-- Exercise 2.1: A function over one row
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    SELECT end_date - start_date INTO result
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT rental_days(2);
SELECT rental_days(11);
SELECT rental_days(19);
SELECT rental_days(999);
--Answer:Rental 19 returns NULL because its end_date is NULL. Rental 999 returns NULL because no matching row exists.

-- Exercise 2.2: A function over many rows
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    result INT;
BEGIN
    SELECT COUNT(*) INTO result
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1);
SELECT member_rental_count(5);
SELECT member_rental_count(6);
SELECT member_rental_count(99);
--Answer: COUNT(*) returns 0 when no rows match the condition, regardless of whether the member exists.

-- Exercise 2.3: Returning text
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    SELECT city INTO result
    FROM stations
    WHERE station_id = p_station_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30);--Astana
SELECT station_city(77);--null

-- Exercise 2.4: Using a function inside a query
SELECT rental_id,
       member_id,
       rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration DESC;


--Part 3
-- Exercise 3.1: IN parameters
CREATE OR REPLACE FUNCTION fee_with_discount(
    p_fee NUMERIC,
    p_percent NUMERIC
)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100), 2);
END;
$$ LANGUAGE plpgsql;

SELECT fee_with_discount(74.00, 15);--62.90

-- Exercise 3.2: OUT parameters
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
AS $$
BEGIN
    SELECT COUNT(*),
           COALESCE(SUM(fee), 0),
           MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);--(5,164.75,2025-06-01)
SELECT * FROM member_stats(3);--5	164.75	2025-06-01
SELECT * FROM member_stats(6);--0	0	NULL

-- Exercise 3.3: INOUT parameters
CREATE OR REPLACE FUNCTION apply_late_fee(
    INOUT p_fee NUMERIC
)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(fee)
FROM rentals WHERE rental_id = 1;--18.5

-- Exercise 3.4: VARIADIC parameters
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
AS $$
BEGIN
    SELECT SUM(p_fees[i]),
           ROUND(AVG(p_fees[i]), 2),
           MAX(p_fees[i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(
    13.50, 35.00, 18.50, 31.50
);--98.5,24.63,35

-- Expected error
SELECT * FROM fee_summary();

SELECT *
FROM fee_summary(VARIADIC ARRAY[]::NUMERIC[]);--right version
--Answer: Calling fee_summary() without arguments fails because a variadic function without
-- a default requires at least one matching argument. An explicitly passed empty array returns NULL for all three aggregates.
-- VARIADIC must be the last input parameter because it collects all remaining arguments.

--Exercise 3.5 — Choosing a Mode
--(a) ID of a row	IN — the ID is only used as input.
-- (b) Running balance	INOUT — the balance is received, modified and returned.
-- (c) Unknown number of station IDs	VARIADIC — it accepts a variable number of arguments.
-- (d) Two statistics	OUT — it allows multiple values to be returned together.

--part 4
-- Exercise 4.1: A function with one parameter
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO result
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(6);--0
SELECT total_fees(1);--98.5

-- Exercise 4.2: Overloading the name

CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO result
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');--98.5
SELECT total_fees(1, DATE '2025-01-01');--50.00

-- List both function signatures

SELECT proname,
       pg_get_function_identity_arguments(oid) AS arguments
FROM pg_proc
WHERE proname = 'total_fees';

-- Exercise 4.3: Giving a parameter a default value
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO result
    FROM rentals
    WHERE member_id = p_member_id
      AND start_date >= p_from_date;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Expected error
SELECT total_fees(1);
--[42725] ОШИБКА: функция total_fees(integer) не уникальна
-- Подсказка: Не удалось выбрать лучшую кандидатуру функции. Возможно, вам следует добавить явные приведения типов.

-- Exercise 4.4: Resolving the ambiguity
DROP FUNCTION total_fees(INTEGER);

SELECT total_fees(1);--50.00
--Answer: The two-parameter function is called using its default date of 2025-01-01. It returns 50.00.
--Dropping the other version would return 98.50 because the original function includes all rental fees.

-- Exercise 4.5: Overloading on type
CREATE OR REPLACE FUNCTION total_fees(
    p_member_name VARCHAR
)
RETURNS NUMERIC AS $$
DECLARE
    result NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0) INTO result
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    WHERE m.full_name = p_member_name;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova');--98.50
SELECT total_fees(1);--50.00
--Answer: The functions have different input types, VARCHAR and INT.
-- The name-based function includes all rental fees,
-- while the integer-based function uses the default date and includes only rentals starting from 2025-01-01.

--Part 5 — Functions That Return a Table
-- Exercise 5.1: Search by pattern

CREATE OR REPLACE FUNCTION find_bikes(
    p_pattern VARCHAR
)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model, b.daily_rate
    FROM bikes b
    WHERE b.model ILIKE p_pattern
    ORDER BY b.bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');--ex:(105,"Road Sprint",9.25)
--Answer: SELECT without FROM returns each row as a composite value in one column. SELECT * FROM expands the result into separate columns.

-- Exercise 5.2: A table from a join
CREATE OR REPLACE FUNCTION member_history(
    p_member_id INT
)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration INT,
    fee NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT r.rental_id,
           b.model,
           s.station_name,
           r.end_date - r.start_date,
           r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

-- Exercise 5.3: Ambiguous column names
CREATE OR REPLACE FUNCTION bike_list(
    p_station_id INT
)
RETURNS TABLE (
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

-- Expected error
SELECT * FROM bike_list(10);
--[42702] ОШИБКА: неоднозначная ссылка на столбец "bike_id"
--  Подробности: Подразумевается ссылка на переменную PL/pgSQL или столбец таблицы.

-- Exercise 5.3: Solution 1
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model
    FROM bikes
    WHERE station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);

-- Exercise 5.3: Solution 2
DROP FUNCTION bike_list(INT);

CREATE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (
    bike_id INT,
    model VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT b.bike_id, b.model
    FROM bikes b
    WHERE b.station_id = p_station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM bike_list(10);
--Answer: The error appears at call time because the SQL statement inside the PL/pgSQL function is prepared
-- when it is first executed. Renaming output variables or qualifying table columns resolves the ambiguity.

-- Exercise 5.4: Without casting
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id),
           s.capacity - COUNT(b.bike_id)
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity;
END;
$$ LANGUAGE plpgsql;

-- Expected error

SELECT * FROM station_board('Almaty');
--[42804] ОШИБКА: structure of query does not match function result type
--Подробности: Возвращаемый тип bigint не соответствует ожидаемому типу integer в столбце "s_bikes" (позиция 2).

-- Exercise 5.4: Corrected function

CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (
    s_name VARCHAR,
    s_bikes INT,
    s_free INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT s.station_name,
           COUNT(b.bike_id)::INT,
           s.capacity - COUNT(b.bike_id)::INT
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity
    ORDER BY s.station_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM station_board('Almaty');
SELECT * FROM station_board('Astana');
--Answer: COUNT returns BIGINT, while the function expects INT. An explicit cast is required to match the declared return type.

--Part 6 — Block Structure, DO Blocks and Subblocks
-- Exercise 6.1: An anonymous block
DO $$
<<rental_report>>
DECLARE
    total_rentals INT := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals
    FROM rentals;

    RAISE NOTICE 'The rentals table holds % rows.',
                 total_rentals;
END rental_report;
$$;--The rentals table holds 22 rows.
--Answer: If the END label does not match the opening label, PostgreSQL raises a syntax error.

-- Exercise 6.2: A subblock and a hidden variable
DO $$
<<rental_report>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total
    FROM rentals;

    RAISE NOTICE 'Outer before: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total
        FROM rentals
        WHERE start_date >= DATE '2025-01-01';

        RAISE NOTICE 'Inner value: %', fee_total;

        RAISE NOTICE 'Outer from inside: %',
                     rental_report.fee_total;
    END;

    RAISE NOTICE 'Outer after: %', fee_total;
END rental_report;
$$;
--Outer before: 621.50
--Inner value: 369.00
--Outer from inside: 621.50
--Outer after: 621.50
--Answer: The assignment inside the subblock does not change the outer variable.
-- Each variable belongs to the scope in which it is declared.
-- The outer variable can be accessed using the block label.

-- Exercise 6.3: Local variable error
DO $$
BEGIN
    DECLARE
        local_value INT := 10;
    BEGIN
        RAISE NOTICE 'First block: %', local_value;
    END;

    BEGIN
        RAISE NOTICE 'Second block: %', local_value;
    END;
END;
$$;
--[42703] ОШИБКА: столбец "local_value" не существует

-- Exercise 6.3: Corrected variable scope
DO $$
DECLARE
    local_value INT := 10;
BEGIN
    BEGIN
        RAISE NOTICE 'First block: %', local_value;
    END;

    BEGIN
        RAISE NOTICE 'Second block: %', local_value;
    END;
END;
$$;
--First block: 10
--Second block: 10
--Answer: A variable declared inside a subblock is not accessible from another subblock.
-- Declaring it in the outer block makes it accessible to both.

-- Exercise 6.4: From a block to a function
CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
AS $$
BEGIN
    SELECT COALESCE(SUM(fee), 0)
    INTO before_total
    FROM rentals
    WHERE start_date < p_from_date;

    SELECT COALESCE(SUM(fee), 0)
    INTO after_total
    FROM rentals
    WHERE start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_split(DATE '2025-01-01');--252.5,369

-- Verify the total
SELECT before_total,
       after_total,
       before_total + after_total AS calculated_total,
       (SELECT SUM(fee) FROM rentals) AS actual_total
FROM fee_split(DATE '2025-01-01'); --252.5,369,621.5,621.5

--Part 7 — Practical Scenarios
-- Exercise 7.1: Station occupancy
CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(b.bike_id),
           ROUND(
               COUNT(b.bike_id) * 100.0 /
               NULLIF(s.capacity, 0), 1
           )
    INTO bikes_parked, capacity_pct
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.station_id = p_station_id
    GROUP BY s.capacity;
END;
$$ LANGUAGE plpgsql;

SELECT s.station_id, s.station_name, l.*
FROM stations s,
LATERAL station_load(s.station_id) l
ORDER BY s.station_id;
--Answer: Station 50 returns NULL for capacity_pct because its capacity is zero and
-- the occupancy percentage is undefined. NULLIF prevents division by zero.

-- Exercise 7.2: Top members with a default
CREATE OR REPLACE FUNCTION top_members(
    p_limit INT DEFAULT 3
)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           COUNT(r.rental_id)::INT,
           COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY COALESCE(SUM(r.fee), 0) DESC,
             m.member_id
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);
--Answer: Aisha Nurlanova has five rentals but is ranked below Daniyar Serik, who has four.
-- This is not a bug because the ranking is based on total spending, not the number of rentals.

-- Exercise 7.3: An invoice for an open rental
CREATE OR REPLACE FUNCTION rental_invoice(
    p_rental_id INT
)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    rental_duration INT,
    amount_owed NUMERIC,
    status VARCHAR
)
AS $$
BEGIN
    RETURN QUERY
    SELECT m.full_name,
           b.model,
           COALESCE(r.end_date, CURRENT_DATE)
               - r.start_date,
           ROUND(
               (COALESCE(r.end_date, CURRENT_DATE)
                   - r.start_date) * b.daily_rate, 2
           ),
           CASE
               WHEN r.end_date IS NULL THEN 'OPEN'
               ELSE 'CLOSED'
           END::VARCHAR
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    JOIN bikes b ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
--Answer: Rental 11 returns 74.00, which matches the stored fee.
-- Rental 19 uses CURRENT_DATE, so its duration and amount change every day.
-- The function cannot be IMMUTABLE because its result depends on the current date.

-- Exercise 7.4: City report without a date
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    OUT member_count INT,
    OUT rental_count INT,
    OUT total_revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)
    INTO member_count, rental_count, total_revenue
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');

-- Exercise 7.4: City report with a date
CREATE OR REPLACE FUNCTION city_report(
    p_city VARCHAR,
    p_from_date DATE,
    OUT member_count INT,
    OUT rental_count INT,
    OUT total_revenue NUMERIC
)
AS $$
BEGIN
    SELECT COUNT(DISTINCT m.member_id),
           COUNT(r.rental_id),
           COALESCE(SUM(r.fee), 0)
    INTO member_count, rental_count, total_revenue
    FROM members m
    LEFT JOIN rentals r
        ON m.member_id = r.member_id
        AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report(
    'Almaty', DATE '2025-01-01'
);
--Answer: The date condition should be placed in the ON clause to preserve members without matching rentals.
-- Placing it in WHERE removes members with NULL rental dates.
-- For Almaty, ON returns three members, while WHERE returns two.

-- LAB QUESTIONS

-- 1. What is the difference between a function's name and its signature?
-- A function name is its identifier, while its signature includes
-- the name and input argument types. PostgreSQL needs the signature
-- to identify and drop a specific overloaded function.

-- 2. What is the purpose of dollar quoting ($$)?
-- Dollar quoting allows single quotes inside a function body
-- without escaping them.
-- Example:
CREATE OR REPLACE FUNCTION greeting()
RETURNS TEXT AS $$
BEGIN
    RETURN 'Welcome to CityBike!';
END;
$$ LANGUAGE plpgsql;

SELECT greeting();

-- 3. When should you use OUT parameters or RETURNS TABLE?
-- OUT parameters are useful for returning multiple values in one record.
-- RETURNS TABLE is useful for returning multiple rows and columns.

-- 4. Why must VARIADIC be the last input parameter?
-- It collects all remaining arguments into an array.
-- For example, in f(VARIADIC nums INT[], x INT), a call
-- f(1, 2, 3) would have an unclear argument boundary.

-- 5. What is the difference between RETURN and RETURN QUERY?
-- RETURN returns a single value or ends function execution.
-- RETURN QUERY adds query results to the function's output.

-- 6. Why can DEFAULT parameters cause ambiguity?
-- Default parameters can make multiple overloaded functions
-- match the same function call. To avoid this, do not create
-- overlapping function signatures with default parameters.

-- 7. What happens to a variable declared in a subblock?
-- The variable becomes inaccessible when the subblock ends.
-- A shadowed outer variable can be accessed using its block label,
-- for example, rental_report.fee_total.

-- 8. Give one advantage and one disadvantage of stored functions.
-- Advantage: reusable and consistent business logic.
-- Disadvantage: increased dependence on database-specific code.

-- 9. What is the difference between trusted and untrusted languages?
-- Trusted languages restrict access to external system resources.
-- Authorized ordinary users can create PL/pgSQL functions,
-- while untrusted PL/Python requires superuser privileges.

-- 10. What happens when CREATE OR REPLACE FUNCTION changes argument types?
-- PostgreSQL creates a new function with a different signature
-- instead of replacing the existing function.
-- This can create unwanted overloads or ambiguous function calls.
