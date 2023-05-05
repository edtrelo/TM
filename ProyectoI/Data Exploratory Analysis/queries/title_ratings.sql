-- EDA: title_ratings
select *
from title_ratings

-- Número de títulos calificados: 1,274,334
select count(*)
from title_ratings

-- Número de nulos de averagerating: 0
select count(*)
from title_ratings
where averagerating is null

-- Número de nulos de numvotes: 0
select count(*)
from title_ratings
where numvotes is null

-- Creamos una tabla temporal 
-- películas con calificación
create temp table rated_movies as
select title_basics.*, title_ratings.averagerating, title_ratings.numvotes
from title_ratings
inner join title_basics
on title_ratings.tconst = title_basics.tconst
where titletype = 'movie'

-- Número de películas calificadas: 286416
select *
from rated_movies
