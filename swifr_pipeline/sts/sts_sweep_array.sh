#!/bin/bash

#SBATCH -J swifr_sts_array      	# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 10:00:00 			    # time 5hrs per job days	
#SBATCH --mem 5G 				    # memory
#SBATCH --array=1501-4500           # array jobs

module load anaconda
source /oscar/runtime/opt/anaconda/2023.03-1/etc/profile.d/conda.sh
conda activate /users/hsnell/.conda/envs/swifr_tools

metadata=scripts/metadata/big_metafile2

sim=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $1}')
pop=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $2}')
#pop="'$pop'"
gens=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $3}')
allele_freq=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $4}')
sel_coeff=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $5}')
year=$(cat $metadata | head -n $SLURM_ARRAY_TASK_ID | tail -1 | awk '{print $6}')

direc="'/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/$year/'"
poppath=/users/hsnell/data/hsnell/swifr/pop1_AF1_alltimes/output/pops # keep this to define pops 
vcfpath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/slim/$year 
stspath=/users/hsnell/data/hsnell/swifr/allscenarios_100sims/output/sts/$year/$pop

#################### generate single-population VCF files within each scenario ######################
echo 'filtering out monomorphic sites' 
vcftools --vcf $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.vcf --non-ref-ac-any 1 --recode --recode-INFO-all --stdout > $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.nomono.vcf

echo "making single pop VCFs" 
for popu in pop1 pop2 pop3; do grep -v "MULTIALLELIC" $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.nomono.vcf | vcftools --vcf - --recode --keep $poppath/$popu --out $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim; done
for popu in pop1 pop2 pop3; do grep -v '#' $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | awk '{print $1"\t"$3"\t"$2"\t"$2 }' > $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.map; done

#################### calculate individual statistics within each scenario ###########################
# XP-EHH 
#echo 'XP-EHH'
#if [ $pop == 'pop1' ]; then 
#    xpehh=$(python -c "import allel as sa; targetpop = sa.read_vcf($stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); refpop = sa.read_vcf($stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); print(sa.xpehh(targetpop['calldata/GT'][:, :, 0], refpop['calldata/GT'][:, :, 0], pos=targetpop['variants/POS'], include_edges=True, use_threads=True))")
#    echo '$xpehh' > $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh 
#    #python xpehh_test/run_xpehh.py $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf > $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh 
#elif [ $pop == 'pop2' ]; then
#    xpehh=$(python -c "import allel as sa; targetpop = sa.read_vcf($stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); refpop = sa.read_vcf($stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); print(sa.xpehh(targetpop['calldata/GT'][:, :, 0], refpop['calldata/GT'][:, :, 0], pos=targetpop['variants/POS'], include_edges=True, use_threads=True))")
#    echo '$xpehh' > $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh
    #python xpehh_test/run_xpehh.py $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh_test
    #/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --xpehh --vcf $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --vcf-ref $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --map $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --wagh --out $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim
#else 
#    xpehh=$(python -c "import allel as sa; targetpop = sa.read_vcf($stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); refpop = sa.read_vcf($stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf); print(sa.xpehh(targetpop['calldata/GT'][:, :, 0], refpop['calldata/GT'][:, :, 0], pos=targetpop['variants/POS'], include_edges=True, use_threads=True))")
#    echo '$xpehh' > $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh
    #python xpehh_test/run_xpehh.py $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.xpehh_test
    #/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --xpehh --vcf $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --vcf-ref $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --map $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --wagh --out $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim
#fi

# DDAF 
echo 'DDAF'
for popu in pop1 pop2 pop3; do
vcftools --vcf $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --freq2 --stdout | awk '{print $6}' | tail -n+2 | sed "s/{FREQ}/DDAF/g" > $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF; done
grep -v "^#" $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | awk '{print $2}' | sed '1s/^/SNP_name\n/' > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos
if [ $pop == 'pop1' ]; then 
    paste $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF | awk 'BEGIN { OFS = "\t" } {print ($1-(($2+$3)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos - > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out
elif [ $pop == 'pop2' ]; then 
    paste $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF | awk 'BEGIN { OFS = "\t" } {print ($2-(($1+$3)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos - > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out
else
    paste $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF | awk 'BEGIN { OFS = "\t" } {print ($3-(($2+$1)/2))}' | sed '1s/^/DDAF\n/' | paste $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos - > $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.DAF.pos.DDAF.out
fi

# nSL 
echo 'nSL'
/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --nsl --vcf $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --map $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.map --maf 0.001 --threads 12 --trunc-ok --keep-low-freq --out $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim 

# iHS 
echo 'iHS' 
/users/hsnell/data/hsnell/swifr/programs/selscan/bin/linux/./selscan --ihs --vcf $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf --map $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim.map --maf 0.001 --threads 12 --trunc-ok --max-extend -1 --out $stspath/$pop-$gens.$pop.$allele_freq.$sel_coeff.$sim

# Fst
echo 'Fst'
for popu in pop1 pop2 pop3; do grep "^#CHROM" $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.recode.vcf | sed 's/\t/\n/g' | tail -n+10 > $stspath/$popu-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt; done
if [ $pop == 'pop1' ]; then     
    grep -v "MULTIALLELIC" $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.nomono.vcf | vcftools --vcf - --weir-fst-pop $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --stdout | cut -f2,3 | sed "s/POS/SNP_name/g" | sed "s/WEIR_AND_COCKERHAM_FST/FST/g" > $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
elif [ $pop == 'pop2' ]; then 
    grep -v "MULTIALLELIC" $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.nomono.vcf | vcftools --vcf - --weir-fst-pop $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --stdout | cut -f2,3 | sed "s/POS/SNP_name/g" | sed "s/WEIR_AND_COCKERHAM_FST/FST/g" > $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
else    
    grep -v "MULTIALLELIC" $vcfpath/$gens.$pop.$allele_freq.$sel_coeff.$sim.nomono.vcf | vcftools --vcf - --weir-fst-pop $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop1-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --weir-fst-pop $stspath/pop2-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt --stdout | cut -f2,3 | sed "s/POS/SNP_name/g" | sed "s/WEIR_AND_COCKERHAM_FST/FST/g" > $stspath/pop3-$gens.$pop.$allele_freq.$sel_coeff.$sim.txt.fst.out
fi