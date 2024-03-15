#!/bin/bash

#SBATCH -J swifr_sts_neutral		# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 10:00:00 					# time 7hrs	
#SBATCH --mem 5G 				    # memory
#SBATCH --array=1-100

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

samplesize=1000
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops # keep this to define pops 
vcfpath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/neutral
stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/neutral

i=$SLURM_ARRAY_TASK_ID

# XP-EHH 
#echo 'XP-EHH - pop1 vs pop2'
#/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --xpehh --vcf $stspath/pop1.neutral.$i.recode.vcf --vcf-ref $stspath/pop2.neutral.$i.recode.vcf --map $stspath/pop2.neutral.$i.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --wagh --out $stspath/pop1.neutral.$i # edit for lauren's version of selscan for incomplete sweeps

# DDAF 
echo 'DDAF'
for popu in pop1 pop2 pop3; do
vcftools --vcf $stspath/$popu.neutral.$i.recode.vcf --freq2 --stdout | awk '{print $6}' | tail -n+2 | sed "s/{FREQ}/DDAF/g" > $stspath/$popu.neutral.$i.DAF; done

    for popu in pop1 pop2 pop3; do
    grep -v "^#" $stspath/$popu.neutral.$i.recode.vcf | awk '{print $2}' | sed '1s/^/SNP_name\n/' > $stspath/$popu.neutral.$i.DAF.pos

    if [ $popu == 'pop1' ]; then 
        paste $stspath/pop1.neutral.$i.DAF $stspath/pop2.neutral.$i.DAF $stspath/pop3.neutral.$i.DAF | awk 'BEGIN { OFS = "\t" } {print ($1-(($2+$3)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$popu.neutral.$i.DAF.pos - > $stspath/$popu.neutral.$i.DDAF.out
    elif [ $popu == 'pop2' ]; then 
        paste $stspath/pop1.neutral.$i.DAF $stspath/pop2.neutral.$i.DAF $stspath/pop3.neutral.$i.DAF | awk 'BEGIN { OFS = "\t" } {print ($2-(($1+$3)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$popu.neutral.$i.DAF.pos - > $stspath/$popu.neutral.$i.DDAF.out
    else
        paste $stspath/pop1.neutral.$i.DAF $stspath/pop2.neutral.$i.DAF $stspath/pop3.neutral.$i.DAF | awk 'BEGIN { OFS = "\t" } {print ($3-(($2+$1)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$popu.neutral.$i.DAF.pos - > $stspath/$popu.neutral.$i.DDAF.out
    fi

done

# nSL 
 #echo 'nSL'
#for popu in pop1 pop2 pop3; do 
#/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --nsl --vcf $stspath/$popu.neutral.$i.recode.vcf --map $stspath/$popu.neutral.$i.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --out $stspath/$popu.neutral.$i; done

# iHS 
#echo 'iHS' 
#for popu in pop1 pop2 pop3; do
#/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --ihs --vcf $stspath/$popu.neutral.$i.recode.vcf --map $stspath/$popu.neutral.$i.map --maf 0.001 --threads 12 --out $stspath/$popu.neutral.$i --trunc-ok --max-extend -1; done

# Fst
#echo 'Fst'
#for popu in pop1 pop2 pop3; do grep "^#CHROM" $stspath/$popu.neutral.$i.recode.vcf | sed 's/\t/\n/g' | tail -n+10 > $stspath/$popu.neutral.$i.txt; done
#for popu in pop1 pop2 pop3; do 
#grep -v "MULTIALLELIC" $vcfpath/neutral.$i.vcf | vcftools --vcf - --weir-fst-pop $stspath/pop1.neutral.$i.txt --weir-fst-pop $stspath/pop2.neutral.$i.txt --weir-fst-pop $stspath/pop3.neutral.$i.txt --stdout | cut -f2,3 | sed "s/POS/SNP_name/g" | sed "s/WEIR_AND_COCKERHAM_FST/FST/g" > $stspath/$popu.neutral.$i.fst.out; done



