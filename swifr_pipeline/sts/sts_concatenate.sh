#!/bin/sh

#####################################################################################################
# Pre_1. Let's define files. 
# type of archive: p1.p2.p3.S0_0.0.migr_0.5.seed.100.gens.189.vcf

# fold:		Where are the archives (what folder)
# popsize:	What is the population size (if important)
# S0:		What is the pre-admixture selection coefficient
# migp2: 	What is the migp2tion proportion
# S1:		What is the post-admixture selection coefficient
# gen:		At what generation do we stop the simulation
# firstsd:	What is the first seed that we start this loop with
# endsd:	What is the last seed
# sce:		In what scenario are we working
# treat:	What treatment we are going to work on (for example pop.500.resca)

tag='sweep_pop1'
fold=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/$tag	
foldtive=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/swifr_output
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers

for i in {1..80}; do echo $i 
tail -n+2 $fold/pop1.$tag.$i.swifr_final; done | sort -k1,1n | awk 'NF==8 {print}'| cat $foldhead/header.swifr - > $foldtive/pop1.$tag.train.negative

for i in {90..100}; do echo $i
tail -n+2 $fold/pop1.$tag.$i.swifr_final; done | sort -k1,1n | awk 'NF==8 {print}' | cat $foldhead/header.swifr - > $foldtive/pop1.$tag.test.negative

