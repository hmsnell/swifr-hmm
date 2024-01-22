#!/bin/bash

#SBATCH -J 1000_sims_5kya			
#SBATCH -N 1 							
#SBATCH -n 1                           
#SBATCH --time 10-00:00						
#SBATCH --mem 5G 						


module load slim				
# module load gcc/10.2 cmake/3.20.0

slim=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/scripts/slim
pop=1000 # sample size from population 								
alpha_yri=0.0862
alpha_ceu=0.0
alpha_chb=0.0
# output_path="/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/slim_vcfs"
# scenario="neutral"

for i in {1..1000}; do echo $i 
seed=$(shuf -i 1-1000000 -n 1) # generates a random seed for each loop iteration
# echo $seed
slim -seed $seed -d run_name=$i -d N=$pop -d alpha_yri=$alpha_yri -d alpha_ceu=$alpha_ceu -d alpha_chb=$alpha_chb $slim/gravelmodel_sweep_5kya.slim 
done
