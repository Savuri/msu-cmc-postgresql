/*Кто сидел в первом ряду сегодня из рейса svo (шереметьево) - ovb (новосибирск) и когда они забронировали свои билеты вывести по возрастанию даты брони*/
select t.passenger_name as name, to_char(b.book_date, 'HH:MM DD Month YYYY') as "booking date", bp.seat_no as seat from tickets as t
join bookings as b on b.book_ref = t.book_ref
join boarding_passes as bp on bp.ticket_no = t.ticket_no
join flights as f on f.flight_id = bp.flight_id
where f.departure_airport = 'SVO' and f.arrival_airport = 'OVB' and bp.seat_no like '1_' -- Можно in но мне ведь неизвестно сколько мест в ряду
and f.scheduled_departure::date = bookings.now()::date and f.status = 'Arrived'
order by 2;

/*Доход с каждого рейса отправишегося позавчера (sum()) который уже успешно завешён (Arrived) с прибылью больше миллиона*/
select aircraft_code, departure_airport, arrival_airport, sum(tf.amount)::integer as income
from flights as f join ticket_flights as tf on tf.flight_id = f.flight_id
where bookings.now() - interval '2 day' = f.scheduled_departure and f.status = 'Arrived'
group by f.flight_id having sum(tf.amount) > 1000000;


/*Топ северных аэропортов по временным зонам*/
SELECT timezone, rank() OVER (
	PARTITION BY timezone
	ORDER BY coordinates[1] DESC
),
airport_name as "airport name", city, round(coordinates[1]::numeric, 2) AS latitude
FROM airports
ORDER BY timezone, rank;


/*Изменение популяции в городе с помощью with*/
with passangers_on_flight as (
	select flight_id, count(ticket_no) as cnt_on_flight from Ticket_flights as tf
	group by flight_id
),	arriving_flights_in_cities as (
	select flight_id, city, arrival_airport from Flights as f
	join Airports as a on airport_code = arrival_airport 
	where status = 'Arrived'
),  arriving_pop as (
	select city, arrival_airport, sum(cnt_on_flight) as total from arriving_flights_in_cities
	join passangers_on_flight on arriving_flights_in_cities.flight_id = passangers_on_flight.flight_id
	group by city, arrival_airport
),  departing_flights_in_cities as (
	select flight_id, city, departure_airport from Flights as f
	join Airports as a on airport_code = departure_airport
	where status = 'Arrived'
),  departing_pop as (
	select city, departure_airport, sum(cnt_on_flight) as total  from departing_flights_in_cities
	join passangers_on_flight on departing_flights_in_cities.flight_id = passangers_on_flight.flight_id
	group by city, departure_airport
)
select ap.city, ap.arrival_airport, ap.total as arrived, dp.total as departed, ap.total - dp.total as grow,
sum(ap.total) over (partition by ap.city) as "arrived in city",
sum(dp.total) over (partition by ap.city) as "departed from city",
sum(ap.total - dp.total) over (partition by ap.city) as "city grow"
from arriving_pop as ap join departing_pop as dp on dp.city = ap.city and ap.arrival_airport = dp.departure_airport
order by city;


/* Здаание: выбрать рейсы, где расстояние между аэропортами превышает 80% дальности самолета */
select f.flight_id, f.departure_airport, f.arrival_airport, ac.range, ap_dep.coordinates, ap_arr.coordinates, ap_dep.city, ap_arr.city from Flights as f
join Aircrafts as ac on f.aircraft_code = ac.aircraft_code
join airports as ap_dep on ap_dep.airport_code = f.departure_airport
join airports as ap_arr on ap_arr.airport_code = f.arrival_airport
where (ap_arr.coordinates <@> ap_dep.coordinates) * 1.609 >= 0.8 * ac.range;

