#!/bin/sh

module load slim
slim=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/scripts/slim
size=1000
run_name=$1
pop=$2
# pop="'$pop'"
gens=$3
selCoeff=$4
allele_freq=$5
threshold=$6
direc=$7
# direc="'$direc'"

#echo $run_name $pop $gens $selCoeff $allele_freq $direc
#sleep 5
seed=$(shuf -i 1-1000000 -n 1) # generates a random seed for each loop iteration
# echo $seed
#echo $direc $pop $allele_freq $selCoeff $run_name
slim -seed $seed -d gens=$gens -d run_name=$run_name -d N=$size -d pop=$pop -d selCoeff=$selCoeff -d allele_freq=$allele_freq -d threshold=$threshold -d direc=$direc $slim/gravelmodel_sweep_30kya.slim
# slim -seed $seed -d run_name=$run_name -d N=$size -d direc=$direc $slim/gravelmodel_neutral.slim