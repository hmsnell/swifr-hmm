#!/bin/sh

#SBATCH -J swifr_cat_neutral 		# name
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

##########################################################################################

for popu in pop1 pop2 pop3; do 
    for i in {1..80}; do echo $i 
    tail -n+2 $stspath/$popu.neutral.$i.swifr_final; done | sort -k1,1n | awk 'NF==7 {print}'| cat $foldhead/noxpehh.header - > $foldswifr/$popu.neutral.train.negative

    for i in {90..100}; do echo $i
    tail -n+2 $stspath/$popu.neutral.$i.swifr_final; done | sort -k1,1n | awk 'NF==7 {print}' | cat $foldhead/noxpehh.header - > $foldswifr/$popu.neutral.test.negative
done
