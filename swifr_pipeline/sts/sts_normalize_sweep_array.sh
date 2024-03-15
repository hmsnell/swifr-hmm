#!/bin/bash

#SBATCH -J swifr_sts_array 			# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 5:00:00 					# time 2hrs per job days	
#SBATCH --mem 5G 				    # memory
#SBATCH --array=1-4500              # array jobs

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

metadata=scripts/metadata/big_metafile2

sim=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $1}')
pop=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $2}')
#pop="'$pop'"
gens=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $3}')
allele_freq=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $4}')
sel_coeff=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $5}')
year=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $6}')

direc="'/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/$year/'"
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops # keep this to define pops 
vcfpath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/$year 
stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/$year/$pop
globals=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/globals
foldswifr=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/swifr_output
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers # keep to define headers

##############################################################
# normalize files

if [ $pop == 'pop1' ]; then 

    eval avg_ddaf_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_ddaf_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
    eval avg_fst_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_fst_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")

    # norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
    
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out $globals/pop1.neutral.nsl.global --first --bins 20
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out $globals/pop1.neutral.ihs.global --first --bins 20

    python scripts/normalizer.py $avg_ddaf_pop1 $std_ddaf_pop1 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out $avg_fst_pop1 $std_fst_pop1 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm
    
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_ddaf_$pop) / $std_ddaf_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_fst_$pop) / $std_fst_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col

    python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr_final

elif [ $pop == 'pop2' ]; then

    eval avg_ddaf_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_ddaf_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
    eval avg_fst_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_fst_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")

    # norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
    
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out $globals/pop2.neutral.nsl.global --first --bins 20
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out $globals/pop2.neutral.ihs.global --first --bins 20

    python scripts/normalizer.py $avg_ddaf_pop2 $std_ddaf_pop2 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out $avg_fst_pop2 $std_fst_pop2 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm
    
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_ddaf_$pop) / $std_ddaf_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_fst_$pop) / $std_fst_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col

    python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr_final

else 
    eval avg_ddaf_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_ddaf_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
    eval avg_fst_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
    eval std_fst_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")

    # norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
    
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out $globals/pop3.neutral.nsl.global --first --bins 20
    /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out $globals/pop3.neutral.ihs.global --first --bins 20

    python scripts/normalizer.py $avg_ddaf_pop3 $std_ddaf_pop3 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out $avg_fst_pop3 $std_fst_pop3 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out.norm | sed '1d' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm
    
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_ddaf_$pop) / $std_ddaf_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm
    #cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out | sed '1d' | awk '{print $1, $2 = ($2 - $avg_fst_$pop) / $std_fst_$pop}' | awk '{print $1=$1".0", $2}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col

    python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.first.col $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DDAF.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.nsl.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.ihs.out.20bins.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.fst.norm $pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr

    cat $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.swifr_final

fi