--Zhastilek Alua 25B031259

--PART 1: CHECK Constraints
-- Task 1.1: Employees table
create table employees (
employee_id integer primary key, -- unique identifier
first_name text,
last_name text,
age integer check (age between 18 and 65), -- valid age
salary numeric check(salary>0)); -- Positive salary

-- Successful inserts
INSERT INTO employees VALUES (1, 'John', 'Smith', 25, 50000);
INSERT INTO employees VALUES (2, 'Sarah', 'Brown', 30, 60000);

-- Failed test: age below 18
-- INSERT INTO employees VALUES (3, 'Mike', 'Lee', 15, 40000);
-- Expected result: ERROR, CHECK constraint violated.

-- Failed test: negative salary
-- INSERT INTO employees VALUES (4, 'Anna', 'Kim', 22, -1000);
-- Expected result: ERROR, CHECK constraint violated.

-- Task 1.2: Named CHECK Constraint
create table products_catalog (
 product_id integer primary key, -- Unique product ID
 product_name text,
 regular_price  numeric,
 discount_price  numeric,
 constraint valid_discount check( -- Ensures both prices are positive and discount price is lower
 regular_price>0 and
 discount_price>0 and
 discount_price<regular_price));

-- Valid inserts
INSERT INTO products_catalog VALUES (1, 'Laptop', 500000, 450000);
INSERT INTO products_catalog VALUES (2, 'Mouse', 10000, 8000);

-- Invalid: regular_price must be positive
-- INSERT INTO products_catalog VALUES (3, 'Keyboard', -5000, 3000);
-- Expected: ERROR, violates valid_discount.

-- Invalid: discount_price must be positive
-- INSERT INTO products_catalog VALUES (4, 'Monitor', 80000, -1000);
-- Expected: ERROR, violates valid_discount.

-- Invalid: discount_price must be less than regular_price
-- INSERT INTO products_catalog VALUES (5, 'Phone', 100000, 120000);
-- Expected: ERROR, violates valid_discount.

-- Task 1.3: Multiple Column CHECK
Create table  bookings (
 booking_id integer primary key ,-- Unique booking ID
 check_in_date date,
 check_out_date date,
 num_guests integer,
constraint num check( num_guests between 1 and 10), -- Ensures the number of guests is between 1 and 10
 constraint checkdate check (check_out_date > check_in_date)); -- Ensures check-out date is later than check-in date

-- Valid inserts
INSERT INTO bookings VALUES (1, '2026-10-15', '2026-10-20', 2);
INSERT INTO bookings VALUES (2, '2026-11-01', '2026-11-05', 5);

-- Invalid: Number of guests exceeds 10
-- INSERT INTO bookings VALUES (3, '2026-10-15', '2026-10-20', 12);
-- Expected result: ERROR, violates CHECK constraint "num".

-- Invalid: Number of guests is below 1
-- INSERT INTO bookings VALUES (4, '2026-10-15', '2026-10-20', 0);
-- Expected result: ERROR, violates CHECK constraint "num".

-- Invalid: Check-out date is before check-in date
-- INSERT INTO bookings VALUES (5, '2026-10-20', '2026-10-15', 3);
-- Expected result: ERROR, violates CHECK constraint "checkdate".

-- Invalid: Check-out date equals check-in date
-- INSERT INTO bookings VALUES (6, '2026-10-20', '2026-10-20', 2);
-- Expected result: ERROR, violates CHECK constraint "checkdate".

--PART2: NOT NULL Constraints
--Task 2.1: NOT NULL Implementation
Create table customers (
 customer_id integer NOT NULL primary key,-- Unique ID, cannot be NULL
 email text NOT NULL,-- Email is required
 phone text,-- Phone can be NULL
 registration_date date NOT NULL);-- Registration date is required

 -- Valid inserts
INSERT INTO customers VALUES (1, 'john@gmail.com', '87011234567', '2026-10-01');
INSERT INTO customers VALUES (2, 'anna@gmail.com', NULL, '2026-10-05');

