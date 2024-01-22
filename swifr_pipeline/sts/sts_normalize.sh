#!/bin/sh

#SBATCH -J swifr_sts_normalize 			# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 1-0 					# time 10 days	
#SBATCH --mem 1G 				    # memory

tag='sweep_pop1'
prog=/users/hsnell/data/hsnell/swifr/programs
sels=$prog/selscan_2.0/bin/linux/selscan
#norm=$prog/selscan_2.0/bin/linux/norm
sugd=$prog/selscan.sugden/selscan/src/selscan

module load gcc/10.2 cmake/3.20.0
module load selscan/1.2.0a
module load vcftools/0.1.16

fold=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output

##############################################################
# Normalize files. 

avg_ddaf=$(python -c "import numpy as np; data = np.loadtxt('$fold/globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
std_ddaf=$(python -c "import numpy as np; data = np.loadtxt('$fold/globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
avg_fst=$(python -c "import numpy as np; data = np.loadtxt('$fold/globals/pop1.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
std_fst=$(python -c "import numpy as np; data = np.loadtxt('$fold/globals/pop1.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")

echo $avg_ddaf $std_ddaf $avg_fst $std_fst

for i in $(eval echo "{1..100}"); do 

norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
norm --nsl --files $fold/$tag/pop1.$tag.$i.nsl.out $fold/globals/pop1.neutral.nsl.global --first --bins 20
norm --ihs --files $fold/$tag/pop1.$tag.$i.ihs.out $fold/globals/pop1.neutral.ihs.global --first --bins 20

cat $fold/$tag/pop1.$tag.$i.DDAF.out | sed '1d' | awk '{print $1, ($2-$avg_ddaf)/$std_ddaf}' | awk '{print $1=$1".0", $2}' > $fold/$tag/pop1.$tag.$i.DDAF.norm
cat $fold/$tag/pop1.$tag.$i.fst.out | sed '1d' | awk '{print $1, ($2-$avg_fst)/$std_fst}' | awk '{print $1=$1".0", $2}' > $fold/$tag/pop1.$tag.$i.fst.norm

cat $fold/$tag/pop1.$tag.$i.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $fold/$tag/pop1.$tag.$i.first.col

python /users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/scripts/merge.5.stats.norm.py $fold/$tag pop1.$tag.$i.first.col pop1.$tag.$i.xpehh.out.norm pop1.$tag.$i.DDAF.norm pop1.$tag.$i.nsl.out.20bins.norm pop1.$tag.$i.ihs.out.20bins.norm pop1.$tag.$i.fst.norm pop1.$tag.$i.swifr

cat $fold/$tag/pop1.$tag.$i.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==8 {print}' > $fold/$tag/pop1.$tag.$i.swifr_final

done

