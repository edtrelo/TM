/* CREACIÓN DE LA ABT: Analytical Base Table

In database theory, the analytical base table (ABT) 
is a flat table that is used for building analytical models 
and scoring (predicting) the future behavior of a subject.

A single record in this table represents the subject of the 
prediction (e.g. a customer) and stores all data (variables) 
describing this subject. */

-- CREACIÓN TABLA: rated_movies 
-- Películas que tienen un averagerating en title.ratings
-- create table rated_movies as
select X.tconst, X.primarytitle, X.isadult, X.startyear as releaseyear,
X.runtimeminutes, X.genres, Y.averagerating, Y.numvotes
from title_ratings as Y
inner join title_basics as X
on Y.tconst = X.tconst
where titletype = 'movie';

select *
from rated_movies
order by releaseyear desc

-- CREACIÓN TABLA: rated_movies_wt_target
-- Películas con la variable target y cuatro nuevas variables más. 

/* usando un script de python, "rated_movies_wt_target.py", modificamos 
de la siguiente manera la tabla rated_movies:

1. seleccionamos uno de los géneros de "genres" de manera aletoria y
creamos la variable "maingenre" con él.

2. Contamos el número de géneros en "genres" de cada registro para
obtener la variable "cnt_genres".

3. Decimos que una película es de no-ficción si en su variable "genres"
se encuentra "Documentary", "Reality-TV", "Talk-Show", "Game-Show". 
Creamos la variable "isfiction" definiéndola como 0 si la películas es de
no-ficción y 1 en otro caso.

4. Definimos la variable "len_title" como la longuitud del caracter 
del "primaryTitle."

5. Según el lugar en alguno de los intervalos formados por 
Q_0, Q_0.25, Q_0.50, Q_0.75, Q_1 de numvotes, creamos la variable 
target siendo 1 si su averagerating está arriba del 75% y 0 en otro caso.

La tabla resultado de esta la llamamos rated_movies_wt_target. */

select *
from rated_movies_wt_target;
-- tiene las mismas 286416 entradas que rated_movies

-- Para la ABT no nos sirven ya averagerating, numvotes, genres.

/* CREACIÓN TABLA TEMP: pre_ABT_00
de la tabla rated_movies_wt_target, filtramos las columnas que 
no estén en función de otras.*/

-- 286,416 registros :)
create temp table pre_ABT_00 as
select tconst, target, maingenre, runtimeminutes, isadult, cnt_genres,
isfiction, len_title from
rated_movies_wt_target;

--- DIRECTORES --- 

/* CREACIÓN TABLA TEMP: directors_stats
Contiene datos agregados de las películas por director: 
número de películas realizadas, calificación promedio,
número total de votos a sus películas y las películas
que ha dirigido. Son 126,971 directores.
*/

create temp table directors_stats as
SELECT unnest(string_to_array(directors, ',')) as director, 
count(*) as numdirectedmovies, 
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_crew.tconst, ', ') as directedmovies
FROM title_crew INNER JOIN rated_movies
ON title_crew.tconst = rated_movies.tconst
GROUP BY director;

/* CREACIÓN TEMP TABLE: pop_directors:
los id del 0.1% directores más votados.
El 0.1% corresponde a 126*/
create temp table pop_directors as 
select director, primaryname, totalvotes
from directors_stats 
inner join name_basics
on director = nconst
order by totalvotes desc
limit 126;

/* CREACIÓN TEMP TABLE: top_directors:
los id del 0.1% directores con mejor calificación promedio.
El 0.1% corresponde a 126*/
create temp table top_directors as
select director, primaryname, averagerating
from directors_stats 
inner join name_basics
on director = nconst
order by averagerating desc
limit 126;


/*Películas dirigidas por los pop directors: 1746 distintas*/
create temp table movies_by_pop_dir as
SELECT DISTINCT(REPLACE(unnest(string_to_array(directedmovies, ',')), ' ', '')) as tconst
FROM directors_stats
inner join pop_directors
on directors_stats.director = pop_directors.director;

/*pelìculas dirigidas por directores top: 116*/
create temp table movies_by_top_dir as
SELECT DISTINCT(REPLACE(unnest(string_to_array(directedmovies, ',')), ' ', '')) as tconst
FROM directors_stats
inner join top_directors
on directors_stats.director = top_directors.director;

