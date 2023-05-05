-- EDA: title_basics

-- Tipos de títulos
select distinct(titletype)
from title_basics;

-- Número de Películas: 634,122
select count(*)
from title_basics
where titletype = 'movie'

-- Número de Películas distintas: 634,122
select count(distinct(tconst))
from title_basics
where titletype = 'movie'

-- primaryTitle = originalTitle: 555,150
select *
from title_basics
where primaryTitle = originalTitle
and titletype = 'movie'

-- ¿Cuántas películas son para adultos?: 9561
select *
from title_basics
where isadult = '1'
and titletype = 'movie'

-- Año de la primer película 
select startyear
from title_basics
where titletype = 'movie'
order by startyear desc

-- startYear not null: 546,081
select startyear
from title_basics
where titletype = 'movie'
and startyear is not Null
order by startyear desc

-- Cuántas películas hay de 2023 hacia adelante: 4,238
-- Último año registrado: 2029
select startyear
from title_basics
where titletype = 'movie'
and startyear is not Null
and startyear > 2022
order by startyear desc

-- Año en que se hicieron más películas: 2022, 2018, 2017
select startyear, count(*) as conteo
from title_basics
where titletype = 'movie'
and startyear is not Null
group by startyear
order by conteo desc 
limit 3

-- Runtimeminuts sin null: 400,370
select count(*)
from title_basics
where titletype = 'movie'
and runtimeminutes is not Null

-- película de mayor duración: 100, 59,460 minutos
select primarytitle, runtimeminutes
from title_basics
where titletype = 'movie'
and runtimeminutes is not Null
order by runtimeminutes desc
limit 1

-- película de menor duración: "Nikkatsu on Parade", 1 minuto
select primarytitle, runtimeminutes
from title_basics
where titletype = 'movie'
and runtimeminutes is not Null
order by runtimeminutes asc
limit 1

-- Géneros Distintos y conteos:
-- top3: Drama, documentary, comedy
select genre, count(*) as conteo
from title_basics
CROSS JOIN LATERAL unnest(string_to_array(genres, ',')) as genre
where titletype = 'movie'
group by genre
order by conteo desc
