create database labfunctions;

CREATE TABLE employees (
 employee_id SERIAL PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 department VARCHAR(50),
 salary NUMERIC(10,2),
 hire_date DATE,
 manager_id INTEGER,
 email VARCHAR(100)
);
CREATE TABLE projects (
 project_id SERIAL PRIMARY KEY,
 project_name VARCHAR(100),
 budget NUMERIC(12,2),
 start_date DATE,
 end_date DATE,
 status VARCHAR(20)
);
CREATE TABLE assignments (
 assignment_id SERIAL PRIMARY KEY,
 employee_id INTEGER REFERENCES employees(employee_id),
 project_id INTEGER REFERENCES projects(project_id),
 hours_worked NUMERIC(5,1),
 assignment_date DATE
);

INSERT INTO employees (first_name, last_name, department,
salary, hire_date, manager_id, email) VALUES
('John', 'Smith', 'IT', 75000, '2020-01-15', NULL,
'john.smith@company.com'),
('Sarah', 'Johnson', 'IT', 65000, '2020-03-20', 1,
'sarah.j@company.com'),
('Michael', 'Brown', 'Sales', 55000, '2019-06-10', NULL,
'mbrown@company.com'),
('Emily', 'Davis', 'HR', 60000, '2021-02-01', NULL,
'emily.davis@company.com'),
('Robert', 'Wilson', 'IT', 70000, '2020-08-15', 1, NULL),
('Lisa', 'Anderson', 'Sales', 58000, '2021-05-20', 3,
'lisa.a@company.com');
INSERT INTO projects (project_name, budget, start_date,
end_date, status) VALUES
('Website Redesign', 150000, '2024-01-01', '2024-06-30',
'Active'),
('CRM Implementation', 200000, '2024-02-15', '2024-12-31',
'Active'),
('Marketing Campaign', 80000, '2024-03-01', '2024-05-31',
'Completed'),
('Database Migration', 120000, '2024-01-10', NULL, 'Active');
INSERT INTO assignments (employee_id, project_id,
hours_worked, assignment_date) VALUES
(1, 1, 120.5, '2024-01-15'),
(2, 1, 95.0, '2024-01-20'),
(1, 4, 80.0, '2024-02-01'),
(3, 3, 60.0, '2024-03-05'),
(5, 2, 110.0, '2024-02-20'),
(6, 3, 75.5, '2024-03-10');

--PART1
select first_name || ' ' || last_name as fullname, department, salary
from employees;

select distinct department from employees;

select project_name, budget,
case
    when budget >150000 then 'Large'
    when budget between 100000 and 150000 then 'Medium'
    else 'Small'
end as budget_category
from projects
;

Select first_name, coalesce (email, 'No email provided') from employees;

--PART2
Select * from employees
where hire_date>'2020-01-01';

select * from employees
where salary between 60000 and 70000;

select * from employees
where last_name like 'S%' or last_name like 'J%';

select * from employees
where manager_id is not null and department='IT';

--PART3
select upper(first_name), length(last_name), substring(email from 1 for 3)
from employees;

select first_name, last_name, salary*12 as annual_salary, round(salary, 2), salary*1.1 as raised_salary
from employees;

select format('Project: %s - Budget: $ %s - Status: %s', project_name, budget, status) from projects;

select first_name, last_name, extract (year from age(current_date, hire_date)) as years_with_company from employees;

--PART4
select department, avg(salary) as avg_salary
from employees group by department;

select p.project_name, sum(a.hours_worked) as total_hours from projects p
join assignments a on p.project_id=a.project_id group by p.project_name;

select department, count(employee_id) from employees group by department having count(*)>1;

select max(salary) as max_salary, min(salary) as min_salary, sum(salary) as total_payroll from employees;

--PART5
select employee_id, (first_name || ' ' || last_name) as full_name, salary
from employees where salary>65000
union
select employee_id, (first_name || ' ' || last_name) as full_name, salary
from employees where hire_date>'2020-01-01';

select * from employees where department='IT'
intersect
select * from employees where salary>65000;

select employee_id, first_name from employees
except
SELECT e.employee_id, e.first_name
FROM employees e
JOIN assignments a
    ON e.employee_id = a.employee_id;

--PART6
select * from employees e
where exists(select 1 from assignments a where e.employee_id=a.employee_id);

select * from employees
where employee_id in(
    select employee_id from assignments
    where project_id in(
        select project_id from projects where status = 'ACTIVE'
        )
    );

select * from employees
where salary>any(select salary from employees where department='Sales');

--PART7
select e.first_name || ' '|| e.last_name as full_name,
       e.department,
       avg(a.hours_worked) as avg_hours,
       rank() over(partition by e.department order by e.salary desc) as salary_rank
from employees e
    left join assignments a on
    e.employee_id=a.employee_id
group by e.employee_id, e.first_name, e.last_name, e. department, e.salary;

select p.project_name, sum(a.hours_worked) as total_hours,
       count(distinct a.employee_id) as employee_number
from projects p
    join assignments a on p.project_id = a.project_id
group by p.project_id, p.project_name
having sum(a.hours_worked)>150;

select department,
       count(*) as total_num_employees,
       avg(salary) as avg_salary,
        (select e2.first_name || ' ' || e2.last_name from employees e2 where e2.department=e.department order by salary desc limit 1) as highest_paid_emp,
        greatest(max(salary), avg(salary)) as greatest_salary,
        least(min(salary), avg(salary)) as least_salary
from employees e
group by department;