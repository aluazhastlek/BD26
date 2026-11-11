--Part 1: Database Setup
--Step 1.1: Create Sample Tables

-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

--Step 1.2: Insert Sample Data
-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

--Part 2: CROSS JOIN Exercises
--Exercise 2.1: Basic CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
    --Answer: 20 records; N*M= 5*4=20
--Exercise 2.2: Alternative CROSS JOIN Syntax
SELECT emp_name, dept_name
FROM employees, departments;
--Exercise 2.3: Practical CROSS JOIN
SELECT e.emp_name, d.dept_name
FROM employees e INNER JOIN departments d on true;

--Part 3: INNER JOIN Exercises
--Exercise 3.1: Basic INNER JOIN with ON
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
    --Answer: 4 records; Tom Brown isn't included, because his department id is NULL
--Exercise 3.2: INNER JOIN with USING
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
    --Answer:-- Same output columns. With SELECT *, USING merges dept_id into one column, while ON keeps both.
--Exercise 3.3: NATURAL INNER JOIN
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
--Exercise 3.4: Multi-table INNER JOIN
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

--Part 4: LEFT JOIN Exercises
--Exercise 4.1: Basic LEFT JOIN
--Write a query to show all employees with their department information, including employees without a department.
select e.emp_name, e.dept_id, d.dept_name
from employees e
left join departments d on e.dept_id=d.dept_id;
    --Answer: Tom Brown|NULL|NULL
--Exercise 4.2: LEFT JOIN with USING
select e.emp_name, e.dept_id, d.dept_name
from employees e
left join departments d using (dept_id);
--Exercise 4.3: Find Unmatched Records
select e.emp_name, e.dept_id, d.dept_name
from employees e
left join departments d on e.dept_id=d.dept_id
where d.dept_id is null;
--Exercise 4.4: LEFT JOIN with Aggregation
--Show all departments with the count of employees in each department (include departments with 0 employees).
select d.dept_name, count(e.dept_id) as employee_count
from departments d
left join employees e on e.dept_id=d.dept_id
group by d.dept_id, d.dept_name
order by employee_count desc;

--Part 5: RIGHT JOIN Exercises
--Exercise 5.1: Basic RIGHT JOIN
--Write a query to show all departments with their employees, including departments without employees
select e.emp_name, d.dept_name
from employees e
right join departments d on e.dept_id = d.dept_id;
--Exercise 5.2: Convert to LEFT JOIN
select e.emp_name, d.dept_name
from departments d
right join employees e on e.dept_id = d.dept_id;
--Exercise 5.3: Find Departments Without Employees
SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

--Part 6: FULL JOIN Exercises
--Exercise 6.1: Basic FULL JOIN
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS
dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
    --Answer: Left side NULL: departments without employees. Right side NULL: employees without a department (Tom Brown).
--Exercise 6.2: FULL JOIN with Projects
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;
--Exercise 6.3: Find Orphaned Records
SELECT
 CASE
 WHEN e.emp_id IS NULL THEN 'Department without
employees'
 WHEN d.dept_id IS NULL THEN 'Employee without
department'
 ELSE 'Matched'
 END AS record_status,
 e.emp_name,
 d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
--Part 7: ON vs WHERE Clause
--Exercise 7.1: Filtering in ON Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND
d.location = 'Building A';
--Exercise 7.2: Filtering in WHERE Clause (Outer Join)
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
    --Answer:
    --• Query 7.1 (ON clause): Applies the filter BEFORE the join, so all employees are included, but
        --only departments in Building A are matched.
    --• Query 7.2 (WHERE clause): Applies the filter AFTER the join, so employees are excluded if
        --their department is not in Building A.
--Exercise 7.3: ON vs WHERE with INNER JOIN
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
inner JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
inner JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
    --Answer:-- No difference. INNER JOIN only returns matching rows, so filtering in ON or WHERE produces the same result.
