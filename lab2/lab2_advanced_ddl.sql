create database university_main
owner= postgres
template = template0
encoding ='UTF8';

create database university_archive
template= template0
connection limit =50;

Create	database university_test
is_template = true
connection limit = 10;

create tablespace student_data
location 'C:\data\students';

create tablespace course_data
owner postgres
location 'C:\data\cources';

Create database university_distributed
tablespace = student_data
template=template0
encoding='LATIN9'
LC_COLLATE = 'C'
LC_CTYPE = 'C';

create Table students(
student_id serial	primary	key,
first_name varchar (50)	,
last_name varchar(50),
email varchar(100),
phone char(15),
date_of_birth date,
enrollment_date date,
gpa decimal	(3,2),
is_active bool,
graduation_year smallint);

create Table professors(
professor_id serial	primary	key,
first_name varchar(50),
 last_name varchar(50),
 email varchar(100),
 office_number varchar(20),
 hire_date date,
 salary decimal(12,2),
 is_tenured bool,
 years_experience integer);

create Table courses(
course_id serial	primary	key,
course_code char(8),
course_title varchar(100),
description text,
credits smallint,
max_enrollment integer,
course_fee decimal(10,2),
is_online bool,
created_at timestamp without time zone);

create Table class_schedule(
schedule_id serial	primary	key,
course_id integer,
professor_id integer,
classroom varchar(20),
class_date date,
start_time time	without	time zone,
end_time time without time zone,
duration interval);

create Table student_records(
record_id serial primary	key,
student_id  integer,
course_id  integer,
semester varchar(20),
year integer,
grade char(2),
attendance_percentage decimal(4,1),
submission_timestamp timestamp with time zone,
last_updated timestamp with time zone);

alter table students
add column middle_name varchar(30),
add column student_status varchar(20);

alter table students
alter column phone type varchar(20),
alter column student_status set default 'ACTIVE',
alter column gpa set default 0.00;

alter table professors
Add	column	department_code char(5),
Add	column	research_area text,
alter column years_experience type	smallint,
alter column is_tenured Set	default	false,
Add	column	last_promotion_date date;

alter table courses
Add	column	prerequisite_course_id integer,
Add	column	difficulty_level smallint,
alter column course_code type varchar(10),
alter column credits Set default 3,
Add	column	lab_required boolean default false;

alter table class_schedule
Add	column	room_capacity integer,
Drop column	duration,
Add	column	session_type varchar(15),
alter column classroom 	type varchar(30),
Add	column	equipment_needed	text;

alter table student_records
Add	column	extra_credit_points decimal(4,1),
alter column grade type varchar(5),
alter column extra_credit_points Set default 0.0,
Add	column	final_exam_date date,
Drop column	last_updated;

create Table departments (
 department_id serial	primary	key,
 department_name varchar(100),
 department_code char(5),
 building varchar(50),
 phone varchar(15),
 budget decimal(10,2),
 established_year integer);

create Table library_books
 (book_id serial	primary	key,
 isbn char(13),
 title varchar(200),
 author varchar (100),
 publisher varchar(100),
 publication_date date,
 price decimal(5,2),
 is_available boolean,
 acquisition_timestamp timestamp without time zone);

create Table student_book_loans(
 loan_id serial	primary	key,
 student_id integer,
 book_id   integer,
 loan_date date,
 due_date date,
 return_date date,
 fine_amount decimal(5,2),
 loan_status varchar(20));

Alter table professors Add column department_id integer;
Alter table students Add column advisor_id integer;
Alter table courses Add column department_id integer;

create Table grade_scale(
 grade_id serial	primary	key,
 letter_grade char(2),
 min_percentage decimal(4,1),
 max_percentage decimal(4,1),
 gpa_points decimal(3,2));

create Table semester_calendar (
 semester_id serial	primary	key,
 semester_name varchar(20),
 academic_year integer,
 start_date date,
 end_date date,
 registration_deadline timestamp with time zone,
 is_current boolean);

 Drop	table if exists student_book_loans;
 Drop	table  if exists library_books;
 Drop	table  if exists grade_scale;

CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(3,2),
    description TEXT
);

DROP TABLE semester_calendar CASCADE;

ALTER DATABASE university_test IS_TEMPLATE FALSE;
Drop database if exists university_test;
Drop database if exists university_distributed;
Create database	university_backup template=	university_main;