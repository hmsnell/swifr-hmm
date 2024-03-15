#!/bin/sh

#SBATCH -J swifr_sts_normalize 		# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 1-0 					    # time 10 days	
#SBATCH --mem 1G 				    # memory

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/neutral
globals=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/globals
foldswifr=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/swifr_output
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers

##############################################################
# normalize neutral files 

for popu in pop1 pop2 pop3; do
    if [ $popu == 'pop1' ]; then 
        eval avg_ddaf_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_ddaf_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
        eval avg_fst_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_fst_pop1=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop1.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")

        for i in {1..100}; do 

            #norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/pop1.neutral.$i.nsl.out $globals/pop1.neutral.nsl.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/pop1.neutral.$i.ihs.out $globals/pop1.neutral.ihs.global --first --bins 20

            python scripts/normalizer.py $avg_ddaf_pop1 $std_ddaf_pop1 $stspath/$popu.neutral.$i.DDAF.out $avg_fst_pop1 $std_fst_pop1 $stspath/$popu.neutral.$i.fst.out
            cat $stspath/$popu.neutral.$i.DDAF.out.norm | sed '1d' > $stspath/$popu.neutral.$i.DDAF.norm
            cat $stspath/$popu.neutral.$i.fst.out.norm | sed '1d' > $stspath/$popu.neutral.$i.fst.norm

            cat $stspath/$popu.neutral.$i.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$popu.neutral.$i.first.col

            python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $popu.neutral.$i.first.col $popu.neutral.$i.DDAF.norm $popu.neutral.$i.nsl.out.20bins.norm $popu.neutral.$i.ihs.out.20bins.norm $popu.neutral.$i.fst.norm $popu.neutral.$i.swifr

            cat $stspath/$popu.neutral.$i.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$popu.neutral.$i.swifr_final

        done
    
    elif [ $popu == 'pop2' ]; then 
        eval avg_ddaf_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_ddaf_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
        eval avg_fst_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_fst_pop2=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop2.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")
    
        for i in {1..100}; do 

            #norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/pop2.neutral.$i.nsl.out $globals/pop2.neutral.nsl.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/pop2.neutral.$i.ihs.out $globals/pop2.neutral.ihs.global --first --bins 20

            python scripts/normalizer.py $avg_ddaf_pop2 $std_ddaf_pop2 $stspath/$popu.neutral.$i.DDAF.out $avg_fst_pop2 $std_fst_pop2 $stspath/$popu.neutral.$i.fst.out
            cat $stspath/$popu.neutral.$i.DDAF.out.norm | sed '1d' > $stspath/$popu.neutral.$i.DDAF.norm
            cat $stspath/$popu.neutral.$i.fst.out.norm | sed '1d' > $stspath/$popu.neutral.$i.fst.norm

            cat $stspath/$popu.neutral.$i.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$popu.neutral.$i.first.col

            python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $popu.neutral.$i.first.col $popu.neutral.$i.DDAF.norm $popu.neutral.$i.nsl.out.20bins.norm $popu.neutral.$i.ihs.out.20bins.norm $popu.neutral.$i.fst.norm $popu.neutral.$i.swifr

            cat $stspath/$popu.neutral.$i.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$popu.neutral.$i.swifr_final

        done
    
    else
        eval avg_ddaf_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.DDAF.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_ddaf_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.DDAF.global', skiprows=1); print(np.nanstd(data[1:,1]))")
        eval avg_fst_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.fst.global', skiprows=1); print(np.nanmean(data[1:,1]))")
        eval std_fst_pop3=$(python -c "import numpy as np; data = np.loadtxt('$globals/pop3.neutral.fst.global', skiprows=1); print(np.nanstd(data[1:,1]))")
    
        for i in {1..100}; do 

            #norm --xpehh --files $fold/$tag/pop1.$tag.$i.xpehh.out $fold/globals/pop1.neutral.xpehh.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --nsl --files $stspath/pop3.neutral.$i.nsl.out $globals/pop3.neutral.nsl.global --first --bins 20
            /users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./norm --ihs --files $stspath/pop3.neutral.$i.ihs.out $globals/pop3.neutral.ihs.global --first --bins 20

            python scripts/normalizer.py $avg_ddaf_pop3 $std_ddaf_pop3 $stspath/$popu.neutral.$i.DDAF.out $avg_fst_pop3 $std_fst_pop3 $stspath/$popu.neutral.$i.fst.out
            cat $stspath/$popu.neutral.$i.DDAF.out.norm | sed '1d' > $stspath/$popu.neutral.$i.DDAF.norm
            cat $stspath/$popu.neutral.$i.fst.out.norm | sed '1d' > $stspath/$popu.neutral.$i.fst.norm

            cat $stspath/$popu.neutral.$i.recode.vcf | grep -v "^#" | awk -v OFS='\t' '{printf "%d\t%d\t%.3e\n", $2, $2, $2/(10^9)}' > $stspath/$popu.neutral.$i.first.col

            python /users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/merge.5.stats.norm.py $stspath $popu.neutral.$i.first.col $popu.neutral.$i.DDAF.norm $popu.neutral.$i.nsl.out.20bins.norm $popu.neutral.$i.ihs.out.20bins.norm $popu.neutral.$i.fst.norm $popu.neutral.$i.swifr

            cat $stspath/$popu.neutral.$i.swifr | awk 'NR==1; NR>1 && $1>1 {print}' | awk 'NF==7 {print}' > $stspath/$popu.neutral.$i.swifr_final

        done
    fi
done

