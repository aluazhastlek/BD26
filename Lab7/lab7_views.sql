--Part 2: Creating Basic Views
--Exercise 2.1: Simple View Creation
create view employees_view AS
    select e.emp_name, e.salary, d.dept_name, d.location
from employees e
join departments d on e.dept_id=d.dept_id;
SELECT * FROM employees_view;
--Answer: 4 rows,tom is not returned because it has no department

--Exercise 2.2: View with Aggregation
create view dept_statistics as
    select d.dept_name, count(e.emp_id) as employee_count, avg(e.salary), max(salary), min(salary)
from employees e right join departments d on d.dept_id=e.dept_id
group by d.dept_name;

--Exercise 2.3: View with Multiple Joins
create view project_overview as
    select p.project_name, p. budget, d.dept_name, d.location, count(e.emp_id) as team_size
from projects p join departments d on p.dept_id=d.dept_id
left join employees e on d.dept_id=e.dept_id
group by p.project_id,p.project_name, p. budget, d.dept_id, d.dept_name, d.location;

--Exercise 2.4: View with Filtering
create view high_earners as
    select e.emp_name, e.salary, d.dept_name
from employees e
left join departments d on e.dept_id=d.dept_id
where e.salary>55000;
-- Answer: LEFT JOIN includes high-earning employees without a department.

--Part 3: Modifying and Managing Views
--Exercise 3.1: Replace a View
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name,
       e.salary,
       d.dept_name,
       d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
       END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

--Exercise 3.2: Rename a View
alter view employees_view rename to top_performers;

--Exercise 3.3: Drop a View
create temp view temp_view as
    SELECT emp_name, salary
FROM employees
WHERE salary < 50000;
drop view temp_view;

--Part 4: Updatable Views
--Exercise 4.1: Create an Updatable View
create view employee_salaries as
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

--Exercise 4.2: Update Through a View
update employee_salaries
set salary=52000
where emp_name='John Smith';

--Exercise 4.3: Insert Through a View
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

--Exercise 4.4: View with CHECK OPTION
create view it_employees as
    select * from employees
where dept_id=101
with local check option;

--Part 5: Materialized Views
--Exercise 5.1: Create a Materialized View
-- Exercise 5.1: Create a Materialized View
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COALESCE(e.num_emp, 0) AS total_employees,
       COALESCE(e.total_salary, 0) AS total_salaries,
       COALESCE(p.num_pr, 0) AS total_projects,
       COALESCE(p.total_budget, 0) AS total_project_budget
