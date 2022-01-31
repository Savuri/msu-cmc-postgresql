 -- 1) Запрос к связаным таблицам + массив
EXPLAIN ANALYZE SELECT * FROM stat.courses_reviews JOIN stat.students on (students.id = students_id)
WHERE ARRAY['Староста группы', 'Идеальная посещаемость']::varchar(100)[] <@ achivments AND extract(YEAR from review_date) = 2021 LIMIT 1000000;
/*
 Limit  (cost=889641.65..8167243.99 rows=9968 width=1086) (actual time=94669.125..110573.821 rows=678895 loops=1)
   ->  Gather  (cost=889641.65..8167243.99 rows=9968 width=1086) (actual time=94669.123..110541.064 rows=678895 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Parallel Hash Join  (cost=888641.65..8165247.19 rows=4153 width=1086) (actual time=94667.443..109761.296 rows=226298 loops=3)
               Hash Cond: (courses_reviews.students_id = students.id)
               ->  Parallel Seq Scan on courses_reviews  (cost=0.00..7243932.67 rows=208333 width=476) (actual time=0.821..79515.947 rows=16666384 loops=3)
                     Filter: (date_part('year'::text, (review_date)::timestamp without time zone) = '2021'::double precision)
                     Rows Removed by Filter: 16666949
               ->  Parallel Hash  (cost=881113.33..881113.33 rows=83065 width=610) (actual time=5529.728..5529.729 rows=45245 loops=3)
                     Buckets: 8192  Batches: 32  Memory Usage: 3168kB
                     ->  Parallel Seq Scan on students  (cost=0.00..881113.33 rows=83065 width=610) (actual time=0.898..5468.635 rows=45245 loops=3)
                           Filter: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
                           Rows Removed by Filter: 3288088
 Planning Time: 2.122 ms
 Execution Time: 110595.529 ms

*/
CREATE INDEX gin_array ON stat.Students USING GIN(achivments);

EXPLAIN ANALYZE SELECT * FROM stat.courses_reviews JOIN stat.students on (students.id = students_id)
WHERE ARRAY['Староста группы', 'Идеальная посещаемость']::varchar(100)[] <@ achivments AND extract(YEAR from review_date) = 2021 LIMIT 1000000;
/*
Limit  (cost=518079.18..7795681.52 rows=9968 width=1086) (actual time=90865.297..106674.427 rows=678895 loops=1)
   ->  Gather  (cost=518079.18..7795681.52 rows=9968 width=1086) (actual time=90865.295..106641.814 rows=678895 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Parallel Hash Join  (cost=517079.18..7793684.72 rows=4153 width=1086) (actual time=90861.464..106015.782 rows=226298 loops=3)
               Hash Cond: (courses_reviews.students_id = students.id)
               ->  Parallel Seq Scan on courses_reviews  (cost=0.00..7243932.67 rows=208333 width=476) (actual time=0.660..79602.622 rows=16666384 loops=3)
                     Filter: (date_part('year'::text, (review_date)::timestamp without time zone) = '2021'::double precision)
                     Rows Removed by Filter: 16666949
               ->  Parallel Hash  (cost=509550.86..509550.86 rows=83065 width=610) (actual time=336.029..336.029 rows=45245 loops=3)
                     Buckets: 8192  Batches: 32  Memory Usage: 3168kB
                     ->  Parallel Bitmap Heap Scan on students  (cost=2381.01..509550.86 rows=83065 width=610) (actual time=114.436..307.849 rows=45245 loops=3)
                           Recheck Cond: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
                           Rows Removed by Index Recheck: 248377
                           Heap Blocks: exact=21127 lossy=26988
                           ->  Bitmap Index Scan on gin_array  (cost=0.00..2331.17 rows=199356 width=0) (actual time=106.972..106.972 rows=135735 loops=1)
                                 Index Cond: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
 Planning Time: 3.429 ms
 Execution Time: 106693.998 ms
*/

--1.2)
EXPLAIN ANALYZE SELECT * FROM stat.students
WHERE ARRAY['Староста группы', 'Идеальная посещаемость']::varchar(100)[] <@ achivments;
/*
 Gather  (cost=1000.00..902048.93 rows=199356 width=610) (actual time=0.418..7111.526 rows=135735 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on students  (cost=0.00..881113.33 rows=83065 width=610) (actual time=1.816..7086.658 rows=45245 loops=3)
         Filter: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
         Rows Removed by Filter: 3288088
 Planning Time: 0.586 ms
 Execution Time: 7116.971 ms

*/

