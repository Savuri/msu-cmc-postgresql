/*
1)Вывести всех привитых студентов и серию и дату получения ими сертификатов о вакцинации
*/
/*
select student_doc_id, full_name, series, date_of_issue from students
join certificates on certificates.id = students.vacc_certificate_id;
*/


/* 
2)Найти студентов, которым ставили первую прививку с серией с девяткой в десятках (типа вдруг вакцина испортилась и государству нужны
данные об этих людях)
Выведу ещё и серию чтобы можно было проверить
*/
/*
select student_doc_id, full_name, vaccinations.series as "vac series",
full_name_of_doctor, date_of_vac, place as "place of vaccination" from students
join certificates on certificates.id = students.vacc_certificate_id
join CertificatesVaccinations on certificate_id = certificates.id
join vaccinations on vacc_id = vaccinations.id 
where vaccinations.series not like 'II-%' and vaccinations.series like '%9_';
*/
/*
3) Вывести первого заболевшего в каждый карантин
*/
/*
with sicks_before_qurantines as ( 
	select quarantines.id as qid, quarantines.start as qstart, full_name, beg_sick, end_of_sick from quarantines
	join "groups" on group_id = groups.id
	join students on students.group_id = quarantines.group_id
	join sicks on sicks.student_id = students.id
	where quarantines.start >= sicks.beg_sick and (quarantines.start < sicks.end_of_sick) is not false
	order by quarantines.id, beg_sick
), first_ill_dates_per_sicks_before_qurantines as (
	select qid, min(beg_sick) as beg_sick from sicks_before_qurantines
	group by qid 
) select sbq.qid, qstart, full_name, sbq.beg_sick, end_of_sick from sicks_before_qurantines as sbq
join first_ill_dates_per_sicks_before_qurantines as fid on fid.qid = sbq.qid and fid.beg_sick = sbq.beg_sick;
*/

/*
4) Вывести аудитории которые необходимо продезинфицировать из-за последнего карантина
*/
/*
with last_q as (
	select * from Quarantines order by start desc limit 1
) select /*last_q.start,*/ au."name" as cabinet, au.floor from auditoriums as au
join groupsauditoriums as ga on aud_id = au.id 
join "groups" as gr on gr.id = group_id
join last_q on last_q.group_id = gr.id;
*/



/* 
1) Изменить студенческий билет Цао Анны Михайловной со студенческим 00000030 на 00000001
Не успешно студент со стундческим билетом 00000001 уже существеует
*/
-- update students set student_doc_id = '00000037'
-- where "id" = (select "id" from students where full_name = 'Цао Анна Михайловна');
/*
Если менять на 00000037 то всё ок
*/
-- select full_name, student_doc_id from students where student_doc_id = '00000001' or student_doc_id = '00000030';
-- select full_name, student_doc_id from students where student_doc_id = '00000001' or student_doc_id = '00000037';

/*
2) Отменяем магистратуру
*/
-- delete from "groups" where "name" = 'М-501' or "name" = 'М-601';
/* 
Тоже с ошибкой всё ещё есть студенты 
но если отчислить всех студентов в этих группах
*/
-- delete from students where student_doc_id between '00000011' and '00000014';
-- delete from "groups" where "name" = 'М-501' or "name" = 'М-601';
/*
то группы успешно удалятся
*/


/*
3) Удаляем сертификат (студент принёс купленный)
*/
-- delete from certificates where "id" = (select vacc_certificate_id from students where full_name = 'Чао Юрий Михайлович');

-- select full_name, vacc_certificate_id from students;
-- select full_name, vacc_certificate_id from students;



/*Количество студентов по месяцам болеющий за год*/

with got_sick as (
	select extract(month from beg_sick) as mm, count(*) as got_sick from sicks
	join students on students.id = sicks.id
	where beg_sick >= '2021-01-01'
	group by mm
), recovered as (
	select extract(month from end_of_sick) as mm, count(*) as recovered from sicks
	join students on students.id = sicks.id
	where (end_of_sick >= '2021-01-01')
	group by mm
), months as (
	select generate_series(1, 12) as mm
) select months.mm, COALESCE(gsk.got_sick, 0) as got_sick, COALESCE(rec.recovered, 0) as recovered,
COALESCE(rec.recovered, 0) - COALESCE(gsk.got_sick, 0) as trend from months
left join recovered as rec on rec.mm = months.mm
left join got_sick as gsk on gsk.mm = months.mm;