--- ESCRITORES --- 

/* CREACIÓN TABLA TEMP: writers_stats
Contiene datos agregados de las películas por escritor: 
número de películas realizadas, calificación promedio,
número total de votos a sus películas y las películas
que ha dirigido. Son 199,271 directores.
*/


create temp table writers_stats as
SELECT unnest(string_to_array(writers, ',')) as writer, 
count(*) as numdirectedmovies, 
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_crew.tconst, ', ') as writtenmovies
FROM title_crew INNER JOIN rated_movies
ON title_crew.tconst = rated_movies.tconst
GROUP BY writer;

/* CREACIÓN TEMP TABLE: pop_writers:
los id del 0.1% escritores más votados.
El 0.1% corresponde a 199*/
create temp table pop_writers as 
select writer, primaryname, totalvotes
from writers_stats 
inner join name_basics
on writer = nconst
order by totalvotes desc
limit 199;

/* CREACIÓN TEMP TABLE: top_writers:
los id del 0.1% escritores con mejor calificación promedio.
El 0.1% corresponde a 3232*/
create temp table top_writers as
select writer, primaryname, averagerating
from writers_stats 
inner join name_basics
on writer = nconst
order by averagerating desc
limit 199;


/*Películas escritas por los pop writers: 2451*/
create temp table movies_by_pop_wr as
SELECT DISTINCT(replace(unnest(string_to_array(writtenmovies, ',')), ' ', '')) as tconst
FROM writers_stats
inner join pop_writers
on writers_stats.writer = pop_writers.writer;

/*pelìculas escritas por escritores top: 157*/
create temp table movies_by_top_wr as
SELECT DISTINCT(REPLACE(unnest(string_to_array(writtenmovies, ',')), ' ', '')) as tconst
FROM writers_stats
inner join top_writers
on writers_stats.writer = top_writers.writer;


/* Creamos la siguiente iteración de la pre_ABT: indicamos si las pelis tienen top o pop 
directores o escritores */

create table pre_ABT_01 as
select *, case when tconst in (select tconst from movies_by_top_dir) then 1 else 0 end as "top_dir",
case when tconst in (select tconst from movies_by_pop_dir) then 1 else 0 end as "pop_dir",
case when tconst in (select tconst from movies_by_top_wr) then 1 else 0 end as "top_wr",
case when tconst in (select tconst from movies_by_pop_wr) then 1 else 0 end as "pop_wr"
from pre_ABT_00;

/*Películas escritas y dirigidas por los populares: 793 */
select *
from pre_ABT_01
inner join rated_movies
on pre_ABT_01.tconst = rated_movies.tconst
where pop_dir = 1
and pop_wr = 1;

-- de title_pricipals --
/*Obtenemos la info de title_principals para pelis calificas: 2555384 */
create table rated_title_principals as 
SELECT title_principals.*
FROM title_principals
inner join rated_movies
on title_principals.tconst = rated_movies.tconst;

select *
from rated_title_principals;

select category, count(category)
from rated_title_principals
group by category;

-- categorías que voy a revisar: productor, editor, compositor, actor, actriz, cinematografo

/* CREACIÓN TABLA TEMP: producers_stats
Contiene datos agregados de las películas por productor: 
número de películas realizadas, calificación promedio,
número total de votos a sus películas y las películas
que ha dirigido. Son 107,420 productores.
*/

create temp table producers_stats as
SELECT unnest(string_to_array(nconst, ',')) as producer, 
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_principals.tconst, ', ') as producedmovies
FROM title_principals INNER JOIN rated_movies
ON title_principals.tconst = rated_movies.tconst
WHERE category = 'producer'
GROUP BY producer;

select *
from producers_stats

/* CREACIÓN TEMP TABLE: pop_producers:
los id del 0.1% escritores más votados.
El 0.1% corresponde a 107*/
create temp table pop_producers as 
select producer, primaryname, totalvotes
from producers_stats 
inner join name_basics
on producer = nconst
order by totalvotes desc
limit 107;

