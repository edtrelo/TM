import pandas as pd
import psycopg2
import random
import numpy as np
from sqlalchemy import create_engine

random.seed(1234) # establecemos una seed para reproductibilidad.
# credenciales de ingreso para conexiones con postgres.
credentials = {'dbname':'imdb', 'password':'1234', 'user':'postgres'}
# iniciamos la conexión.
conn = psycopg2.connect(**credentials)
# creamos el cursos para ejecutar queries.
cursor = conn.cursor()
# queremos todos los registros de "rated_movies".
query  = 'SELECT * FROM rated_movies;' 
cursor.execute(query=query)
# obtenemos todos los registros obtenidos.
tuples_list = cursor.fetchall()
# obtenemos el header de la tabla.
headers = [i[0] for i in cursor.description]
# cerramos el cursor.
cursor.close()
# creamos un dataframe con el resultado del querie.
rated_movies = pd.DataFrame(tuples_list, columns=headers)
conn.close()

# ------------------- 1. "maingenre" ------------------------------ #

def chooseGenre(x):
    """
    Elige uno de los elementos de una lista x de strings separados por comas.

    Args:
        x: string or None"""
    # hay registros con nulos.
    if x is None:
        return x # que estos sigan nulos.
    else:
        # elegimos al azar uno de los valores de la lista que resulta
        # de separar x por comas.
        return random.choice(x.split(','))
    
# cremos la variable "maingenre" en función de "genres."
rated_movies['maingenre'] = rated_movies['genres'].apply(chooseGenre)

# ------------------- 2. "cnt_genre" ------------------------------ #

def cnt_genre(x):
    """
    Obtiene el número de elementos de la lista de strings x.

    Args:
        x: string or None."""
    if x is None: # hay registros nulos.
        return x # los dejamos nulos.
    else:
        return len(x.split(','))
    
# creamos la variable "cnt_genres" en función de "genres".
rated_movies['cnt_genres'] = rated_movies['genres'].apply(cnt_genre)

# ------------------- 3. "isfiction" ------------------------------ #

# géenros de no-ficción (deberían no tener guión pues)
nonfictiongenres = ["Documentary", "Reality-TV", "Talk-Show", "Game-Show"]

def isfiction(genres):
    """Dado el string genres, revisa si alguno de los géneros en 'nonfinctiongenres'
    se encuentran listados en él."""
    if genres is None:
        return genres
    else:
        listgenres = genres.split(',')
        for nf_genre in nonfictiongenres: # checamos si alguno de los géneros no-ficción
            # ... se encuentra listado en genres.
            if nf_genre in listgenres: # regresamos 0 si es así:
                # ... la película es de no-ficción.
                return 0
        return 1

# creamos la variable "is_fiction" en función de "genres".
rated_movies['isfiction'] = rated_movies['genres'].apply(isfiction)

# ------------------- 5. "len_title" ------------------------------ #
rated_movies['len_title'] = rated_movies['primarytitle'].apply(lambda x: len(x))

# ------------------- 5. "target" ------------------------------ #

# calculamos los Q0, Q25, Q50, Q75, Q100 de laa distribución de número de votos
nV = rated_movies['numvotes'] # ponemos un alías para la columnas "numVotes."
Q0 = nV.min()
Q25 = nV.quantile(0.25)
Q50 = nV.quantile(0.50)
Q75 = nV.quantile(0.75)
Q100 = nV.max()
# Los guardamos en una lista para poder iterar.
Q = [Q0, Q25, Q50, Q75, Q100]
# creamos un array donde vamos a guardar el 0.75 percentil de la distribución
# averagerating correspondiente al grupo de numVotes.
quantilesratings = np.zeros(len(Q)-1)
# definimos los grupos como G_i-> numVotes in [Q[i], Q[i+1])
for i in range(len(Q) - 1):
    filtro = rated_movies['numvotes'].between(Q[i], Q[i+1], inclusive='left')
    # obtenemos el cuantil 0.75 de la distribución obtenida al filtrar.
    quantilesratings[i] = rated_movies[filtro]['averagerating'].quantile(0.75)

def f(numVotes):
    """Regresa el índice de la distribución de ratings generada por el grupo 
    de votos al que pertence numVotes."""
    for i in range(len(Q) - 1):
        if Q[i] <= numVotes < Q[i+1]:
            return i
        
    return len(Q) - 2 # caso para cuando numVotes sea el máximo

def target(averageRating, numVotes):
    i = f(numVotes)

    q75 = quantilesratings[i]

    if averageRating >= q75:
        return 1
    else:
        return 0
    
rated_movies['target'] = rated_movies.apply(lambda x: target(x.averagerating, x.numvotes), axis = 1)

# -------------------------------- fin -----------------------------------#
# creamos un engine para poder cargar la tabla nueva a la base de datos.
engine = create_engine('postgresql+psycopg2://postgres:1234@localhost:5432/imdb')
# escribimos la tabla nueva en la base de datos. Remplazar si es que ya existe.
rated_movies.to_sql('rated_movies_wt_target', engine, index=False, if_exists='replace')

