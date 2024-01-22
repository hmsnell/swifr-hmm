#!/bin/sh

#####################################################################################################
# Pre_1. Let's define files. 

# foldtive:	Where are the neutral and sweep concatenated files
# popsize:	What is the population size (if important)
# S0:		What is the pre-admixture selection coefficient
# migp2: 	What is the migp2tion proportion
# S1:		What is the post-admixture selection coefficient
# sce:		In what scenario are we working (0-5)
# treat:	What treatment we are going to work on (for example pop.500.resca)
# pathswifr:	Where is the swifr folder
# foldnums:	Where are the one-dimensional _nums files

foldtive=/users/hsnell/data/hsnell/swifr/swifr_output
pathswifr=/users/hsnell/data/hsnell/swifr/swifr_output
foldnums=$9

pop=pop1

# we pass the file names as variables to swifr for easier handling. 
neuttrain=$pathswifr/pop1.neutral.train.negative
sweeptrain=$pathswifr/pop1.sweep_pop1.train.negative
neuttest=$pathswifr/pop1.neutral.test.negative
sweeptest=$pathswifr/pop1.sweep_pop1.test.negative

comp=$pathswifr/component_statistic_distributions/joints
comm=$pathswifr/component_statistic_distributions/marginals

# copy the neutral and sweep training files to the swifr directory. 
cp $foldtive/$neuttrain $pathswifr/simulations/neutral/$neuttrain
cp $foldtive/$sweeptrain $pathswifr/simulations/sweep/$sweeptrain

# train SWIF(r) with the neutral and sweep training files
echo '############################## train'
swifr_train --path $pathswifr/

# to avoid overadjusting by SWIF(r), we reduce the dimensions of each variable to 1. We have a joint_component_nums and a marginal_component_nums file prepared. After that, we retrain the model.
echo '############################## retrain'
cp $foldnums/joint_component_nums $pathswifr/AODE_params/joint_component_nums
cp $foldnums/marginal_component_nums $pathswifr/AODE_params/marginal_component_nums

swifr_train --path $pathswifr/ --retrain

# we unite all pdfs into one and store them in another folder. 
pdfunite $comp/XP-EHH.p1vp3_DDAF_joint.pdf $comp/XP-EHH.p1vp3_nSL_joint.pdf $comp/XP-EHH.p1vp3_iHS_joint.pdf $comp/XP-EHH.p1vp3_FST_joint.pdf $comp/DDAF_nSL_joint.pdf $comp/DDAF_iHS_joint.pdf $comp/DDAF_FST_joint.pdf $comp/nSL_iHS_joint.pdf $comp/nSL_FST_joint.pdf $comp/iHS_FST_joint.pdf $foldtive/joints.$pop.sce.$sce.S0_$S0.seed.all.gens.$gen.$treat.pdf

pdfunite $comm/XP-EHH.p1vp3_marginal.pdf $comm/DDAF_marginal.pdf $comm/nSL_marginal.pdf $comm/iHS_marginal.pdf $comm/FST_marginal.pdf $foldtive/marginals.$pop.sce.$sce.S0_$s.seed.all.gens.$gen.$treat.pdf

# we test the trained data with the neutral and sweep testing datasets. 
echo '############################## test with true selected'
swifr_test --path2trained $pathswifr/ --pi 0.998 0.002 --file $foldtive/$sweeptest

echo '############################## test with neutral (false selected) '
swifr_test --path2trained $pathswifr/ --pi 0.998 0.002 --file $foldtive/$neuttest

# so that we can run swifr again, we remove the files from the sweep and neutral directories. 
rm $pathswifr/simulations/neutral/$neuttrain $pathswifr/simulations/sweep/$sweeptrain



