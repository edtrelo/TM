import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats
df = pd.read_csv('ABT Construction/ABT.csv', dtype = {'departments':str, 'othercrew':str})

bytarget = [df[df['target'] == 1]['runtimeminutes'].dropna(), 
            df[df['target'] == 0]['runtimeminutes'].dropna()]

byfiction = [df[df['isfiction'] == 1]['runtimeminutes'].dropna(), 
            df[df['isfiction'] == 0]['runtimeminutes'].dropna()]

byadult = [df[df['isadult'] == 1]['runtimeminutes'].dropna(), 
            df[df['isadult'] == 0]['runtimeminutes'].dropna()]

# ---------- Boxplot ------------------------- #

all = bytarget
all.extend(byfiction)
all.extend(byadult)

fig, ax = plt.subplots()

bp = ax.boxplot(all, labels = ['Buena Peli', 'No Buena Peli', 'Ficción', 'No Ficción',
                          'Para Adultos', 'No Para Adultos'], showfliers=False, patch_artist=True)

colors = ['pink', 'pink', 'b', 'b', 'g', 'g']

for i,patch in enumerate(bp['boxes']):
        patch.set(facecolor=colors[i])    

ax.legend([bp["boxes"][0], bp["boxes"][2], bp["boxes"][4]], ['target', 'isfiction', 'isadult'])
ax.set_ylabel('runtimeminutes', fontsize = 16)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)

#plt.show()

# ----------------- pruebas Mann-Whitney----------------------- #
# target
print(stats.mannwhitneyu(bytarget[0], bytarget[1]))
# fiction
print(stats.mannwhitneyu(byfiction[0], byfiction[1]))
# adult
print(stats.mannwhitneyu(byadult[0], byadult[1]))