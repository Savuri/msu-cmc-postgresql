DROP TRIGGER IF EXISTS delete_trig_for_stud ON students;


CREATE OR REPLACE FUNCTION delete_trig_for_stud() RETURNS TRIGGER AS $trg1$
	begin
		delete from certificates where old.vacc_certificate_id = id;

		return NULL;
	end;
$trg1$ LANGUAGE PLPGSQL;


CREATE TRIGGER delete_trig_for_stud AFTER DELETE ON students for each row EXECUTE FUNCTION delete_trig_for_stud();

select * from students;
select * from certificates;
delete from students;


--------------------------------------------------------------

DROP TRIGGER IF EXISTS check_vaccinations_date_consistency ON Vaccinations;


CREATE OR REPLACE FUNCTION check_vaccinations_date_consistency() RETURNS TRIGGER AS $trg2$
	declare counter integer;
	begin
		select count(*) from CertificatesVaccinations where old.id = CertificatesVaccinations.vacc_id into counter;
		if (counter > 2 or counter = 0) then
			raise exception 'Vaccinations table is not consistency';
		end if;
		return new;
	end;
$trg2$ LANGUAGE PLPGSQL;


CREATE CONSTRAINT TRIGGER check_vaccinations_date_consistency AFTER
INSERT
OR
UPDATE ON Vaccinations DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_vaccinations_date_consistency();


select * from CertificatesVaccinations;
select * from Vaccinations;


begin;
	insert into Vaccinations(name, series, date_of_vac, place, full_name_of_doctor) values
	('Гам-КОВИД-Вак', '123456987', '2021-12-20', 'Московская поликлиника №1', 'Хачатарян Алла Альбертовна');
commit;