-- Result: SUCCESS, both rows inserted.
-- NULL phone is allowed because it has no NOT NULL constraint.

-- Invalid: Customer ID cannot be NULL
-- INSERT INTO customers VALUES (NULL, 'mike@gmail.com', '87015556677', '2026-10-10');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Invalid: Email cannot be NULL
-- INSERT INTO customers VALUES (3, NULL, '87015556677', '2026-10-10');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Invalid: Registration date cannot be NULL
-- INSERT INTO customers VALUES (4, 'sara@gmail.com', '87017778899', NULL);
-- Expected result: ERROR, violates NOT NULL constraint.

--Task 2.2: Combining Constraints
Create table inventory (
 item_id integer NOT NULL primary key,-- Unique ID, Item ID is required
 item_name text NOT NULL,-- Item name cannot be NULL
 quantity integer NOT NULL check ( quantity>= 0), -- Quantity cannot be negative
 unit_price numeric NOT NULL check(unit_price > 0), -- Price must be positive
 last_updated timestamp NOT NULL); -- Timestamp is required

 -- Valid inserts
INSERT INTO inventory VALUES (1, 'Laptop', 10, 350000, '2026-10-14 10:00:00');
INSERT INTO inventory VALUES (2, 'Mouse', 0, 5000, '2026-10-14 11:30:00');

-- Result: SUCCESS, both rows inserted.
-- Quantity = 0 is allowed.

-- Invalid: Item ID cannot be NULL
-- INSERT INTO inventory VALUES (NULL, 'Keyboard', 5, 12000, '2026-10-14 12:00:00');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Invalid: Item name cannot be NULL
-- INSERT INTO inventory VALUES (3, NULL, 5, 12000, '2026-10-14 12:00:00');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Invalid: Quantity cannot be negative
-- INSERT INTO inventory VALUES (4, 'Monitor', -5, 80000, '2026-10-14 13:00:00');
-- Expected result: ERROR, violates CHECK constraint.

-- Invalid: Unit price must be greater than 0
-- INSERT INTO inventory VALUES (5, 'Phone', 10, 0, '2026-10-14 14:00:00');
-- Expected result: ERROR, violates CHECK constraint.

-- Invalid: Last updated cannot be NULL
-- INSERT INTO inventory VALUES (6, 'Tablet', 3, 150000, NULL);
-- Expected result: ERROR, violates NOT NULL constraint.

--Part 3: UNIQUE Constraints
--Task 3.1: Single Column UNIQUE
Create table  users (
user_id integer primary key , -- Unique user ID, cannot be NULL
 username text unique, -- Prevents duplicate usernames
 email text unique,-- Prevents duplicate emails
 created_at timestamp);
-- Valid inserts
INSERT INTO users VALUES (1, 'alua', 'alua@gmail.com', '2026-10-14 10:00:00');
INSERT INTO users VALUES (2, 'anna', 'anna@gmail.com', '2026-10-14 11:00:00');

-- Result: SUCCESS, both rows inserted.

-- Invalid: Duplicate username
-- INSERT INTO users VALUES (3, 'alua', 'sara@gmail.com', '2026-10-14 12:00:00');
-- Expected result: ERROR, violates UNIQUE constraint on username.

-- Invalid: Duplicate email
-- INSERT INTO users VALUES (4, 'sara', 'anna@gmail.com', '2026-10-14 13:00:00');
-- Expected result: ERROR, violates UNIQUE constraint on email.

-- Invalid: Duplicate primary key
-- INSERT INTO users VALUES (1, 'mike', 'mike@gmail.com', '2026-10-14 14:00:00');
-- Expected result: ERROR, violates PRIMARY KEY constraint.

-- Valid: NULL values are allowed in UNIQUE columns
INSERT INTO users VALUES (5, NULL, NULL, '2026-10-14 15:00:00');
-- Result: SUCCESS, UNIQUE allows multiple NULL values by default.

