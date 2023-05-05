-- EDA: name.basics
select *
from name_basics

-- número de personas registradas: 12,287,610
select count(*)
from name_basics

-- número de nombres distintos: 9,542,558
select count(distinct(primaryname))
from name_basics

-- persona más vieja (con vida) registrada
select primaryname, birthyear
from name_basics
where deathyear is null
and birthyear is not null
order by birthyear asc

-- profesiones de primaryProfessions: top 5-> actor, acrtiz, miscellaneous, 
-- producer, writer, 
select profession, count(*) as conteo
from name_basics
CROSS JOIN LATERAL unnest(string_to_array(primaryprofession, ',')) as profession
group by profession
order by conteo desc

-- número de películas por las que una persona es conocida.
-- 2: 1217738
-- 3: 1222225
-- 0: 2660854
-- 1: 7186793
select cardinality(string_to_array(primaryprofession, ',')) as numpelis, 
count(*) as conteo
from name_basics
group by numpelis
order by conteo asc

