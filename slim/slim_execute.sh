#!/bin/bash

#SBATCH -J 5kya_pop2_0.2 			    # name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 10:00:00 					# time 10 days	
#SBATCH --mem 5G 				    # memory

module load slim				
# module load gcc/10.2 cmake/3.20.0

slim=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/slim
size=1000 # sample size from population 	

# read each line of text file containing coefficients  

#pop=$(cat scripts/metadata/5kya_allpops_selcoeffs | head -n $j | tail -1 | awk '{print $1}')
pop=pop2
pop="'$pop'"
#gens=$(cat scripts/metadata/5kya_allpops_selcoeffs | head -n $j | tail -1 | awk '{print $2}')
#allele_freq=$(cat scripts/metadata/5kya_allpops_selcoeffs | head -n $j | tail -1 | awk '{print $3}')
#sel_coeff=$(cat scripts/metadata/5kya_allpops_selcoeffs | head -n $j | tail -1 | awk '{print $4}')
direc="'/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/5kya/'"

for i in {1..100}; do 
    seed=$(shuf -i 1-1000000 -n 1) # generates a random seed for each loop iteration
    # echo $seed
    slim -seed $seed -d gens=200 -d run_name=$i -d N=$size -d pop=$pop -d selCoeff=0.033 -d allele_freq=0.2 -d threshold=0.1 -d direc=$direc $slim/gravelmodel_sweep_5kya.slim
done