--Task 3.2: Multi-Column UNIQUE
Create table course_enrollments (
 enrollment_id integer,
 student_id integer,
 course_code text,
 semester text,
    -- Prevents the same student from enrolling in the same course during the same semester more than once
 unique (student_id, course_code, semester));

-- Valid inserts
INSERT INTO course_enrollments VALUES (1, 101, 'CS101', 'Fall2026');
INSERT INTO course_enrollments VALUES (2, 102, 'CS101', 'Fall2026');
INSERT INTO course_enrollments VALUES (3, 101, 'CS101', 'Spring2027');
INSERT INTO course_enrollments VALUES (4, 101, 'MATH101', 'Fall2026');
-- Result: SUCCESS, all combinations are unique.

-- Invalid: Duplicate student, course, and semester
-- INSERT INTO course_enrollments VALUES (5, 101, 'CS101', 'Fall2026');
-- Expected result: ERROR, violates composite UNIQUE constraint.

-- Valid: Same student and course in a different semester
INSERT INTO course_enrollments VALUES (6, 101, 'CS101', 'Fall2027');
-- Result: SUCCESS, semester is different.

--Task 3.3: Named UNIQUE Constraints
alter table users
-- Rename existing UNIQUE constraints
RENAME CONSTRAINT users_username_key TO unique_username;
alter table users
RENAME CONSTRAINT users_email_key TO unique_email;

-- Test: Duplicate username
-- INSERT INTO users VALUES (6, 'alua', 'new@gmail.com', '2026-10-14 16:00:00');
-- Expected result: ERROR, violates unique_username constraint.

-- Test: Duplicate email
-- INSERT INTO users VALUES (7, 'newuser', 'anna@gmail.com', '2026-10-14 17:00:00');
-- Expected result: ERROR, violates unique_email constraint.

--Part 4: PRIMARY KEY Constraints
--Task 4.1: Single Column Primary Key
Create table  departments (
 dept_id integer PRIMARY KEY, -- Unique department ID, cannot be NULL
 dept_name text NOT NULL, -- Department name is required
 location text);-- Location can be NULL

-- Valid inserts
INSERT INTO departments VALUES (1, 'IT', 'Almaty');
INSERT INTO departments VALUES (2, 'Finance', 'Astana');
INSERT INTO departments VALUES (3, 'Marketing', 'Shymkent');
-- Expected result: SUCCESS, all 3 rows inserted.

-- Invalid: Duplicate PRIMARY KEY
-- INSERT INTO departments VALUES (1, 'HR', 'Almaty');
-- Expected result: ERROR, violates PRIMARY KEY constraint.

-- Invalid: NULL PRIMARY KEY
-- INSERT INTO departments VALUES (NULL, 'HR', 'Astana');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Invalid: NULL department name
-- INSERT INTO departments VALUES (4, NULL, 'Almaty');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Valid: NULL location is allowed
INSERT INTO departments VALUES (4, 'HR', NULL);
-- Expected result: SUCCESS, location is nullable.

--Task 4.2: Composite Primary Key
Create table student_courses (
 student_id integer,
 course_id integer,
 enrollment_date date,
 grade text,
-- The combination of student_id and course_id must be unique and NOT NULL
 PRIMARY KEY (student_id, course_id));

-- Valid inserts
INSERT INTO student_courses VALUES (101, 1, '2026-09-01', 'A');
INSERT INTO student_courses VALUES (102, 1, '2026-09-01', 'B');
INSERT INTO student_courses VALUES (101, 2, '2026-09-02', 'A');
-- Result: SUCCESS, all combinations are unique.

-- Task 4.3: Comparison Exercise

-- 1. The difference between UNIQUE and PRIMARY KEY
-- UNIQUE prevents duplicate values but allows NULL.
-- PRIMARY KEY prevents both duplicates and NULL values.

