import pandas as pd
import sys
import os

dir = sys.argv[1]
firstcol = sys.argv[2]
xpehh_p1vp2 = sys.argv[3]
ddaf = sys.argv[4]
nsl = sys.argv[5]
ihs = sys.argv[6]
fst = sys.argv[7]
out = sys.argv[8]

# First part: divide into columns. 

first_col = pd.read_csv(dir + '/' + firstcol, delim_whitespace=True, names=["SNP_name", "Physical_Distance", "Map_Distance"])

xpehh_p1vp2_col = pd.read_csv(dir + '/' + xpehh_p1vp2, delim_whitespace=True, skiprows = 1, names = ["SNP_name", "gpos", "p1", "ihh1", "p2", "ihh2", "unnorm.XP-EHH.p1vp2", "XP-EHH.p1vp2", "crit"]).dropna()[["SNP_name","XP-EHH.p1vp2"]]

ddaf_col = pd.read_csv(dir + '/' + ddaf, delim_whitespace=True, names = ["SNP_name", "DDAF"]).dropna()[["SNP_name","DDAF"]]

nsl_col = pd.read_csv(dir + '/' + nsl, delim_whitespace=True, names=["locus_ID", "SNP_name", "ALT_freq", "sl1", "sl0", "unnorm.nSL", "nSL", "crit"]).dropna()[["SNP_name","nSL"]]

ihs_col = pd.read_csv(dir + '/' + ihs, delim_whitespace=True, names=["locus_ID", "SNP_name", "ALT_freq", "ihh1", "ihh0", "unnorm.iHS", "iHS", "crit"]).dropna()[["SNP_name","iHS"]]

fst_col = pd.read_csv(dir + '/' + fst, delim_whitespace=True, names = ["SNP_name", "FST"]).dropna()[["SNP_name","FST"]]

# Second part: merge. 

merge1 = first_col.merge(xpehh_p1vp2_col, how = "outer", on = "SNP_name").fillna("-998")
merge1 = merge1.merge(ddaf_col, how = "outer", on = "SNP_name").fillna("-998")
merge1 = merge1.merge(nsl_col, how = "outer", on = "SNP_name").fillna("-998")
merge1 = merge1.merge(ihs_col, how = "outer", on = "SNP_name").fillna("-998")
merge1 = merge1.merge(fst_col, how = "outer", on = "SNP_name").fillna("-998")

merge1.to_csv(dir + '/' + out, index=False, sep='\t')