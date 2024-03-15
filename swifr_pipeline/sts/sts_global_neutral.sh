#!/bin/bash

#SBATCH -J swifr_sts_neutral		# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 1-0 					    # time 10 days	
#SBATCH --mem 5G 				    # memory

# module load gcc/10.2 cmake/3.20.0
# module load selscan/1.2.0a
# module load plink

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

samplesize=1000
#pop='pop1'
#sc='0.0'
#yrs='5kya'
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops # keep this to define pops 
vcfpath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/neutral
stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/neutral
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers # keep this to define headers
foldglobal=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/globals

for popu in pop1 pop2 pop3; do
    # XP-EHH
    #for i in $(eval echo "{1..100}"); do 
    #tail -n+2 $stspath/$pop.neutral.$i.xpehh.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6, $7, $8}' | cat $foldhead/header.xpehh - > $foldglobal/$pop.neutral.xpehh.global

    # DDAF
    for i in {1..100}; do 
    tail -n+2 $stspath/$popu.neutral.$i.DDAF.out; done | sort -k1,1 -n | cat $foldhead/header.ddaf - > $foldglobal/$popu.neutral.DDAF.global

    # nSL 
    for i in {1..100}; do 
    cat $stspath/$popu.neutral.$i.nsl.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' > $foldglobal/$popu.neutral.nsl.global

    # iHS
    for i in {1..100}; do 
    cat $stspath/$popu.neutral.$i.ihs.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' > $foldglobal/$popu.neutral.ihs.global

    # Fst
    for i in {1..100}; do 
    tail -n+2 $stspath/$popu.neutral.$i.fst.out; done | sort -k1,1 -n | cat $foldhead/header.fst - > $foldglobal/$popu.neutral.fst.global
done
