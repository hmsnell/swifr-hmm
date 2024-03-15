#!/bin/bash

#SBATCH -J swifr_sts_neutral 		# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 1-0 					    # time 10 days	
#SBATCH --mem 5G 				    # memory


# FOR BENEFICIAL MUTATIONS IN POPULATION 1

module load vcftools
samplesize=1000
#pop='pop1'
#sc='0.0'
#yrs='5kya'
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops # keep this to define pops 
vcfpath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/neutral
stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/neutral

# echo "making MAP file from all pop VCF"
# grep -v "MULTIALLELIC" $vcfpath/YRI.$sc.CEU.0.0.CHB.0.0.SEED.1.SS.1000.vcf | vcftools --vcf - --recode --out $stspath/YRI.$sc.CEU.0.0.CHB.0.0.SEED.1.SS.1000.5kya.nomulti
# vgrep -v "#" $stspath/YRI.$sc.CEU.0.0.CHB.0.0.SEED.1.SS.1000.5kya.nomulti.recode.vcf | awk '{print $1"\t"$3"\t"$2"\t"$2 }' > $stspath/pop123.$tag.5kya.1.map; # change VCF for map file construction

echo "making single pop VCFs" 
for i in {1..100}; do echo $i

# for j in $(shuf -i 0-9999 -n $samplesize); do echo "i$j" >> $popu/pop1.subset.$i.txt; done
# for j in $(shuf -i 10000-19999 -n $samplesize); do echo "i$j" >> $popu/pop2.subset.$i.txt; done
# for j in $(shuf -i 20000-29999 -n $samplesize); do echo "i$j" >> $popu/pop3.subset.$i.txt; done

# cat $popu/pop1.subset.$i.txt $popu/pop2.subset.$i.txt $popu/pop3.subset.$i.txt > $popu/pop1.pop2.pop3.subset.$i.txt

vcftools --vcf $vcfpath/neutral.$i.vcf --non-ref-ac-any 1 --recode --recode-INFO-all --stdout > $vcfpath/neutral.$i.nomono.vcf

for pop in pop1 pop2 pop3; do grep -v "MULTIALLELIC" $vcfpath/neutral.$i.nomono.vcf | vcftools --vcf - --recode --keep $poppath/$pop --out $stspath/$pop.neutral.$i; done
for pop in pop1 pop2 pop3; do grep -v '#' $stspath/$pop.neutral.$i.recode.vcf | awk '{print $1"\t"$3"\t"$2"\t"$2 }' > $stspath/$pop.neutral.$i.map; done; 
done