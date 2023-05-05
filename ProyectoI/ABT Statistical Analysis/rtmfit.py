import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats
df = pd.read_csv('ABT Construction/ABT.csv', dtype = {'departments':str, 'othercrew':str})

rtm = df['runtimeminutes'] # la única variable que podemos considerar continua

# -------------------- Distibución sin Outliers ------------------- #
Q1 = rtm.quantile(0.25)
Q3 = rtm.quantile(0.75)
IQR = Q3 - Q1
rtm = rtm[rtm.between(Q1-1.5*IQR, Q3 + 1.5*IQR)]
# --------------------- Histograma -------------------------------- #
fig, ax = plt.subplots()
ax.hist(np.log(rtm), density=True)
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.set_xlabel('runtime minutes', fontsize = 16)
plt.show()
# ---------------------- Normalidad -------------------- #
dist = stats.norm
fit = dist.fit(rtm)
print('Normal')
print(stats.kstest(rtm, cdf = dist.cdf, args = (*fit,)))
# ---------------------- T-Student -------------------- #
dist = stats.t
fit = dist.fit(rtm)
# print(dist)
# print(stats.kstest(rtm, cdf = dist.cdf, args = (*fit,)))
# ---------------------- Cauchy -------------------- #
dist = stats.cauchy
fit = dist.fit(rtm)
print('Cuachy')
# print(stats.kstest(rtm, cdf = dist.cdf, args = (*fit,)))
# ---------------------- Log Normal ------------------ #
dist = stats.norm
fit = dist.fit(np.log(rtm))
print('Log-Normal')
print(stats.kstest(np.log(rtm), cdf = dist.cdf, args = (*fit,)))

# ------------------- Ajuste a la Log(rtm) ----------- #
# ----------------- exponnorm ----------------------- #
dist = stats.exponnorm
fit = dist.fit(np.log(rtm))
print('Exponnorm a log(runtimeminutes)')
print(stats.kstest(np.log(rtm), cdf = dist.cdf, args = (*fit,)))
# ----------------- Gamma----------------------- #
dist = stats.gamma
fit = dist.fit(np.log(rtm))
print('Gamma a log(runtimeminutes)')
print(stats.kstest(np.log(rtm), cdf = dist.cdf, args = (*fit,)))