/* CREACIÓN TEMP TABLE: top_producers:
los id del 0.1% escritores con mejor calificación promedio.
El 0.1% corresponde a 107*/
create temp table top_producers as
select producer, primaryname, averagerating
from producers_stats 
inner join name_basics
on producer = nconst
order by averagerating desc
limit 107;

/*Películas producidas por los pop_producers: 2179*/
create temp table movies_by_pop_prod as
SELECT DISTINCT(replace(unnest(string_to_array(producedmovies, ',')), ' ', '')) as tconst
FROM producers_stats
inner join pop_producers
on producers_stats.producer = pop_producers.producer;

/*pelìculas escritas por escritores top: 93*/
create temp table movies_by_top_prod as
SELECT DISTINCT(REPLACE(unnest(string_to_array(producedmovies, ',')), ' ', '')) as tconst
FROM producers_stats
inner join top_producers
on producers_stats.producer = top_producers.producer;

/*Tabla de editores. Son 43655 productores*/
create temp table editors as 
SELECT unnest(string_to_array(nconst, ',')) as editor, 
STRING_AGG(tconst, ', ') as editedmovies
FROM rated_title_principals
WHERE category = 'editor'
GROUP BY editor;

/* CREACIÓN TABLA TEMP: editors_stats
Son 43655 editores.
*/
create temp table editors_stats as 
SELECT unnest(string_to_array(nconst, ',')) as editor,
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_principals.tconst, ', ') as editedmovies
FROM title_principals INNER JOIN rated_movies
ON title_principals.tconst = rated_movies.tconst
WHERE category = 'editor'
GROUP BY editor;


/* CREACIÓN TEMP TABLE: pop_editors:
los id del 0.1% editores más votados.
El 0.1% corresponde a 43*/
create temp table pop_editor as 
select editor, primaryname, totalvotes
from editors_stats 
inner join name_basics
on editor = nconst
order by totalvotes desc
limit 43;

/* CREACIÓN TEMP TABLE: top_editor:
los id del 0.1% escritores con mejor calificación promedio.
El 0.1% corresponde a 43*/
create temp table top_editor as 
select editor, primaryname, totalvotes
from editors_stats 
inner join name_basics
on editor = nconst
order by averagerating desc
limit 43;

/*Películas editadas por los editores pop: 413*/
create temp table movies_by_pop_edt as
SELECT DISTINCT(replace(unnest(string_to_array(editedmovies, ',')), ' ', '')) as tconst
FROM editors_stats
inner join pop_editor
on editors_stats.editor = pop_editor.editor;

/*pelìculas editadas por los editores top: 36*/
create temp table movies_by_top_edt as
SELECT DISTINCT(replace(unnest(string_to_array(editedmovies, ',')), ' ', '')) as tconst
FROM editors_stats
inner join top_editor
on editors_stats.editor = top_editor.editor;

/*pre_ABT_02*/
create table pre_ABT_02 as
select *, case when tconst in (select tconst from movies_by_top_prod) then 1 else 0 end as "top_prod",
case when tconst in (select tconst from movies_by_pop_prod) then 1 else 0 end as "pop_prod",
case when tconst in (select tconst from movies_by_top_edt) then 1 else 0 end as "top_edt",
case when tconst in (select tconst from movies_by_pop_edt) then 1 else 0 end as "pop_edt"
from pre_ABT_01;

/*TEMP Tables de CINEMATOGRAPHERs y COMPOSERs*/


/* CREACIÓN TABLA TEMP: cinemat_stats
Son 57,802 productores.
*/

create temp table cinemat_stats as
SELECT unnest(string_to_array(nconst, ',')) as cinemat, 
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_principals.tconst, ', ') as filmography
FROM title_principals INNER JOIN rated_movies
ON title_principals.tconst = rated_movies.tconst
WHERE category = 'cinematographer'
GROUP BY cinemat;

select *
from cinemat_stats

/* CREACIÓN TEMP TABLE: pop_cinemats:
los id del 0.1% cinematografos más votados.
El 0.1% corresponde a 57*/
create temp table pop_cinemats as 
select cinemat, primaryname, totalvotes
from cinemat_stats 
inner join name_basics
on cinemat = nconst
order by totalvotes desc
limit 57;

