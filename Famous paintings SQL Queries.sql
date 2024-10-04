use painting;
select * from artist;              #421
select * from canvas_size;         #200
select * from museum;              #57
select * from canvas_size;         #200
select * from museum_hours;        #351
select * from product_size;        #110347
select * from work;                #14776
select * from subject;             #6771

#Q1. Fetch all the paintings which are not displayed on any museums?

select count(*) 
from work 
where museum_id is null;

#Q2. Are there museuems without any paintings?

select * from museum m
	where not exists (select 1 from work w
					 where w.museum_id=m.museum_id);
                     
#Q3. How many paintings have an asking price more than their regular price? 
select * 
from product_size
where sale_price > regular_price;

#Q4.Identify the paintings whose asking price is less than 50% of its regular price
select * 
from product_size
where sale_price < (regular_price)*0.5;

#Q.5 Which canva size costs the most?
select cs.label as canva, ps.sale_price
from (select *
  , rank() over(order by sale_price desc) as ranks
  from product_size) ps
join canvas_size cs
on cs.size_id = ps.size_id
where ps.ranks=1;					

#Q6. Delete duplicate records from work.
WITH ranked_works AS (
    SELECT work_id, 
           ROW_NUMBER() OVER (PARTITION BY work_id ORDER BY work_id) AS rn
    FROM work
)
DELETE w 
FROM work w
JOIN ranked_works rw ON w.work_id = rw.work_id
WHERE rw.rn > 1;

#Q7. Identify the museums with invalid city information in the given dataset
	select * from museum 
	where city regexp '^[0-9]';
    
#Q8. Museum_Hours table has 1 invalid entry. Identify it and remove it.
select count(*), day from museum_hours
group by day;

select * from museum_hours
where day = 'Thusday';

delete from museum_hours 
where day = 'Thusday';


#Q9 Fetch the top 10 most famous painting subject

select * from work;
select * from subject;


select * from
(select s.subject, count(1) as no_of_paintings,
rank() over(order by count(1) desc) as ranks 
from work as w
join subject as s
on s.work_id = w.work_id
group by s.subject) as rt
where rt.ranks <= 10;

#Q10. Identify the museums which are open on both Sunday and Monday. Display museum name, city.

select name, city
from museum as m
join (
select * 
from museum_hours as mh
where day = 'Sunday'
and exists (select 1 from museum_hours as mh1
              where mh1.museum_id = mh.museum_id
              and day = 'Monday')) as mht
on m.museum_id = mht.museum_id;

#Q11. How many museums are open every single day?

select count(1) 
from
(select museum_id, count(1)
		  from museum_hours
		  group by museum_id
		  having count(1) = 7) as x;
          
#Q12. Which are the top 5 most popular museum? 
#(Popularity is defined based on most no of paintings in a museum)

select m.name, x.c, x.ranks
from museum as m
join (select museum_id, count(*) as c,
      rank() over(order by count(*) desc) as ranks
       from work
       where museum_id is not null
       group by museum_id) as x
       on x.museum_id = m.museum_id
where x.ranks <= 5;

#Q13. Who are the top 5 most popular artist? 
#(Popularity is defined based on most no of paintings done by an artist)

select * from artist;
select * from work;

select a.full_name, x.c, x.ranks
from artist as a
join (select artist_id, count(*) as c,
      rank() over(order by count(*) desc) as ranks
       from work
       group by artist_id) as x
on x.artist_id = a.artist_id
       where x.ranks <=5;

#Q14.Display the 3 least popular canva sizes.

select * from canvas_size;
select * from product_size;

select cs.label as name, pst.size_id
from canvas_size as cs
join (select size_id, count(*) as c,
rank() over(order by count(*)) as ranks
from product_size as ps
group by size_id) as pst
on pst.size_id = cs.size_id
where pst.ranks <= 3;

