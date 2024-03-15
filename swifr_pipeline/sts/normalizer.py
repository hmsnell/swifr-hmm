import pandas as pd
import sys
import os

avg_ddaf = float(sys.argv[1])
std_ddaf = float(sys.argv[2])
ddaf_file = sys.argv[3]
avg_fst = float(sys.argv[4])
std_fst = float(sys.argv[5])
fst_file = sys.argv[6]

# normalize ddaf 
ddaf_file_clean = pd.read_csv(ddaf_file, delim_whitespace=True, names = ['SNP_name', 'DDAF'])
ddaf_file_clean2 = ddaf_file_clean.drop(index = 0)
ddaf_to_normalize = pd.DataFrame(ddaf_file_clean2)

ddaf_to_normalize["DDAF"] = ddaf_to_normalize["DDAF"].astype(float)
ddaf_to_normalize = ddaf_to_normalize.assign(DDAF = lambda x: ((x['DDAF'] - avg_ddaf) / std_ddaf))
ddaf_to_normalize.to_csv(ddaf_file + ".norm", index=False, sep='\t', header=None)

# normalize fst
fst_file_clean = pd.read_csv(fst_file, delim_whitespace=True, names = ['SNP_name', 'FST'])
fst_file_clean2 = fst_file_clean.drop(index = 0)
fst_to_normalize = pd.DataFrame(fst_file_clean2)

fst_to_normalize["FST"] = fst_to_normalize["FST"].astype(float)
fst_to_normalize = fst_to_normalize.assign(FST = lambda x: ((x['FST'] - avg_fst) / std_fst))
fst_to_normalize.to_csv(fst_file + ".norm", index=False, sep='\t', header=None)
