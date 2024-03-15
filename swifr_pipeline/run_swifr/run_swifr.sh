#!/bin/sh

#SBATCH -J swifr_train 		        # name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 4                        # cores
#SBATCH -t 1-0 					    # time 1 day
#SBATCH --mem 50G 				    # memory

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /oscar/home/hsnell/swifr_example/env

swifr_path=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/swifr_output

cd $swifr_path

#swifr_train --path $swifr_path

#swifr_train --path $swifr_path --retrain

# test neutrals
#swifr_test --path2trained $swifr_path --pi 0.499 0.002 0.499 --file $swifr_path/testing_data/allscenarios_neutral_testing_data 

# test sweeps
#swifr_test --path2trained $swifr_path --pi 0.499 0.002 0.499 --file $swifr_path/testing_data/allscenarios_sweep_testing_data 

# test linked
swifr_test --path2trained $swifr_path --pi 0.499 0.002 0.499 --file $swifr_path/testing_data/allscenarios_linked_testing_data
