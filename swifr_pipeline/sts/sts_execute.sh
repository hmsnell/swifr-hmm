#!/bin/bash

#SBATCH -J swifr_sts_sweep		# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 10-0 					# time 10 days	
#SBATCH --mem 5G 				    # memory

# module load gcc/10.2 cmake/3.20.0
# module load selscan/1.2.0a
# module load plink

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

samplesize=1000
tag='sweep_pop1'
sc='0.0862'
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops
vcfpath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/slim/5kya/testing/$tag
stspath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/sts/5kya/testing/$tag
yrs='5kya'
pop=pop1
# selscan=/users/hsnell/data/hsnell/swifr/programs/selscan_2.0/bin/osx/selscan

for i in {1..10}; do

# XP-EHH 
echo 'XP-EHH - pop1 vs pop2'
selscan --xpehh --vcf $stspath/$pop.$tag.$yrs.$i.recode.vcf --vcf-ref $stspath/pop2.$tag.$yrs.$i.recode.vcf --map $stspath/$pop.$tag.$yrs.$i.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --out $stspath/$pop.$tag.$yrs.$i # edit for lauren's version of selscan for incomplete sweeps

# DDAF 
echo 'DDAF'
for popu in pop1 pop2 pop3; do
vcftools --vcf $stspath/$popu.$tag.$yrs.$i.recode.vcf --freq2 --stdout | awk '{print $6}' | tail -n+2 | sed "s/{FREQ}/DDAF/g" > $stspath/$popu.$tag.$yrs.$i.DAF; done
grep -v "^#" $stspath/$pop.$tag.$yrs.$i.recode.vcf | awk '{print $2}' | sed '1s/^/SNP_name\n/' > $stspath/$pop.$tag.$yrs.$i.DAF.pos

paste $stspath/pop1.$tag.$yrs.$i.DAF $stspath/pop2.$tag.$yrs.$i.DAF $stspath/pop3.$tag.$yrs.$i.DAF | awk 'BEGIN { OFS = "\t" } {print ($3-(($2+$1)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$pop.$tag.$yrs.$i.DAF.pos - > $stspath/$pop.$tag.$yrs.$i.DDAF.out

# nSL 
echo 'nSL'
selscan --nsl --vcf $stspath/pop3.$tag.$yrs.$i.recode.vcf --map $stspath/$pop.$tag.$yrs.$i.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --out $stspath/$pop.$tag.$yrs.$i 

# iHS 
echo 'iHS' 
selscan --ihs --vcf $stspath/$pop.$tag.$yrs.$i.recode.vcf --map $stspath/$pop.$tag.$yrs.$i.map --maf 0.001 --threads 12 --out $stspath/$pop.$tag.$yrs.$i --trunc-ok --max-extend -1

# Fst
echo 'Fst'
for popu in pop1 pop2 pop3; do grep "^#CHROM" $stspath/$popu.$tag.$yrs.$i.recode.vcf | sed 's/\t/\n/g' | tail -n+10 > $stspath/$popu.$tag.$yrs.$i.txt; done

grep -v "MULTIALLELIC" $vcfpath/YRI.$sc.CEU.0.0.CHB.0.0.SEED.$i.SS.1000.$yrs.vcf | vcftools --vcf - --weir-fst-pop $stspath/pop1.$tag.$yrs.$i.txt --weir-fst-pop $stspath/pop2.$tag.$yrs.$i.txt --weir-fst-pop $stspath/pop3.$tag.$yrs.$i.txt --stdout | cut -f2,3 | sed "s/POS/SNP_name/g" | sed "s/WEIR_AND_COCKERHAM_FST/FST/g" > $stspath/$pop.$tag.$yrs.$i.fst.out

# Clean up 
#rm $fold/pop1.sweep_pop1.$i.xpehh.log $fold/pop1.sweep_pop1.$i.nsl.log $fold/pop1.sweep_pop1.$i.ihs.log $fold/pop1.sweep_pop1.$i.fst.log $fold/pop1.sweep_pop1.$i.DAF.pos 
#for pop in pop1 pop2 pop3; do rm $fold/$pop.sweep_pop1.$i.DAF; rm $fold/$pop.sweep_pop1.$i.txt; done

done

