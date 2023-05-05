import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from scipy import stats

rated_movies = pd.read_csv("Filtered Tables/rated_principals.csv")

# -------------------- Categorías ----------------------- #
main_cats = ['actor', 'actress', 'director', 'writer', 'producer', 
             "cinematographer", 'editor', 'composer']

otros = lambda x: x if x in main_cats else 'otros'

categorías = rated_movies['category'].apply(otros)

u_cats, cnt_cats = np.unique(categorías, return_counts=True)

fig, ax = plt.subplots(figsize=(21, 8))

ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.bar(u_cats, cnt_cats)

ax.set_ylabel('Frencuencia\n', fontsize = 18)
ax.set_xlabel('\nCategorías', fontsize = 18)

plt.xticks(fontsize=16)

plt.show()