EXPLAIN ANALYZE SELECT * FROM stat.students
WHERE ARRAY['Староста группы', 'Идеальная посещаемость']::varchar(100)[] <@ achivments;
/*
 Gather  (cost=3381.01..530486.46 rows=199356 width=610) (actual time=121.702..339.361 rows=135735 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Bitmap Heap Scan on students  (cost=2381.01..509550.86 rows=83065 width=610) (actual time=117.533..318.279 rows=45245 loops=3)
         Recheck Cond: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
         Rows Removed by Index Recheck: 248377
         Heap Blocks: exact=18427 lossy=24834
         ->  Bitmap Index Scan on gin_array  (cost=0.00..2331.17 rows=199356 width=0) (actual time=111.713..111.713 rows=135735 loops=1)
               Index Cond: ('{"Староста группы","Идеальная посещаемость"}'::character varying(100)[] <@ achivments)
 Planning Time: 0.275 ms
 Execution Time: 342.862 ms
*/

DROP INDEX stat.gin_array;
-- 2) (JSON)
EXPLAIN ANALYZE SELECT * FROM stat.Students
WHERE (marks ? 'Математический анализ') AND ((marks->>'Математический анализ')::integer >= 4)
AND (marks ? 'Комплексный анализ') AND ((marks->>'Комплексный анализ')::integer >= 4);
/*
Gather  (cost=1000.00..975863.43 rows=1 width=610) (actual time=0.612..5863.072 rows=4443295 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on students  (cost=0.00..974863.33 rows=1 width=610) (actual time=0.175..5519.117 rows=1481098 loops=3)
         Filter: ((marks ? 'Математический анализ'::text) AND (marks ? 'Комплексный анализ'::text) AND (((marks ->> 'Математический анализ'::text))::integer >= 4) AND (((marks ->> 'Комплексный анализ'::text))::integer >= 4))
         Rows Removed by Filter: 1852235
 Planning Time: 1.763 ms
 Execution Time: 5976.445 ms
*/

CREATE INDEX gin_json ON stat.Students USING GIN(marks);

EXPLAIN ANALYZE SELECT * FROM stat.Students
WHERE (marks ? 'Математический анализ') AND ((marks->>'Математический анализ')::integer >= 4)
AND (marks ? 'Комплексный анализ') AND ((marks->>'Комплексный анализ')::integer >= 4);
/*
 Bitmap Heap Scan on students  (cost=712.10..752.35 rows=1 width=610) (actual time=831.131..8627.021 rows=4443295 loops=1)
   Recheck Cond: ((marks ? 'Математический анализ'::text) AND (marks ? 'Комплексный анализ'::text))
   Filter: ((((marks ->> 'Математический анализ'::text))::integer >= 4) AND (((marks ->> 'Комплексный анализ'::text))::integer >= 4))
   Rows Removed by Filter: 5556705
   Heap Blocks: exact=39373 lossy=789657
   ->  Bitmap Index Scan on gin_json  (cost=0.00..712.10 rows=10 width=0) (actual time=825.459..825.460 rows=10000000 loops=1)
         Index Cond: ((marks ? 'Математический анализ'::text) AND (marks ? 'Комплексный анализ'::text))
 Planning Time: 0.829 ms
 Execution Time: 8726.345 ms
*/
-- Это похоже был одоноразовый выброс. Ну или кэш снизил время выполнения до Execution Time: 6034.450 ms. 
-- Здесь видно что индекс может замедлить работу запроса (Его решил использовать сам postgers)

DROP INDEX stat.gin_json;


-- 3) (ПОЛНОТЕКСТОВЫЙ ПОИСК)

EXPLAIN ANALYZE SELECT * FROM  stat.courses_reviews 
WHERE to_tsvector('russian', review_text) @@ to_tsquery('Плох | Отвратительн | Ужасн | Слишк <-> Сложн');
/*
                                                                   QUERY PLAN                                                                    
-------------------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..28012922.13 rows=1494523 width=476) (actual time=1.058..431485.942 rows=16666877 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on courses_reviews  (cost=0.00..27862469.83 rows=622718 width=476) (actual time=1.062..429791.163 rows=5555626 loops=3)
         Filter: (to_tsvector('russian'::regconfig, (review_text)::text) @@ to_tsquery('Плох | Отвратительн | Ужасн | Слишк <-> Сложн'::text))
         Rows Removed by Filter: 27777708
 Planning Time: 1.878 ms
 Execution Time: 432078.968 ms
*/
CREATE INDEX gin_text ON stat.courses_reviews USING GIN(to_tsvector('russian', review_text));	