/* CREACIÓN TEMP TABLE: top_cinemats:
los id del 0.1% cinematografros con mejor calificación promedio.
El 0.1% corresponde a 57*/
create temp table top_cinemats as
select cinemat, primaryname, averagerating
from cinemat_stats 
inner join name_basics
on cinemat = nconst
order by averagerating desc
limit 57;

/*Películas filmadas por los pop_cinemat: 1351*/
create temp table movies_by_pop_cinemat as
SELECT DISTINCT(replace(unnest(string_to_array(filmography, ',')), ' ', '')) as tconst
FROM cinemat_stats
inner join pop_cinemats
on cinemat_stats.cinemat = pop_cinemats.cinemat;

/*pelìculas filmadas por top_cinemat: 43*/
create temp table movies_by_top_cinemat as
SELECT DISTINCT(REPLACE(unnest(string_to_array(filmography, ',')), ' ', '')) as tconst
FROM cinemat_stats
inner join top_cinemats
on cinemat_stats.cinemat = top_cinemats.cinemat;

/* CREACIÓN TABLA TEMP: composer_stats
Son 67344 editores.
*/
create temp table composers_stats as 
SELECT unnest(string_to_array(nconst, ',')) as composer,
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_principals.tconst, ', ') as filmography
FROM title_principals INNER JOIN rated_movies
ON title_principals.tconst = rated_movies.tconst
WHERE category = 'composer'
GROUP BY composer;


/* CREACIÓN TEMP TABLE: pop_composer:
los id del 0.1% compositores más votados.
El 0.1% corresponde a 67*/
create temp table pop_composer as 
select composer, primaryname, totalvotes
from composers_stats 
inner join name_basics
on composer = nconst
order by totalvotes desc
limit 67;

/* CREACIÓN TEMP TABLE: top_composer:
los id del 0.1% compositores con mejor calificación promedio.
El 0.1% corresponde 67*/
create temp table top_composer as 
select composer, primaryname, totalvotes
from composers_stats 
inner join name_basics
on composer = nconst
order by averagerating desc
limit 67;

/*Películas con composiciones por los composers pop: 3378*/
create temp table movies_by_pop_comp as
SELECT DISTINCT(replace(unnest(string_to_array(filmography, ',')), ' ', '')) as tconst
FROM composers_stats
inner join pop_composer
on composers_stats.composer = pop_composer.composer;

/*pelìculas editadas por los editores top: 57*/
create temp table movies_by_top_comp as
SELECT DISTINCT(replace(unnest(string_to_array(filmography, ',')), ' ', '')) as tconst
FROM composers_stats
inner join top_composer
on composers_stats.composer = top_composer.composer;

/*pre_ABT_03*/
create table pre_ABT_03 as
select *, case when tconst in (select tconst from movies_by_top_cinemat) then 1 else 0 end as "top_cinemat",
case when tconst in (select tconst from movies_by_pop_cinemat) then 1 else 0 end as "pop_cinemat",
case when tconst in (select tconst from movies_by_top_comp) then 1 else 0 end as "top_comp",
case when tconst in (select tconst from movies_by_pop_comp) then 1 else 0 end as "pop_comp"
from pre_ABT_02;

-- Checamos el número de top/pop actors y actress

/* CREACIÓN TABLA TEMP: stars_stats
Estadísticas de actrices y actores
Son 403251 actrices o actores.*/
create temp table stars_stats as 
SELECT unnest(string_to_array(nconst, ',')) as star,
avg(averagerating) as averagerating,
sum(numvotes) as totalvotes,
STRING_AGG(title_principals.tconst, ', ') as movies
FROM title_principals INNER JOIN rated_movies
ON title_principals.tconst = rated_movies.tconst
WHERE category = 'actor' or category = 'actress'
GROUP BY star;


/* CREACIÓN TEMP TABLE: pop_stars:
los id del 0.1% de actores/actrices más votados.
El 0.1% corresponde a 403*/
create temp table pop_stars as 
select star, primaryname, totalvotes
from stars_stats 
inner join name_basics
on star = nconst
order by totalvotes desc
limit 403;


