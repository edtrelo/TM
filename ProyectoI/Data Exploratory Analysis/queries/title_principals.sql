-- EDA: title.principals --

-- Obtenemos los registros para películas rankeadas.
create temp table rated_principals as
select title_principals.*
from rated_movies inner join title_principals
on rated_movies.tconst = title_principals.tconst;

select *
from rated_principals;

-- Número de películas registradas: 285,766
select distinct(tconst), count(*)
from rated_principals
group by tconst;

-- Número de personas registradas: 907442
select distinct(nconst), count(*)
from rated_principals
group by nconst;

-- Categorías 
select category, count(*)
from rated_principals
group by category