--2. When to use a single-column vs. composite PRIMARY KEY
-- A single-column PRIMARY KEY is used when one column can uniquely identify each row (e.g., student_id).
-- A composite PRIMARY KEY is used when two or more columns together identify each row (e.g., student_id, course_id).

-- 3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints
-- A table can have only one PRIMARY KEY because it is the main identifier for each row.
-- However, a table can have multiple UNIQUE constraints to prevent duplicates in different columns.

-- Part 5: FOREIGN KEY Constraints
-- Task 5.1: Basic Foreign Key

CREATE TABLE employees_dept (
emp_id INTEGER PRIMARY KEY, -- Unique employee ID
emp_name TEXT NOT NULL, -- Employee name is required
dept_id INTEGER REFERENCES departments(dept_id), -- References an existing department
hire_date DATE
);
-- Valid inserts: departments 1, 2, and 3 already exist
INSERT INTO employees_dept VALUES (1, 'John Smith', 1, '2026-01-15');
INSERT INTO employees_dept VALUES (2, 'Anna Brown', 2, '2026-03-20');
INSERT INTO employees_dept VALUES (3, 'Mike Lee', 3, '2026-05-10');
-- Expected result: SUCCESS, all dept_id values exist in departments.

-- Invalid: Department 999 does not exist
-- INSERT INTO employees_dept VALUES (4, 'Sara Kim', 999, '2026-06-01');
-- Expected result: ERROR, violates FOREIGN KEY constraint.

--Task 5.2: Multiple Foreign Keys
--Create a complete database schema for a library system:
-- Create authors table
create Table authors(
 author_id integer PRIMARY KEY,-- Unique author ID
 author_name text NOT NULL, -- Author name is required
 country text);

-- Create publishers table
create Table publishers(
 publisher_id integer PRIMARY KEY,-- Unique publisher ID
 publisher_name text NOT NULL,-- Publisher name is required
 city text);

-- Create books table
create Table books(
 book_id integer PRIMARY KEY,-- Unique book ID
 title text NOT NULL,-- Book title is required
 author_id integer REFERENCES authors(author_id),-- References authors table
 publisher_id integer REFERENCES publishers(publisher_id),-- References publishers table
 publication_year integer,
 isbn text UNIQUE);-- Prevents duplicate ISBN values

-- Insert valid authors
INSERT INTO authors VALUES (1, 'George Orwell', 'United Kingdom');
INSERT INTO authors VALUES (2, 'J.K. Rowling', 'United Kingdom');
INSERT INTO authors VALUES (3, 'Haruki Murakami', 'Japan');
-- Result: SUCCESS, 3 authors inserted.

-- Insert valid publishers
INSERT INTO publishers VALUES (1, 'Penguin Books', 'London');
INSERT INTO publishers VALUES (2, 'Bloomsbury', 'London');
INSERT INTO publishers VALUES (3, 'Kodansha', 'Tokyo');
-- Result: SUCCESS, 3 publishers inserted.

-- Insert valid books
INSERT INTO books VALUES (1, '1984', 1, 1, 1949, '9780451524935');
INSERT INTO books VALUES (2, 'Harry Potter', 2, 2, 1997, '9780747532699');
INSERT INTO books VALUES (3, 'Norwegian Wood', 3, 3, 1987, '9780375704024');
-- Result: SUCCESS, all books reference existing authors and publishers.

-- Invalid: Author does not exist
-- INSERT INTO books VALUES (4, 'Unknown Book', 999, 1, 2020, '9780000000001');
-- Expected result: ERROR, violates FOREIGN KEY constraint on author_id.

-- Invalid: Publisher does not exist
-- INSERT INTO books VALUES (5, 'Another Book', 1, 999, 2021, '9780000000002');
-- Expected result: ERROR, violates FOREIGN KEY constraint on publisher_id.

-- Invalid: Duplicate ISBN
-- INSERT INTO books VALUES (6, 'Duplicate Book', 1, 1, 2022, '9780451524935');
-- Expected result: ERROR, violates UNIQUE constraint on isbn.

