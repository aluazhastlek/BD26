-- Part 1: Database Setup
create database labindex;
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample departments
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
-- Insert sample employees
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
-- Insert sample projects
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

--Part 2: Creating Basic Indexes
--Exercise 2.1: Create a Simple B-tree Index
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
--Answer: 2 indexes

--Exercise 2.2: Create an Index on a Foreign Key
--Create an index on the dept_id column in the employees table:
CREATE INDEX emp_dept_idx ON employees(dept_id);
-- Test
SELECT * FROM employees WHERE dept_id = 101;
--Answer: Indexing foreign key columns can improve JOIN performance and speed up searches involving related tables.

--Exercise 2.3: View Index Information
--Use PostgreSQL system catalogs to view detailed index information:
SELECT
 tablename,
 indexname,
 indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--Answer: departments_pkey, emp_dept_idx, emp_salary_idx, employees_pkey, projects_pkey; automatically:employees_pkey, departments_pkey, and projects_pkey

--Part 3 — Multicolumn Indexes
-- Exercise 3.1: Create a Multicolumn Index
CREATE INDEX emp_dept_salary_idx
ON employees(dept_id, salary);
-- Test the index
SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
--Answer:It is generally less efficient because salary is the second column in the index. A separate index on salary is usually more suitable.

-- Exercise 3.2: Understanding Column Order
CREATE INDEX emp_salary_dept_idx
ON employees(salary, dept_id);
-- Query 1
SELECT *
FROM employees
WHERE dept_id = 102 AND salary > 50000;
-- Query 2
SELECT *
FROM employees
WHERE salary > 50000 AND dept_id = 102;
--Answer:Yes. The order of columns in the index affects which queries can use it efficiently.
-- However, changing the order of conditions in the WHERE clause does not change the result or the index's column order.

--Part 4 — Unique Indexes
-- Exercise 4.1: Create a Unique Index
ALTER TABLE employees
ADD COLUMN email VARCHAR(100);

UPDATE employees
SET email = 'john.smith@company.com'
WHERE emp_id = 1;
UPDATE employees
SET email = 'jane.doe@company.com'
WHERE emp_id = 2;
UPDATE employees
SET email = 'mike.johnson@company.com'
WHERE emp_id = 3;
UPDATE employees
SET email = 'sarah.williams@company.com'
WHERE emp_id = 4;
UPDATE employees
SET email = 'tom.brown@company.com'
WHERE emp_id = 5;

-- Create a unique index
CREATE UNIQUE INDEX emp_email_unique_idx
ON employees(email);

-- Test duplicate email (expected error)
INSERT INTO employees
(emp_id, emp_name, dept_id, salary, email)
VALUES
(6, 'New Employee', 101, 55000, 'john.smith@company.com');
--Answer: Duplicate key value violates unique constraint emp_email_unique_idx.

-- Exercise 4.2: Unique Index vs UNIQUE Constraint
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20) UNIQUE;
-- View the indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees'
AND indexname LIKE '%phone%';
--Answer: Yes. PostgreSQL automatically created a unique B-tree index to enforce the UNIQUE constraint.

--Part 5 — Indexes and Sorting
-- Exercise 5.1: Create an Index for Sorting
CREATE INDEX emp_salary_desc_idx
ON employees(salary DESC);

-- Test the index
SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
--Answer: It can provide rows in sorted order, reducing or eliminating the need for a separate sorting operation.

-- Exercise 5.2: Index with NULL Handling
CREATE INDEX proj_budget_nulls_first_idx
ON projects(budget NULLS FIRST);

-- Test the index
SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--Part 6 — Indexes on Expressions
-- Exercise 6.1: Create a Function-Based Index
CREATE INDEX emp_name_lower_idx
ON employees(LOWER(emp_name));

-- Test the index
SELECT *
FROM employees
WHERE LOWER(emp_name) = 'john smith';
--Answer: PostgreSQL would evaluate LOWER() for rows during the search,
-- often using a sequential scan if no suitable expression index exists.

-- Exercise 6.2: Index on Calculated Values
ALTER TABLE employees
ADD COLUMN hire_date DATE;