--Part 8: Complex JOIN Scenarios
--Exercise 8.1: Multiple Joins with Different Types
select d.dept_name, e.emp_name, e.salary, p.project_name, p.budget
from departments d
left join employees e on e.dept_id=d.dept_id
left join projects p on e.dept_id = p.dept_id;
--Exercise 8.2: Self Join
-- Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;
-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;
--self join
select e.emp_name as empl, m.emp_name as mngr
from employees e
left join employees m on e.manager_id=m.emp_id;
--Exercise 8.3: Join with Subquery
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- QUESTIONS
--1. INNER JOIN returns only matching rows, while LEFT JOIN returns all rows from the left table and matching rows from the right.
--2. CROSS JOIN is used to generate all possible combinations, for example, employees and work shifts.
--3. ON filters matches during the join, while WHERE filters the final result. For INNER JOIN, both produce the same result.
--4. 5*10=50 rows will be in output
--5. NATURAL JOIN automatically joins columns with the same names.
--6. It may join unintended columns if tables share column names, producing incorrect or unexpected results.
--7.
    SELECT * FROM B RIGHT JOIN A ON A.id = B.id;
--8. FULL OUTER JOIN is used when we need all rows from both tables, including unmatched rows.

-- SELECT: Chooses which columns to display.
-- FROM: Specifies the main table.
-- AS: Gives a temporary name to a column or table.

-- INNER JOIN: Returns only matching rows from both tables.
-- LEFT JOIN: Returns all rows from the left table and matching rows from the right.
-- RIGHT JOIN: Returns all rows from the right table and matching rows from the left.
-- FULL JOIN: Returns all rows from both tables, including unmatched rows.
-- CROSS JOIN: Returns all possible combinations of rows (N * M).
-- SELF JOIN: Joins a table with itself, usually using two aliases.

-- ON: Specifies the condition used to match rows during a JOIN.
-- USING: Joins tables using a specified column with the same name in both tables.
-- NATURAL JOIN: Automatically joins using all columns with matching names.

-- WHERE: Filters rows after the JOIN and before grouping.
-- AND: Requires both conditions to be true.
-- OR: Requires at least one condition to be true.
-- IS NULL: Checks for missing values.
-- IS NOT NULL: Checks for non-NULL values.

-- GROUP BY: Groups rows with the same values.
-- HAVING: Filters groups after GROUP BY.
-- COUNT(*): Counts all rows, including rows containing NULL values.
-- COUNT(column): Counts only non-NULL values in that column.
-- AVG(): Calculates the average value.
-- SUM(): Calculates the total sum.
-- MIN(): Returns the minimum value.
-- MAX(): Returns the maximum value.

-- UNION: Combines query results and removes duplicate rows.
-- UNION ALL: Combines query results and keeps duplicate rows.

-- ORDER BY: Sorts the result.
-- ASC: Sorts in ascending order.
-- DESC: Sorts in descending order.
-- DISTINCT: Removes duplicate rows from the result.
-- LIMIT: Limits the number of returned rows.

-- LEFT JOIN + WHERE right_table.id IS NULL:
-- Finds rows from the left table with no matching rows on the right.

-- LEFT JOIN + COUNT(right_table.id) + GROUP BY:
-- Counts related records, including groups with zero matches.

-- ON vs WHERE with OUTER JOIN:
-- ON filters matching conditions while preserving unmatched rows on the outer side.
-- WHERE filters the joined result and may remove unmatched rows.

-- ON vs WHERE with INNER JOIN:
-- Placing the same filter in ON or WHERE gives the same result.

-- RIGHT JOIN to LEFT JOIN:
-- Swap the order of the tables and replace RIGHT JOIN with LEFT JOIN.

-- SELECT * with ON: Keeps both join columns.
-- SELECT * with USING: Displays the shared join column only once.
-- SELECT * with NATURAL JOIN: Merges all same-named columns.

-- UNION vs UNION ALL:
-- UNION removes duplicate result rows; UNION ALL keeps them.