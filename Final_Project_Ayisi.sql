-- A travel agency wants to know the average amount of time travelers spent in each destination. Order the results in descending order.
select destination, avg(trip.duration) as avg_stay, count(distinct itineraries.traveler_ID) as number_of_travelers
from trip
join destination on trip.destination_ID = destination.destination_ID
join itineraries on trip.trip_ID = itineraries.trip_ID
group by destination.destination
order by avg_stay desc;

-- How many travelers are of each nationality?
select traveler_nationality, count(*) as traveler_count
from traveler
group by traveler_nationality;

-- What is the total amount spent on each transportation type individually?
select transportation_type, sum(transportation_cost) as total_cost
from transportation
group by transportation_type;

-- List all trips that cost more than the average trip cost.
select
    trip_costs.trip_id,
    trip_costs.total_trip_cost
from
    (
        select
            trip.trip_id,
            sum(transportation.transportation_cost + accommodation.accommodation_cost) as total_trip_cost
        from trip
        join itineraries on trip.trip_id = itineraries.trip_id
        join transportation on itineraries.transportation_id = transportation.transportation_id
        join accommodation on itineraries.accommodation_id = accommodation.accommodation_id
        group by trip.trip_id
    ) as trip_costs
where
    trip_costs.total_trip_cost >
    (
        select avg(all_costs.trip_total)
        from
            (
                select
                    trip.trip_id,
                    sum(transportation.transportation_cost + accommodation.accommodation_cost) as trip_total
                from trip
                join itineraries on trip.trip_id = itineraries.trip_id
                join transportation on itineraries.transportation_id = transportation.transportation_id
                join accommodation on itineraries.accommodation_id = accommodation.accommodation_id
                group by trip.trip_id) as all_costs);

-- Have any travelers visited more than 2 distinct destinations?
select distinct(traveler.traveler_name), count(distinct trip.destination_ID) as destination_count
from traveler
join itineraries on traveler.traveler_id = itineraries.traveler_ID
join trip on itineraries.trip_ID = trip.trip_ID
group by traveler.traveler_id, traveler.traveler_name
having count(distinct trip.destination_ID) > 2;

-- Which travelers have used only one mode of transportation on their trips?
select traveler.traveler_name
from traveler
join itineraries on traveler.traveler_id = itineraries.traveler_ID
join transportation on itineraries.transportation_ID = transportation.transportation_ID
group by traveler.traveler_id, traveler.traveler_name
having count(distinct transportation.transportation_type) = 1;

-- For each nationality, what is the average trip cost?
select traveler.traveler_nationality,
       avg(traveler2.transportation_cost + accommodation.accommodation_cost) as avg_trip_cost
from traveler
join itineraries on traveler.traveler_id = itineraries.traveler_ID
join trip on itineraries.trip_ID = trip.trip_ID
left join transportation traveler2 on itineraries.transportation_ID = traveler2.transportation_ID
left join accommodation on itineraries.accommodation_ID = accommodation.accommodation_ID
group by traveler.traveler_nationality;

-- List all travelers who have the same name and their demographic information.
select
    trav1.traveler_name,
    trav1.traveler_age as age_1,
    trav1.traveler_gender as gender_1,
    trav1.traveler_nationality as nationality_1,
    trav2.traveler_age as age_2,
    trav2.traveler_gender as gender_2,
    trav2.traveler_nationality as nationality_2
from traveler trav1
join traveler trav2 on trav1.traveler_name = trav2.traveler_name 
    and trav1.traveler_id < trav2.traveler_id; 
    
-- Determine what destinations are most popular by season
select
    case 
        when extract(month from trip.start_date) in (12, 1, 2) then 'Winter'
        when extract(month from trip.start_date) in (3, 4, 5) then 'Spring'
        when extract(month from trip.start_date) in (6, 7, 8) then 'Summer'
        when extract(month from trip.start_date) in (9, 10, 11) then 'Fall'
    end as season,
    destination.destination,
    count(*) as visit_count
from trip
join destination on trip.destination_ID = destination.destination_ID
group by season, destination.destination
order by season, visit_count desc;