# importing libraries

import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure


matplotlib.rcParams['figure.figsize'] = (12,8) #adjusting plot config

# data reading
df = pd.read_csv(r'E:\Data Analyst Project\python\movies.csv')

df.head()

df.dtypes

#scatter plot budjet vs gross

plt.scatter(x=df['budget'], y=df['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Budget')
plt.ylabel('Gross Earnings')
plt.show()

#regression plot using seaborn

sns.regplot(x='budget', y='gross', data=df,scatter_kws={"color":"red"}, line_kws={"color":"blue"})

#

df.corr()