/*Películas con actrices/actores populares: 10027
Contamos el número de actores/actrices populares por película*/
create temp table movies_by_pop_stars as
SELECT DISTINCT(replace(unnest(string_to_array(movies, ',')), ' ', '')) as tconst,
count(movies) as no_pop_stars
FROM stars_stats
inner join pop_stars
on stars_stats.star = pop_stars.star
group by tconst;

create table pre_ABT_04 as
select pre_ABT_03.*, COALESCE(movies_by_pop_stars.no_pop_stars, 0) as pop_stars
from pre_ABT_03 left join movies_by_pop_stars
on pre_ABT_03.tconst = movies_by_pop_stars.tconst

/* CREACIÓN TEMP TABLE: top_stars:
los id del 0.1% de actirces/actores con mejor calificación promedio.
El 0.1% corresponde 403*/
create temp table top_stars as 
select star, primaryname, totalvotes
from stars_stats 
inner join name_basics
on star = nconst
order by averagerating desc
limit 403;

/*pelìculas editadas por los editores top: 132*/
create temp table movies_by_top_stars as
SELECT DISTINCT(replace(unnest(string_to_array(movies, ',')), ' ', '')) as tconst,
count(movies) as no_top_stars
FROM stars_stats
inner join top_stars
on stars_stats.star = top_stars.star
group by tconst;

create table pre_ABT_05 as
select pre_ABT_04.*, COALESCE(movies_by_top_stars.no_top_stars, 0) as top_stars
from pre_ABT_04 left join movies_by_top_stars
on pre_ABT_04.tconst = movies_by_top_stars.tconst

/*COLUMNAS EN FUNCIÓN DE TITLE_AKAS*/
create temp table rated_akas as
select *
from title_akas
inner join rated_movies
on titleid = tconst;

-- hacemos un conteo de títulos, conteo de regiones, conteo de langs, conteo de títulos
-- son 285840 registros. Son menos registros que en las abt's
create temp table conteos_akas as
select titleid, 
count(region) as cnt_region, 
count(lang) as cnt_lang, 
count(title) as cnt_title
from rated_akas
group by titleid;

/*Unimos los conteos de title akas a la pre abt.
Hay 576 registros cuyos conteos de akas son nulls.*/
create table pre_ABT_06 as
select pre_ABT_05.*, cnt_region, cnt_lang, cnt_title
from pre_ABT_05 left join conteos_akas
on tconst = titleid;

-- Para la creación de las columnas de crews, usé el código de Rodrigo.
-- principal crew ya lo construí allá arriba.
---CREWS---
select distinct prof as tot from (
select *, unnest(string_to_array(primaryProfession, ',')) as prof from name_basics) as foo;
--No usaremos todas las diferentes categorías, solo las siguiente:
--animation_department, art_department, assistant_director,
--camera_department, costume_department, editorial_department, 
-- make_up_department, miscellaneous, music_department, production_manager, 
-- sound_department, soundtrack, visual_effects
create temp table tmp0 as 
select nconst, split_part(primaryProfession,',', 1) as profession, 
unnest(string_to_array(knownForTitles,',')) as tconst from name_basics;

create temp table tmp1 as 
select * from tmp0 where tconst in (select tconst from rated_movies);

