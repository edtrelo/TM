-- EDA: title.crew
-- crew de todos los títulos
select count(*)
from title_crew

-- crew de películas 
create temp table rated_crew as
select rated_movies.*, title_crew.directors, title_crew.writers
from title_crew
inner join rated_movies
on title_crew.tconst = rated_movies.tconst

-- número de registros para películas
select count(*)
from rated_crew

-- directores (disintos!)de rated_movies
create temp table rated_movies_directors as
select distinct(director)
from rated_crew
CROSS JOIN LATERAL unnest(string_to_array(directors, ',')) as director

-- Número de directores (distintos!) en pelis de rated_movies
select count(*)
from rated_movies_directors

-- escritores (distintos!)de rated_movies
create temp table rated_movies_writers as
select distinct(writer)
from rated_crew
CROSS JOIN LATERAL unnest(string_to_array(writers, ',')) as writer

-- Número de escritores (distintos!) en pelis de rated_movies
select count(*)
from rated_movies_writers

-- directores y escritores (at least once)
select director as director_and_writer
from rated_movies_directors
inner join rated_movies_writers
on director = writer


