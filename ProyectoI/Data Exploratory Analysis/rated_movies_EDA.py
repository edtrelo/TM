import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from scipy import stats

rated_movies = pd.read_csv("Filtered Tables/rated_movies.csv", parse_dates=['releaseyear'])

# categorías numéricas:
rtm = rated_movies['runtimeminutes']
avgrating = rated_movies['averagerating']
numvotes = rated_movies['numvotes']

# ---------------------------------------------------------------- #
# I. Histogramas y Boxplots de Categorías Numéricas 

# creamos arrays para iterar en el plot
columnas = [rtm.dropna(), numvotes, avgrating]
nombresColumnas = ['log10 de runtimeMinutes', 
                   'log10 de numVotes',
                   'averageRating']
# funciones que vamos a aplicar a los datos
funciones = [np.log10, np.log10, lambda x: x]
# creamos la función con 2x3=6 axis
# los axis de arriba (para los boxplot) tendrán en
# 20% del área de la figura.
fig, ax = plt.subplots(
    2, 3, figsize=(10, 4),
    gridspec_kw={"height_ratios": [.2, .8]} 
)
for i in range(len(columnas)):
    # el boxplot horizontal
    f = funciones[i]
    datos = f(columnas[i]) # función i aplicada a los datos i
    ax[0, i].boxplot(datos, vert=False)
    ax[1, i].hist(datos, rwidth = 0.8)
    # removemos los bordes del histograma
    ax[1, i].spines['top'].set_visible(False)
    ax[1, i].spines['right'].set_visible(False)
    ax[1, i].spines['left'].set_visible(False)
    # quitamos los y ticks
    ax[1, i].tick_params(left = False, labelleft = False)
     # el boxplot sin spines
    ax[0, i].axis('off')
    # x label es el nombre de la categoría
    ax[1, i].set_xlabel(nombresColumnas[i], fontsize = 14)

plt.tight_layout()
# plt.show()

# ---------------------------------------------------------------- #
# II. Medidas de Tendencia Central 

# media, std, min, max, Q1, Q2, Q3
descr = rated_movies[['runtimeminutes', 'numvotes', 'averagerating']].describe()
# print(descr)

# modas
moda_rtm = stats.mode(rtm.dropna(), keepdims = True)
# print('moda de runtimeMinutes: ', moda_rtm)
moda_nV = stats.mode(numvotes, keepdims = True)
# print('moda de numVotes: ', moda_nV)
moda_aR = stats.mode(avgrating, keepdims = True)
# print('moda de averageRating: ', moda_aR)

# kurtosis
kurtosis = rated_movies[['runtimeminutes', 'numvotes', 'averagerating']].kurtosis()
# print(kurtosis)

# ---------------------------------------------------------------- #
# averageRating en función de numVotes

media_numV = 3.583880e+03
q1, q2, q3 = 19, 60, 309

Q1 = rated_movies[rated_movies['numvotes'] <= q1]
Q2 = rated_movies[(q1 < rated_movies['numvotes']) & (rated_movies['numvotes'] <= q2)]
Q3 = rated_movies[(q2 < rated_movies['numvotes']) & (rated_movies['numvotes'] <= q3)]
rest = rated_movies[q3 < rated_movies['numvotes'] ]

data = [Q1['averagerating'], Q2['averagerating'], 
        Q3['averagerating'], rest['averagerating']]

# boxplots según el número de votos
fig, ax = plt.subplots(figsize=(10, 4))

# el boxplot 
ax.boxplot(data)
ax.set_xticklabels([r'numVotes  $\leq Q_1$', r'$Q_1 <$ numVotes $\leq Q_2$', 
                    r'$Q_2 <$ numVotes $\leq Q_3$', r'$Q_3 <$ numVotes'])
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.set_ylabel('averagerating', fontsize = 14)

#plt.show()

# ---------------------------------------------------------------- #
# Películas y calificaión media por año
byyear = rated_movies.groupby('releaseyear').size()
avgbyyear = rated_movies.groupby('releaseyear')['averagerating'].mean()

fig, ax = plt.subplots(figsize=(14, 6))
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.plot(byyear, linewidth=3, color = 'b')

ax.set_ylabel('Número de Películas Estrenadas\n', fontsize = 20, color = 'b')
plt.xticks(fontsize=18)
plt.yticks(fontsize=18, color = 'b')

ax2 = ax.twinx()
ax2.plot(avgbyyear, linewidth=3, color = 'g')
ax2.set_ylabel('\nCalificación Promedio', fontsize = 20, color = 'g')

plt.xticks(fontsize=18)
plt.yticks(fontsize=18, color = 'g')
ax2.spines['top'].set_visible(False)

plt.show()


# ---------------------------------------------------------------- #
# Duración de Películas por Año

avgrtmyear = rated_movies.groupby('releaseyear')['runtimeminutes'].mean()

fig, ax = plt.subplots(figsize=(14, 6))
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.plot(avgrtmyear, linewidth=3)

ax.set_ylabel('Duración Promedio (min.)\n', fontsize = 20)
plt.xticks(fontsize=18)
plt.yticks(fontsize=18, color = 'b')

plt.show()
