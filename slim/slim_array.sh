#!/bin/bash
#SBATCH -J allscenarios_100sims_30kya_redolist4
#SBATCH --array=1398
#SBATCH --mem=5G
#SBATCH -t 3-00:00

echo "Starting job $SLURM_ARRAY_TASK_ID on $HOSTNAME"
t=`printf "%03d" $SLURM_ARRAY_TASK_ID`

metadata=scripts/metadata/30kya_allpops_selcoeffs

sim=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $1}')
pop=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $2}')
pop="'$pop'"
gens=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $3}')
allele_freq=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $4}')
selCoeff=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $5}')
threshold=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $7}')
direc="'/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/'"

scripts/run_slim.sh $sim $pop $gens $selCoeff $allele_freq $threshold $direc