--Task 5.3: ON DELETE Options
--Create a schema demonstrating different ON DELETE behaviors:
create Table categories(
 category_id integer PRIMARY KEY,-- Unique category ID
 category_name text NOT NULL);-- Category name is required

create Table products_fk(
 product_id integer PRIMARY KEY,-- Unique product ID
 product_name text NOT NULL,-- Product name is required
 category_id integer REFERENCES categories(category_id) ON DELETE RESTRICT);-- Prevents deleting a category with products

create Table orders(
 order_id integer PRIMARY KEY,-- Unique order ID
 order_date date NOT NULL);-- Order date is required

create Table order_items(
 item_id integer PRIMARY KEY,-- Unique order item ID
 order_id integer REFERENCES orders(order_id) ON DELETE CASCADE,-- Automatically deletes items when their order is deleted
 product_id integer REFERENCES products_fk(product_id),-- References an existing product
 quantity integer CHECK (quantity > 0));-- Quantity must be positive

-- Insert valid categories
INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO categories VALUES (2, 'Clothing');

-- Insert valid products
INSERT INTO products_fk VALUES (1, 'Laptop', 1);
INSERT INTO products_fk VALUES (2, 'T-shirt', 2);

-- Insert valid orders
INSERT INTO orders VALUES (1, '2026-10-14');
INSERT INTO orders VALUES (2, '2026-10-15');

-- Insert valid order items
INSERT INTO order_items VALUES (1, 1, 1, 2);
INSERT INTO order_items VALUES (2, 1, 2, 3);
INSERT INTO order_items VALUES (3, 2, 1, 1);
-- Result: SUCCESS, all records inserted.

-- Test 1: ON DELETE RESTRICT
-- Try to delete a category that has products
-- DELETE FROM categories WHERE category_id = 1;
-- Expected result: ERROR, deletion is restricted.
-- Category 1 cannot be deleted because products reference it.

-- Test 2: ON DELETE CASCADE
-- Delete order 1
DELETE FROM orders WHERE order_id = 1;
-- Expected result: SUCCESS.
-- Order 1 is deleted.
-- Order items 1 and 2 are automatically deleted.

-- Test 3: Check remaining data
SELECT * FROM orders;
SELECT * FROM order_items;
-- Expected result:
-- Orders: only order 2 remains.
-- Order items: only item 3 remains.
-- Products and categories are not deleted.

-- Test 4: Invalid quantity
-- INSERT INTO order_items VALUES (4, 2, 1, -5);
-- Expected result: ERROR, violates CHECK constraint.

--Part 6: Practical Application
--Task 6.1: E-commerce Database Design
-- Separate schema to avoid conflicts with previous tasks
CREATE SCHEMA IF NOT EXISTS lab5_ecommerce;
SET search_path TO lab5_ecommerce;

create table customers (
    customer_id serial primary key,-- Unique customer ID
    name text not null,-- Customer name is required
    email text not null unique,-- Email must be unique
    phone varchar(12),
    registration_date date not null);-- Registration date is required

create table products (
    product_id integer primary key,-- Unique product ID
    name text not null,-- Product name is required
    description text ,
    price integer not null  CHECK (price >= 0), -- Price cannot be negative
    stock_quantity integer not null CHECK (stock_quantity >= 0)); -- Stock cannot be negative

create table orders(
    order_id serial primary key,-- Unique order ID
    customer_id integer not null references customers(customer_id) on delete restrict,-- Prevents deleting customers with orders
    order_date date not null,
    total_amount integer not null check ( total_amount>=0 ),
    -- Only specified statuses are allowed
    status text not null check (status in( 'pending','processing','shipped','delivered','cancelled' )));

create table order_details (
    order_detail_id integer primary key,-- Unique order detail ID
    order_id integer not null references orders(order_id) on delete cascade,-- Deletes order details when an order is deleted
    product_id integer references products(product_id) on delete restrict,-- Prevents deleting products used in orders
    quantity integer not null check ( quantity>0 ),-- Quantity must be positive
    unit_price integer not null check ( unit_price>=0 ));-- Unit price cannot be negative