create temp table tmp_animation_department as select  tconst, count(*) as cnt_animation_department from tmp1 where "profession" = 'animation_department' group by 1 order by 1;
create temp table tmp_art_department as select  tconst, count(*) as cnt_art_department from tmp1 where "profession" = 'art_department' group by 1 order by 1;
create temp table tmp_assistant_director as select  tconst, count(*) as cnt_assistant_director from tmp1 where "profession" = 'assistant_director' group by 1 order by 1;
create temp table tmp_camera_department as select  tconst, count(*) as cnt_camera_department from tmp1 where "profession" = 'camera_department' group by 1 order by 1;
create temp table tmp_costume_department as select  tconst, count(*) as cnt_costume_department from tmp1 where "profession" = 'costume_department' group by 1 order by 1;
create temp table tmp_editorial_department as select  tconst, count(*) as cnt_editorial_department from tmp1 where "profession" = 'editorial_department' group by 1 order by 1;
create temp table tmp_make_up_department as select  tconst, count(*) as cnt_make_up_department from tmp1 where "profession" = 'make_up_department' group by 1 order by 1;
create temp table tmp_miscellaneous as select  tconst, count(*) as cnt_miscellaneous from tmp1 where "profession" = 'miscellaneous' group by 1 order by 1;
create temp table tmp_music_department as select  tconst, count(*) as cnt_music_department from tmp1 where "profession" = 'music_department' group by 1 order by 1;
create temp table tmp_production_manager as select  tconst, count(*) as cnt_production_manager from tmp1 where "profession" = 'production_manager' group by 1 order by 1;
create temp table tmp_sound_department as select  tconst, count(*) as cnt_sound_department from tmp1 where "profession" = 'sound_department' group by 1 order by 1;
create temp table tmp_soundtrack as select  tconst, count(*) as cnt_soundtrack from tmp1 where "profession" = 'soundtrack' group by 1 order by 1;
create temp table tmp_visual_effects as select  tconst, count(*) as cnt_visual_effects from tmp1 where "profession" = 'visual_effects' group by 1 order by 1;

create temp table cnt_crew as
select x1.tconst, x6.cnt_animation_department, x7.cnt_art_department,
x8.cnt_assistant_director, x9.cnt_camera_department, 
x12.cnt_costume_department, x14.cnt_editorial_department, 
x15.cnt_make_up_department, x16.cnt_miscellaneous, x17.cnt_music_department, 
x19.cnt_production_manager, x20.cnt_sound_department, x21.cnt_soundtrack, 
x22.cnt_visual_effects 
from rated_movies as x1 
left join tmp_animation_department as x6 on x1.tconst=x6.tconst
left join tmp_art_department as x7 on x1.tconst=x7.tconst
left join tmp_assistant_director as x8 on x1.tconst=x8.tconst
left join tmp_camera_department as x9 on x1.tconst=x9.tconst
left join tmp_costume_department as x12 on x1.tconst=x12.tconst
left join tmp_editorial_department as x14 on x1.tconst=x14.tconst
left join tmp_make_up_department as x15 on x1.tconst=x15.tconst
left join tmp_miscellaneous as x16 on x1.tconst=x16.tconst
left join tmp_music_department as x17 on x1.tconst=x17.tconst
left join tmp_production_manager as x19 on x1.tconst=x19.tconst
left join tmp_sound_department as x20 on x1.tconst=x20.tconst
left join tmp_soundtrack as x21 on x1.tconst=x21.tconst
left join tmp_visual_effects as x22 on x1.tconst=x22.tconst;

create temp table refined_cnt_crew as select *,
case when cnt_animation_department is NULL then 0 else 1 end as v5,
case when cnt_art_department is NULL then 0 else 1 end as v6,
case when cnt_assistant_director is NULL then 0 else 1 end as v7,
case when cnt_camera_department is NULL then 0 else 1 end as v8,
case when cnt_costume_department is NULL then 0 else 1 end as v11,
case when cnt_editorial_department is NULL then 0 else 1 end as v13,
case when cnt_make_up_department is NULL then 0 else 1 end as v14,
case when cnt_miscellaneous is NULL then 0 else 1 end as v15,
case when cnt_music_department is NULL then 0 else 1 end as v16,
case when cnt_production_manager is NULL then 0 else 1 end as v18,
case when cnt_sound_department is NULL then 0 else 1 end as v19,
case when cnt_soundtrack is NULL then 0 else 1 end as v20,
case when cnt_visual_effects is NULL then 0 else 1 end as v21
from cnt_crew;

create temp table crews as
select tconst,
concat(v5,v6,v8,v11,v13,v14,v16,v19) as departments,
concat(v7,v15,v18,v20,v21) as otherCrew
from refined_cnt_crew;

drop table cnt_crew;
drop table refined_cnt_crew;

select *
from crews

-- juntamos lo obtenido con la pre_ABT anterior
create table pre_ABT_07 as
select pre_ABT_06.*, crews.departments, crews.otherCrew as othercrew
from pre_ABT_06 left join crews
on pre_ABT_06.tconst = crews.tconst;

select * from pre_ABT_07 ;

-- Faltaría agregar los códigos de continentes.