FROM departments d
LEFT JOIN (
    SELECT dept_id,
           COUNT(emp_id) AS num_emp,
           SUM(salary) AS total_salary
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id
LEFT JOIN (
    SELECT dept_id,
           COUNT(project_id) AS num_pr,
           SUM(budget) AS total_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id
WITH DATA;

-- Exercise 5.2: Refresh Materialized View
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);
REFRESH MATERIALIZED VIEW dept_summary_mv;
--Answer:
-- Before refresh, the materialized view shows outdated data.
-- After refresh, it includes Charlie Brown, increasing the employee count by 1 and the total salary by 54000.

-- Exercise 5.3: Concurrent Refresh
CREATE UNIQUE INDEX idx_dept_summary
ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- Answer: CONCURRENTLY allows users to query the materialized view
-- while it is being refreshed, avoiding blocking SELECT queries.
-- It requires a suitable unique index on the materialized view.

-- Exercise 5.4: Materialized View with NO DATA
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       COUNT(e.emp_id) AS employee_count
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget,
         d.dept_id, d.dept_name
WITH NO DATA;

--Part 6: Database Roles
--Exercise 6.1: Create Basic Roles
create role analyst;
create role data_viewer login password 'viewer123';
create role report_user login password 'report456';

--Exercise 6.2: Role with Specific Attributes
create role db_creator createdb login password 'creator789';
create role user_manager createrole login password 'manager101';
create role admin_user superuser login password 'admin999';

--Exercise 6.3: Grant Privileges to Roles
-- Grant SELECT on three tables to analyst
GRANT SELECT ON employees, departments, projects TO analyst;
-- Grant all privileges on the view to data_viewer
GRANT ALL PRIVILEGES ON employees_view TO data_viewer;
-- Grant SELECT and INSERT on employees to report_user
GRANT SELECT, INSERT ON employees TO report_user;

-- Exercise 6.4: Create Group Roles
-- 1. Create group roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;
-- 2. Create individual users
CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';
-- 3. Assign HR users to hr_team
GRANT hr_team TO hr_user1, hr_user2;
-- 4. Assign finance user to finance_team
GRANT finance_team TO finance_user1;
-- 5. Grant privileges to hr_team
GRANT SELECT, UPDATE ON employees TO hr_team;
-- 6. Grant privileges to finance_team
GRANT SELECT ON dept_statistics TO finance_team;

-- Exercise 6.5: Revoke Privileges
-- 1. Revoke UPDATE privilege from hr_team
REVOKE UPDATE ON employees FROM hr_team;
-- 2. Remove hr_user2 from hr_team
REVOKE hr_team FROM hr_user2;
-- 3. Revoke all privileges from data_viewer
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- Exercise 6.6: Modify Role Attributes
-- 1. Add LOGIN and password to analyst
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
-- 2. Make user_manager a SUPERUSER
ALTER ROLE user_manager SUPERUSER;
-- 3. Remove password from analyst
ALTER ROLE analyst PASSWORD NULL;
-- 4. Set connection limit for data_viewer
ALTER ROLE data_viewer CONNECTION LIMIT 5;

--Part 7: Advanced Role Management
-- Exercise 7.1: Role Hierarchies
-- 1. Create a parent role
CREATE ROLE read_only;
-- Grant SELECT on all tables in public schema
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
-- 2. Create child roles
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';
-- 3. Grant read_only membership to both analysts
GRANT read_only TO junior_analyst, senior_analyst;
-- 4. Grant additional privileges to senior_analyst
GRANT INSERT, UPDATE ON employees TO senior_analyst;

-- Exercise 7.2: Object Ownership
-- 1. Create project_manager role
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
-- 2. Transfer ownership of dept_statistics view
ALTER VIEW dept_statistics OWNER TO project_manager;
-- 3. Transfer ownership of projects table
ALTER TABLE projects OWNER TO project_manager;

-- Exercise 7.3: Reassign and Drop Roles
-- 1. Create a role
CREATE ROLE temp_owner LOGIN;
-- 2. Create a table
CREATE TABLE temp_table (
    id INT
);
-- 3. Transfer ownership
ALTER TABLE temp_table OWNER TO temp_owner;
-- 4. Reassign owned objects to postgres
REASSIGN OWNED BY temp_owner TO postgres;
-- 5. Drop remaining objects and privileges owned by temp_owner
DROP OWNED BY temp_owner;
-- 6. Drop the role
DROP ROLE temp_owner;

-- Exercise 7.4: Row-Level Security with Views
-- 1. Create HR employee view
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;
-- 2. Grant SELECT to hr_team
GRANT SELECT ON hr_employee_view TO hr_team;
-- 3. Create finance employee view
CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;
-- 4. Grant SELECT to finance_team
GRANT SELECT ON finance_employee_view TO finance_team;

--Part 8: Practical Scenarios
-- Exercise 8.1: Department Dashboard View
CREATE VIEW dept_dashboard AS
SELECT d.dept_name,
       d.location,
       COALESCE(e.employee_count, 0) AS employee_count,
       ROUND(COALESCE(e.avg_salary, 0), 2) AS avg_salary,
       COALESCE(p.active_projects, 0) AS active_projects,
       COALESCE(p.total_budget, 0) AS total_budget,
       ROUND(
           COALESCE(p.total_budget, 0) /
           NULLIF(COALESCE(e.employee_count, 0), 0),
           2
       ) AS budget_per_employee
FROM departments d
LEFT JOIN (
    SELECT dept_id,
           COUNT(emp_id) AS employee_count,
           AVG(salary) AS avg_salary
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id
LEFT JOIN (
    SELECT dept_id,
           COUNT(project_id) AS active_projects,
           SUM(budget) AS total_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id;

-- Exercise 8.2: Audit View
-- Add a timestamp column to projects
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- Create a view for high-budget projects
CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
       END AS approval_status
FROM projects p
JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- Exercise 8.3: Create Access Control System
-- Level 1: Viewer Role
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public
TO viewer_role;
-- Level 2: Entry Role
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects
TO entry_role;
-- Level 3: Analyst Role
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects
TO analyst_role;
-- Level 4: Manager Role
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects
TO manager_role;
-- Create Users
CREATE ROLE alice LOGIN PASSWORD 'alice123';
CREATE ROLE bob LOGIN PASSWORD 'bob123';
CREATE ROLE charlie LOGIN PASSWORD 'charlie123';
-- Assign Users to Roles
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;

-- STEP 0: DATABASE SETUP

DROP VIEW IF EXISTS v_city_rank, v_tree, v_cat_totals CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_cat_totals;
DROP TABLE IF EXISTS sales, categories CASCADE;

CREATE TABLE categories (
    cat_id INT PRIMARY KEY,
    cat_name VARCHAR(14) NOT NULL,
    parent_id INT REFERENCES categories
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    cat_id INT REFERENCES categories,
    city VARCHAR(10) NOT NULL,
    amount INT NOT NULL
);

INSERT INTO categories VALUES
(1, 'All goods', NULL),
(2, 'Electronics', 1),
(3, 'Furniture', 1),
(4, 'Phones', 2),
(5, 'Laptops', 2),
(6, 'Chairs', 3),
(7, 'Gaming', 4);

SELECT setseed(0.7);

INSERT INTO sales
SELECT g,
       4 + (g % 4),
       (ARRAY['Almaty','Astana','Shymkent','Aktobe'])[1 + (g / 4) % 4],
       500 + (random()*4000)::INT + 2500 * (((g / 4) + g) % 4)
FROM generate_series(1, 300000) g;

ANALYZE sales;


-- PART A: MEASURING WHAT A MATERIALIZED VIEW BUYS

-- A1: Create regular and materialized views

CREATE VIEW v_cat_totals AS
SELECT c.cat_id,
       c.cat_name,
       COUNT(s.sale_id) AS sales_count,
       COALESCE(SUM(s.amount), 0) AS total_amount
FROM categories c
JOIN sales s ON c.cat_id = s.cat_id
GROUP BY c.cat_id, c.cat_name;

CREATE MATERIALIZED VIEW mv_cat_totals AS
SELECT * FROM v_cat_totals;


-- A2: Compare query execution times
-- In DataGrip, check execution times in the query output.

SELECT * FROM v_cat_totals;
SELECT * FROM mv_cat_totals;


-- A3: Compare execution plans and buffer usage

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM v_cat_totals;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM mv_cat_totals;

-- Regular view executes JOIN and GROUP BY again.
-- Materialized view reads precomputed results.


-- A4: Compare storage sizes

SELECT
    pg_size_pretty(pg_total_relation_size('sales')) AS sales_size,
    pg_size_pretty(pg_total_relation_size('mv_cat_totals')) AS mv_size;


-- A4: Insert a new sale

INSERT INTO sales (sale_id, cat_id, city, amount)
VALUES (300001, 7, 'Almaty', 100000);

SELECT * FROM v_cat_totals
WHERE cat_id = 7;

SELECT * FROM mv_cat_totals
WHERE cat_id = 7;

-- Regular view shows updated data.
-- Materialized view shows stale data.

REFRESH MATERIALIZED VIEW mv_cat_totals;

SELECT * FROM mv_cat_totals
WHERE cat_id = 7;

-- REFRESH updates the stored results.


-- PART B: A VIEW THAT CALLS ITSELF

-- B1: Create recursive view

CREATE RECURSIVE VIEW v_tree
(cat_id, cat_name, depth, path) AS

SELECT cat_id,
       cat_name,
       1,
       cat_name::TEXT
FROM categories
WHERE parent_id IS NULL

UNION ALL

SELECT c.cat_id,
       c.cat_name,
       t.depth + 1,
       t.path || ' > ' || c.cat_name
FROM categories c
JOIN v_tree t ON c.parent_id = t.cat_id;


-- B1: Display the complete category tree

SELECT *
FROM v_tree
ORDER BY path;


-- B1: Find the deepest category

SELECT *
FROM v_tree
WHERE depth = (SELECT MAX(depth) FROM v_tree);

-- Deepest category: Gaming, depth = 4.


-- B2: Recursive view explanation
-- Anchor query: WHERE parent_id IS NULL.
-- Recursive query: JOIN v_tree t ON c.parent_id = t.cat_id.
-- Recursion stops when no more child rows are found.


-- B3: Inspect stored view definition

SELECT pg_get_viewdef('v_tree', TRUE);

-- PostgreSQL stores a recursive query using WITH RECURSIVE.


-- B4: Attempt to update recursive view
-- Expected error: recursive views are not automatically updatable.

UPDATE v_tree
SET cat_name = 'New Gaming'
WHERE cat_id = 7;


-- PART C: A VIEW THAT RANKS

-- C1: Create city ranking view

CREATE VIEW v_city_rank AS
SELECT c.cat_name,
       s.city,
       SUM(s.amount) AS total,
       RANK() OVER (
           PARTITION BY c.cat_name
           ORDER BY SUM(s.amount) DESC
       ) AS rnk
FROM sales s
JOIN categories c ON c.cat_id = s.cat_id
GROUP BY c.cat_name, s.city;


-- C1: Find the best city in each category

SELECT *
FROM v_city_rank
WHERE rnk = 1;

-- PARTITION BY creates a separate ranking for each category.


-- C2: Attempt window function in WHERE
-- Expected error: window functions are not allowed in WHERE.

SELECT c.cat_name,
       s.city,
       SUM(s.amount) AS total
FROM sales s
JOIN categories c ON c.cat_id = s.cat_id
GROUP BY c.cat_name, s.city
HAVING SUM(s.amount) > 0
   AND RANK() OVER (
       PARTITION BY c.cat_name
       ORDER BY SUM(s.amount) DESC
   ) = 1;


-- C2: Correct solution using a subquery

SELECT *
FROM (
    SELECT c.cat_name,
           s.city,
           SUM(s.amount) AS total,
           RANK() OVER (
               PARTITION BY c.cat_name
               ORDER BY SUM(s.amount) DESC
           ) AS rnk
    FROM sales s
    JOIN categories c ON c.cat_id = s.cat_id
    GROUP BY c.cat_name, s.city
) ranked
WHERE rnk = 1;

-- A view allows filtering by a computed window function
-- in an outer SELECT statement.
