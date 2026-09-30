Create database advanced_lab;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

Create table departments (
    dept_id serial primary key,
    dept_name varchar(50),
    budget integer,
    manager_id integer);

Create table projects (
    project_id serial primary key,
    project_name varchar(50),
    dept_id integer,
    start_date date,
    end_date date,
    budget integer);

ALTER TABLE projects
ADD CONSTRAINT fk_project_department
FOREIGN KEY (dept_id)
REFERENCES departments(dept_id);

ALTER TABLE departments
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id)
REFERENCES employees(emp_id);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('John', 'Smith', 'IT', 70000, '2019-05-10', 'Active'),
('Anna', 'Brown', 'Sales', 55000, '2021-03-15', 'Active'),
('Michael', 'Lee', 'IT', 85000, '2018-07-20', 'Active'),
('Sara', 'Wilson', 'HR', 45000, '2022-09-01', 'Inactive'),
('David', 'Miller', 'Sales', 65000, '2019-11-12', 'Active');

INSERT INTO projects
(project_name, dept_id, start_date, end_date, budget)
VALUES
('Website Upgrade', 1, '2022-01-01', '2022-12-31', 60000),
('Sales Platform', 2, '2023-02-01', '2024-06-30', 80000),
('HR System', 3, '2024-01-10', '2025-05-30', 40000);

INSERT INTO employees
(emp_id, first_name, last_name, department)
VALUES
(100, 'Alex', 'Green', 'IT');

INSERT INTO employees
(first_name, last_name, department, salary, hire_date, status)
VALUES
('Emma', 'White', 'Sales', DEFAULT, CURRENT_DATE, DEFAULT);

INSERT INTO departments
(dept_name, budget, manager_id)
VALUES
('IT', 150000, 1),
('Sales', 120000, 2),
('HR', 90000, 4);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Daniel', 'Black', 'IT', 50000 * 1.1, CURRENT_DATE);

CREATE TEMPORARY TABLE temp_employees
AS
SELECT *
FROM employees
WHERE 1 = 0;

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
AND hire_date < '2020-01-01';

UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.20
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
AND hire_date > '2023-01-01'
AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Robert', 'Taylor', NULL, NULL, CURRENT_DATE);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
OR department IS NULL;

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Laura', 'Martin', 'IT', 62000, CURRENT_DATE)
RETURNING emp_id,
          first_name || ' ' || last_name AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id,
          old.salary AS old_salary,
          new.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
SELECT
    'James',
    'Anderson',
    'IT',
    70000,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'James'
    AND last_name = 'Anderson'
);

UPDATE employees e
SET salary =
    CASE
        WHEN (
            SELECT d.budget
            FROM departments d
            WHERE d.dept_name = e.department
        ) > 100000
        THEN salary * 1.10
        ELSE salary * 1.05
    END
WHERE EXISTS (
    SELECT 1
    FROM departments d
    WHERE d.dept_name = e.department
);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
('Bulk1', 'Employee', 'IT', 50000, CURRENT_DATE),
('Bulk2', 'Employee', 'IT', 52000, CURRENT_DATE),
('Bulk3', 'Employee', 'Sales', 54000, CURRENT_DATE),
('Bulk4', 'Employee', 'Sales', 56000, CURRENT_DATE),
('Bulk5', 'Employee', 'HR', 58000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN (
    'Bulk1',
    'Bulk2',
    'Bulk3',
    'Bulk4',
    'Bulk5'
);

CREATE TABLE employee_archive (
    emp_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20)
);

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
AND (
    SELECT COUNT(*)
    FROM employees e
    JOIN departments d
        ON e.department = d.dept_name
    WHERE d.dept_id = p.dept_id
) > 3;
