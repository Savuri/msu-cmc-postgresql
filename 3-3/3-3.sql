CREATE OR REPLACE FUNCTION get_trusted_students_reviews_of_course(subject varchar(100) DEFAULT 'ANY', boardry_mark float DEFAULT 4.9,
											   cnt_of_reviews int DEFAULT 10,
											   review_date_beg date DEFAULT date_trunc('year', now()::date),
											   review_date_end date DEFAULT now(), limit_ int DEFAULT 1000000)
RETURNS SETOF stat.courses_reviews
AS
$$
DECLARE
analyzed_cnt int = 0;
accepted_cnt int = 0;
curs CURSOR IS SELECT * FROM stat.courses_reviews WHERE stat.courses_reviews.review_date >= review_date_beg AND stat.courses_reviews.review_date <= review_date_end
AND (subject = 'ANY' OR subject = stat.courses_reviews.course_name);
BEGIN
	FOR row_ IN curs LOOP
		IF accepted_cnt = cnt_of_reviews OR analyzed_cnt = limit_ THEN
			EXIT;
		END IF;
		
		IF row_.student_avg_session_mark >= boardry_mark THEN
			accepted_cnt = accepted_cnt + 1;
			
			RETURN NEXT row_;
		END IF;
		
		analyzed_cnt = analyzed_cnt + 1;
	END LOOP;
	
	IF accepted_cnt != cnt_of_reviews THEN
		RAISE NOTICE 'Not enough good students or wrong subject';
	END IF;
	

	BEGIN
		RAISE NOTICE 'Analyzed %, accepted %, precent of trustable students %', analyzed_cnt, accepted_cnt, round(accepted_cnt::numeric/analyzed_cnt * 100, 2);
	EXCEPTION
		WHEN division_by_zero THEN 
			RAISE NOTICE 'division_by_zero';
	END;
	RETURN;

END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION is_avg_correct(marks jsonb, avg_score float)
RETURNS bool AS
$$
DECLARE 
sum_of_marks int;
cnt_of_marks int;
BEGIN
	PERFORM "value" FROM jsonb_each_text(marks) WHERE "value"::int < 0;
	IF FOUND THEN 
		RAISE NOTICE 'Negative mark in jsonb';
		RETURN FALSE;
	END IF;
	
	SELECT sum("value"::int), count(*) into sum_of_marks, cnt_of_marks FROM jsonb_each_text(marks);
	
	IF CNT_OF_MARKS = 0 THEN
		RAISE NOTICE 'Jsonb is empty';
		RETURN FALSE;
	END IF;
	
	IF SUM_OF_MARKS::float / CNT_OF_MARKS != avg_score THEN
		RAISE NOTICE 'avg_of_marks = %, avg_score = %', SUM_OF_MARKS::float / CNT_OF_MARKS, avg_score;
		RETURN FALSE;
	END IF;
	
	RETURN TRUE;
END;
$$
LANGUAGE plpgsql;


SELECT * FROM get_trusted_students_reviews_of_course(cnt_of_reviews => 1);
SELECT * FROM get_trusted_students_reviews_of_course(limit_ => 1);


SELECT is_avg_correct(marks, avg_session_mark) FROM stat.students LIMIT 1;
SELECT is_avg_correct(marks, avg_mark) FROM stat.courses_reviews LIMIT 2;
SELECT is_avg_correct('{"a":"1", "b":"2"}', 1);
SELECT is_avg_correct('{"a":"2", "b":"2"}', 2);

DROP FUNCTION get_trusted_students_reviews_of_course;
DROP FUNCTION is_avg_correct;