EXPLAIN ANALYZE SELECT * FROM  stat.courses_reviews 
WHERE to_tsvector('russian', review_text) @@ to_tsquery('Плох | Отвратительн | Ужасн | Слишк <-> Сложн');

/*
 Gather  (cost=14798.31..24543480.73 rows=1494975 width=476) (actual time=2155.701..420842.038 rows=16666877 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Bitmap Heap Scan on courses_reviews  (cost=13798.31..24392983.23 rows=622906 width=476) (actual time=2150.742..419123.768 rows=5555626 loops=3)
         Recheck Cond: (to_tsvector('russian'::regconfig, (review_text)::text) @@ to_tsquery('Плох | Отвратительн | Ужасн | Слишк <-> Сложн'::text))
         Rows Removed by Index Recheck: 25735473
         Heap Blocks: exact=9673 lossy=2037708
         ->  Bitmap Index Scan on gin_text  (cost=0.00..13424.56 rows=1494975 width=0) (actual time=2145.294..2145.295 rows=16666877 loops=1)
               Index Cond: (to_tsvector('russian'::regconfig, (review_text)::text) @@ to_tsquery('Плох | Отвратительн | Ужасн | Слишк <-> Сложн'::text))
 Planning Time: 4.328 ms
 Execution Time: 421436.451 ms
*/

DROP INDEX stat.gin_text;


-- СЕКЦИОНИРОВАНИЕ ТАБЛИЦЫ ДЛЯ УСКОРЕНИЯ ДОСТУПА
create table stat.parted(
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
) PARTITION BY RANGE (review_date);


CREATE TABLE stat.parted_2020_05_20_to_2020_05_24 PARTITION OF stat.parted FOR VALUES FROM ('2020-05-20') TO ('2020-05-25');
CREATE TABLE stat.parted_2020_05_25_to_2021_05_19 PARTITION OF stat.parted FOR VALUES FROM ('2020-05-25') TO ('2021-05-20');
CREATE TABLE stat.parted_2021_05_20_to_2021_05_24 PARTITION OF stat.parted FOR VALUES FROM ('2021-05-20') TO ('2021-05-25');
CREATE TABLE stat.parted_2021_05_25_to_2022_05_19 PARTITION OF stat.parted FOR VALUES FROM ('2021-05-25') TO ('2022-05-20');


drop table stat.parted;
drop TABLE stat.parted_2020_05_20_to_2020_05_24;
drop TABLE stat.parted_2020_05_25_to_2021_05_19;
drop TABLE stat.parted_2021_05_20_to_2021_05_24;
drop TABLE stat.parted_2021_05_25_to_2022_05_19;

INSERT INTO stat.parted SELECT * FROM stat.courses_reviews;

EXPLAIN ANALYZE SELECT * FROM stat.courses_reviews where review_date >= '2021-05-20' and review_date <= '2021-05-30';
/*
 Seq Scan on courses_reviews  (cost=0.00..8014766.00 rows=49456666 width=476) (actual time=0.018..40225.510 rows=49999152 loops=1)
   Filter: ((review_date >= '2021-05-20'::date) AND (review_date <= '2021-05-30'::date))
   Rows Removed by Filter: 50000848
 Planning Time: 2.570 ms
 Execution Time: 41429.344 ms
*/
EXPLAIN ANALYZE SELECT * FROM stat.parted where review_date >= '2021-05-20' and review_date <= '2021-05-30';
/*
                                                                       QUERY PLAN                                                                       
--------------------------------------------------------------------------------------------------------------------------------------------------------
 Append  (cost=0.00..4257303.20 rows=50006260 width=476) (actual time=2.075..18596.014 rows=49999152 loops=1)
   ->  Seq Scan on parted_2021_05_20_to_2021_05_24  (cost=0.00..1821567.58 rows=22734972 width=475) (actual time=2.074..7509.182 rows=22726481 loops=1)
         Filter: ((review_date >= '2021-05-20'::date) AND (review_date <= '2021-05-30'::date))
   ->  Seq Scan on parted_2021_05_25_to_2022_05_19  (cost=0.00..2185704.32 rows=27271288 width=476) (actual time=0.367..9338.327 rows=27272671 loops=1)
         Filter: ((review_date >= '2021-05-20'::date) AND (review_date <= '2021-05-30'::date))
 Planning Time: 0.278 ms
 Execution Time: 19506.935 ms
*/