UPDATE employees
SET hire_date = '2020-01-15'
WHERE emp_id = 1;
UPDATE employees
SET hire_date = '2019-06-20'
WHERE emp_id = 2;
UPDATE employees
SET hire_date = '2021-03-10'
WHERE emp_id = 3;
UPDATE employees
SET hire_date = '2020-11-05'
WHERE emp_id = 4;
UPDATE employees
SET hire_date = '2018-08-25'
WHERE emp_id = 5;

-- Create index on hire year
CREATE INDEX emp_hire_year_idx
ON employees(EXTRACT(YEAR FROM hire_date));

-- Test the index
SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--Part 7 — Managing Indexes
-- Exercise 7.1: Rename an Index
ALTER INDEX emp_salary_idx
RENAME TO employees_salary_index;
-- Verify the rename
SELECT indexname
FROM pg_indexes
WHERE tablename = 'employees';

-- Exercise 7.2: Drop Unused Indexes
DROP INDEX emp_salary_dept_idx;
--Answer: Unnecessary indexes consume storage space and increase the cost of INSERT, UPDATE, and DELETE operations.

-- Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;

--Part 8 — Practical Scenarios
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

--Exercise 8.1 — Optimize a Slow Query
CREATE INDEX emp_salary_filter_idx
ON employees(salary)
WHERE salary > 50000;

-- Test the optimized query
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d
ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Exercise 8.2: Partial Index
CREATE INDEX proj_high_budget_idx
ON projects(budget)
WHERE budget > 80000;

-- Test the partial index
SELECT proj_name, budget
FROM projects
WHERE budget > 80000;

--Answer: A partial index stores only rows satisfying a specific condition,
-- making it smaller and potentially more efficient for targeted queries.

-- Exercise 8.3: Analyze Index Usage
EXPLAIN
SELECT *
FROM employees
WHERE salary > 52000;
--Answer: A sequential scan may be chosen for small tables
-- because scanning the entire table can be cheaper than using an index.
-- The query planner selects the estimated most efficient method.

--Part 9 — Index Types Comparison
-- Exercise 9.1: Create a Hash Index
CREATE INDEX dept_name_hash_idx
ON departments USING HASH(dept_name);

-- Test the hash index
SELECT *
FROM departments
WHERE dept_name = 'IT';
--Answer: A hash index can be considered for equality-only searches.
-- However, B-tree indexes also support equality and are generally more versatile.

-- Exercise 9.2: Compare Index Types
-- B-tree index
CREATE INDEX proj_name_btree_idx
ON projects(proj_name);
-- Hash index
CREATE INDEX proj_name_hash_idx
ON projects USING HASH(proj_name);
-- Equality search
SELECT *
FROM projects
WHERE proj_name = 'Website Redesign';
-- Range search
SELECT *
FROM projects
WHERE proj_name > 'Database';

--Part 10 — Cleanup and Best Practices
-- Exercise 10.1: Review All Indexes
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(
        pg_relation_size(indexname::regclass)
    ) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--The largest indexes are dept_name_hash_idx and proj_name_hash_idx, both with a size of 32 kB.
-- They are Hash indexes, which use a different storage structure and
-- have higher storage overhead for these small tables. All other indexes are 16 kB.

-- Exercise 10.2: Drop Unnecessary Indexes
DROP INDEX IF EXISTS proj_name_hash_idx;

-- Exercise 10.3: Document Your Indexes
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

-- View index documentation
SELECT * FROM index_documentation;

--1. What is the default index type in PostgreSQL?
--B-tree

--2. Name three scenarios where you should create an index.
--frequently filtered columns, JOIN conditions, and ORDER BY queries

--3. Name two scenarios where you should NOT create an index.
--for very small tables or columns that are rarely used in queries

--4. What happens to indexes when you INSERT, UPDATE, or DELETE data?
--PostgreSQL maintains the indexes when table data changes, which adds overhead to write operations.

--5. How can you check if a query is using an index?
--Use EXPLAIN or EXPLAIN ANALYZE to inspect the query execution plan and check for Index Scan, Bitmap Index Scan, or Index Only Scan.

-- Brief Reflection on When to Use Indexes
-- During this lab, I learned that indexes improve query performance,
-- especially in large tables and queries using WHERE, JOIN, and ORDER BY.
-- However, too many indexes take up storage space and slow down data modifications.
-- Therefore, indexes should be used when necessary, and their performance can be checked using EXPLAIN ANALYZE.