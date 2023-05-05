import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sn
from scipy import stats

df = pd.read_csv('ABT Construction/ABT.csv', dtype = {'departments':str, 'othercrew':str})

# ---------------------------------------------------- #
# Matriz de Correlación
fig, ax = plt.subplots(figsize = (10, 20))
corr_matrix = df.corr(numeric_only=True)
sn.heatmap(corr_matrix, ax=ax)
fig.subplots_adjust(bottom=0.2)
#plt.show()

# ---------------------------------------------------- #
# scatter plots en función de cnt_titles
fig, ax = plt.subplots()
subdf = df[df[['cnt_title', 'cnt_region', 'cnt_lang']].notnull().all(1)]

titles = subdf['cnt_title']
region = subdf['cnt_region']
lang = subdf['cnt_lang']

ax.scatter(titles, region, label = 'cnt_region')
ax.scatter(titles, lang, label = 'cnt_lang')
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

ax.set_xlabel('cnt_title', fontsize = 16)
ax.set_ylabel('conteos', fontsize = 16)
plt.xticks(fontsize=16)
plt.yticks(fontsize=16)
fig.subplots_adjust(bottom=0.15, left=0.15)
plt.legend()
plt.show()

print(stats.pearsonr(titles, region))
print(stats.pearsonr(titles, lang))