-- Insert customers
INSERT INTO customers VALUES
(1, 'Alua', 'alua@gmail.com', '87011234567', '2026-10-01'),
(2, 'Anna', 'anna@gmail.com', NULL, '2026-10-02'),
(3, 'Mike', 'mike@gmail.com', '87015556677', '2026-10-03'),
(4, 'Sara', 'sara@gmail.com', '87017778899', '2026-10-04'),
(5, 'John', 'john@gmail.com', NULL, '2026-10-05');

-- Insert products
INSERT INTO products VALUES
(1, 'Laptop', 'Gaming laptop', 350000, 10),
(2, 'Mouse', 'Wireless mouse', 5000, 30),
(3, 'Keyboard', 'Mechanical keyboard', 15000, 20),
(4, 'Monitor', '24-inch monitor', 80000, 15),
(5, 'Headphones', 'Bluetooth headphones', 25000, 0);

-- Insert orders
INSERT INTO orders VALUES
(1, 1, '2026-10-10', 350000, 'pending'),
(2, 2, '2026-10-11', 10000, 'processing'),
(3, 3, '2026-10-12', 15000, 'shipped'),
(4, 4, '2026-10-13', 80000, 'delivered'),
(5, 5, '2026-10-14', 25000, 'cancelled');

-- Insert order details
INSERT INTO order_details VALUES
(1, 1, 1, 1, 350000),
(2, 2, 2, 2, 5000),
(3, 3, 3, 1, 15000),
(4, 4, 4, 1, 80000),
(5, 5, 5, 1, 25000);

-- Result: SUCCESS, 5 records inserted into each table.

-- Test 1: Duplicate customer email
-- INSERT INTO customers VALUES (6, 'Alex', 'alua@gmail.com', NULL, '2026-10-14');
-- Expected result: ERROR, violates UNIQUE constraint.

-- Test 2: NULL customer name
-- INSERT INTO customers VALUES (7, NULL, 'alex@gmail.com', NULL, '2026-10-14');
-- Expected result: ERROR, violates NOT NULL constraint.

-- Test 3: Negative product price
-- INSERT INTO products VALUES (6, 'Tablet', 'New tablet', -1000, 10);
-- Expected result: ERROR, violates CHECK constraint.

-- Test 4: Negative stock quantity
-- INSERT INTO products VALUES (7, 'Phone', 'Smartphone', 100000, -5);
-- Expected result: ERROR, violates CHECK constraint.

-- Test 5: Invalid order status
-- INSERT INTO orders VALUES (6, 1, '2026-10-14', 10000, 'unknown');
-- Expected result: ERROR, violates CHECK constraint.

-- Test 6: Non-existent customer
-- INSERT INTO orders VALUES (7, 999, '2026-10-14', 10000, 'pending');
-- Expected result: ERROR, violates FOREIGN KEY constraint.

-- Test 7: Negative order detail quantity
-- INSERT INTO order_details VALUES (6, 1, 1, -2, 350000);
-- Expected result: ERROR, violates CHECK constraint.

-- Test 8: Non-existent product
-- INSERT INTO order_details VALUES (7, 1, 999, 1, 5000);
-- Expected result: ERROR, violates FOREIGN KEY constraint.

-- Test 9: ON DELETE RESTRICT
-- DELETE FROM customers WHERE customer_id = 1;
-- Expected result: ERROR, customer 1 has an existing order.

-- Test 10: ON DELETE CASCADE
BEGIN;

DELETE FROM orders WHERE order_id = 5;
-- Expected result: SUCCESS.
-- Order 5 and its related order_details record are deleted.

SELECT * FROM order_details WHERE order_id = 5;
-- Expected result: 0 rows.

ROLLBACK;
-- Restores order 5 and its details so all 5 sample records remain.