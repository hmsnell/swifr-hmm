from sklearn.metrics import precision_recall_curve
import sys
import pandas as pd
import matplotlib
matplotlib.use('Agg')
from matplotlib import pyplot as plt
import os

neutral_1 = sys.argv[1] # file with rows corresponding to neutral sites in N=300
sweep_1 = sys.argv[2] # file with rows corresponding to sweep sites in N=300
#titsce = sys.argv[3] # title of plot: scenario
#titgen = sys.argv[4] # title of plot: generation
#cond = sys.argv[5] # title of plot: condition
#sel = sys.argv[6] # title of plot: selection coefficient
output_folder = sys.argv[3] # where to save the output. 

#titgen=int(gen)*10

df_N1 = pd.read_csv(neutral_1, sep='\t')
df_S1 = pd.read_csv(sweep_1, sep='\t')

y_true1 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
y_score1 = df_N1['P(sweep)'].tolist() + df_S1['P(sweep)'].tolist()

y_true2 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
y_score2 = df_N1['XP-EHH'].tolist() + df_S1['XP-EHH'].tolist()

#y_true3 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
#y_score3 = df_N1['DDAF'].tolist() + df_S1['DDAF'].tolist()

y_true4 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
y_score4 = df_N1['nSL'].tolist() + df_S1['nSL'].tolist()

y_true5 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
y_score5 = df_N1['iHS'].tolist() + df_S1['iHS'].tolist()

#y_true6 = [0 for i in range(len(df_N1))] + [1 for i in range(len(df_S1))]
#y_score6 = df_N1['FST'].tolist() + df_S1['FST'].tolist()

precision1, recall1, thresholds1 = precision_recall_curve(y_true1, y_score1)
precision2, recall2, thresholds2 = precision_recall_curve(y_true2, y_score2)
#precision3, recall3, thresholds3 = precision_recall_curve(y_true3, y_score3)
precision4, recall4, thresholds4 = precision_recall_curve(y_true4, y_score4)
precision5, recall5, thresholds5 = precision_recall_curve(y_true5, y_score5)
#precision6, recall6, thresholds6 = precision_recall_curve(y_true6, y_score6)


plt.plot(precision1, recall1, c='black', label='SWIFr')
plt.plot(precision2, recall2, c='blue', label='XP-EHH')
#plt.plot(precision3, recall3, c='indigo', label='DDAF')
plt.plot(precision4, recall4, c='lime', label='nSL')
plt.plot(precision5, recall5, c='darkgreen', label='iHS')
#plt.plot(precision6, recall6, c='red', label='FST')

plt.xlabel('Recall')
plt.ylabel('Precision')
plt.xlim(0, 1.0)
plt.ylim(0, 1.0)
plt.legend(['SWIFr', 'XP-EHH', 'nSL', 'iHS'])
plt.title('Precision Recall Curve for Neutral vs. Sweep - 5000kya selection coefficient 0.0376') # {}, {}, selcoeff {}, {} generations after ben. mutation'.format(titsce,cond,sel,titgen))
#plt.savefig("ROC.sce{}.S0_{}.{}_gens.{}.pdf".format(titsce,sel,titgen,cond), format="pdf")

file_name = os.path.join(output_folder, "precision-recall.test.pdf")

plt.savefig(file_name, format="pdf")



