#!/bin/bash

#SBATCH -J swifr_sts_array 			# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 5:00:00 					# time 2hrs per job days	
#SBATCH --mem 5G 				    # memory
#SBATCH --array=1-45                # array jobs

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

metadata=scripts/metadata/traintest_metafile2

pop=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $1}')
gens=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $2}')
allele_freq=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $3}')
sel_coeff=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $4}')
year=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $5}')

stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/$year/$pop
foldswifr=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/swifr_output
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers # keep to define headers

#######################################################################################

for i in {1..80}; do echo $i 
    tail -n+2 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$i.swifr_final; done | sort -k1,1n | awk 'NF==7 {print}'| awk '$1!=250001 {print}'| cat $foldhead/noxpehh.header - > $foldswifr/$pop-$gens.$pop.$allele_freq.$sel_coeff.train.linked.negative

for i in {90..100}; do echo $i
    tail -n+2 $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$i.swifr_final; done | sort -k1,1n | awk 'NF==7 {print}' | awk '$1!=250001 {print}'| cat $foldhead/noxpehh.header - > $foldswifr/$pop-$gens.$pop.$allele_freq.$sel_coeff.test.linked.negative
