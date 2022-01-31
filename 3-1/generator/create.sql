DROP DATABASE stat;

CREATE DATABASE stat;

\connect stat

drop schema stat;

create schema stat;

create table stat.students(
    id serial,
    name varchar(100),
    marks jsonb,
    avg_session_mark float,
    achivments varchar(100)[]
);


create table stat.courses(
    id serial,
    course_name varchar(100),
    head_of_course varchar(100),
    credits int,
    course_description varchar(1000)
);

create table stat.courses_reviews(
    id serial,
    students_id int,
    course_id int,
    course_name varchar(100),
    review_text varchar(1000),
    marks jsonb,
    avg_mark float,
    suggestions varchar(1000),
    review_date date,
    student_avg_session_mark float,
    student_name varchar(100),
    head_of_course varchar(100),
    course_credits int
);

copy stat.students from '/home/yuri/PycharmProjects/ml_prak/std_data.txt' USING DELIMITERS '/';
copy stat.courses from '/home/yuri/PycharmProjects/ml_prak/course_data.txt' USING DELIMITERS '/';
copy stat.courses_reviews from '/home/yuri/PycharmProjects/ml_prak/review_data.txt' USING DELIMITERS '/';

ALTER TABLE stat.courses_reviews add primary key(id);
ALTER TABLE stat.courses add primary key(id);
ALTER TABLE stat.students add primary key(id);

ALTER TABLE stat.courses_reviews
ADD FOREIGN KEY (students_id)
REFERENCES stat.students(id)
ON DELETE RESTRICT;

ALTER TABLE stat.courses_reviews
ADD FOREIGN KEY (course_id)
REFERENCES stat.courses(id)
ON DELETE RESTRICT;