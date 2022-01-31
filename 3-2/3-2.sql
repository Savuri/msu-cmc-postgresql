CREATE ROLE test LOGIN PASSWORD 'test'; -- CREATE USER TEST

GRANT USAGE ON SCHEMA stat TO test;

GRANT 
SELECT ("id", course_name, review_text, marks, avg_mark, suggestions, review_date, head_of_course, course_credits, review_date),
UPDATE ("id", course_name, review_text, marks, avg_mark, suggestions, review_date, head_of_course, course_credits, review_date)
ON TABLE stat.courses_reviews TO test;

GRANT SELECT ON TABLE stat.students TO test;

GRANT SELECT, UPDATE, INSERT ON TABLE stat.courses TO test;


CREATE VIEW stat.anonymous_reviews AS
SELECT "id", course_id, course_name, head_of_course, review_text, marks, avg_mark, suggestions, course_credits FROM stat.courses_reviews;

CREATE VIEW stat.reviews_of_good_students AS
SELECT "id", students_id, course_id, "student_name", course_name, review_text, suggestions, avg_mark -- avg_mark для проверки
FROM stat.courses_reviews
WHERE avg_mark = 5.0;

GRANT SELECT ON TABLE stat.reviews_of_good_students TO test;

CREATE ROLE test1 LOGIN PASSWORD 'test1';

GRANT SELECT, UPDATE ON TABLE stat.anonymous_reviews TO test1;
GRANT test TO test1;


SET ROLE test1;

/* Проверка*/
-- Из таблиц
-- SELECT/UPDATE

SELECT course_name FROM stat.courses_reviews WHERE "id" = 1; -- ok
SELECT students_id FROM stat.courses_reviews WHERE "id" = 1; -- not ok

SELECT review_date from stat.courses_reviews WHERE "id" = 1;
UPDATE stat.courses_reviews SET review_date = '2021_05_20' WHERE "id" = 1; -- ok
SELECT review_date from stat.courses_reviews WHERE "id" = 1;
UPDATE stat.courses_reviews SET review_date = '2020_05_20' WHERE "id" = 1; -- return

--SELECT
SELECT "name" FROM stat.students where "id" = 1; -- ок
UPDATE stat.students SET "name" = 'Брезников Николай' WHERE "id" = 1; -- not ok


--SELECT/UPDATE/INSERT
SELECT * FROM stat.courses WHERE "id" = 2; -- ok

-- view only 
-- 1
SELECT * from stat.reviews_of_good_students ORDER BY "id" LIMIT 1; -- ok
UPDATE stat.reviews_of_good_students SET student_name = 'Лихтенберг Антон' where "id" = 5; -- not ok
-- 2
SELECT suggestions from stat.anonymous_reviews where "id" = 1; -- ok
UPDATE stat.anonymous_reviews SET suggestions = 'Нет предложений' where "id" = 1; -- ok
DELETE from stat.anonymous_reviews where "id" = 1 -- not ok
UPDATE stat.anonymous_reviews SET 
suggestions = 'Этому курсу нужны свежие умы! Пусть студенты выступают в начале каждой пары. Будет интерсно их послушать'
where "id" = 1; -- ret
/* Конец проверки 1*/

SET ROLE postgres;

SELECT * from stat.courses_reviews where "id" = 1;

DROP VIEW stat.anonymous_reviews;
DROP VIEW stat.reviews_of_good_students;

DROP OWNED BY test1;
DROP ROLE test1;

DROP OWNED BY test;
DROP ROLE test;

