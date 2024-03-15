# swifr-hmm
additions to the SWIF(r) framework using and AODE HMM

## environment setup 

main setup: 

```
conda create --name swifr python=3.7
conda activate swifr
pip3 install swifr
```
other packages: 


## pipeline structure  
1. _SLiM simulations:_ scripts to generate corresponding sweep and neutral simulations - these are hard-coded for a sweep mutation introduction time of 200 gens ago (more times to be added).
2. _STS calculations:_ five scripts to generate input for SWIF(r) tool
   a. *sts_prepare.sh*: generate single-population VCF files and MAP files
   b. *sts_execute.sh*: calculate five point statistics for population 1
   c. *sts_global.sh*: use neutral files to create global statistics for normalization
   d. *sts_normalize.sh*: normalize all statistics against global files
   e. *sts_concatenate.sh*: concatenate training and testing statistic files for input to SWIF(r)
3. _SWIF(r):_ script to train and test with SWIF(r), Python scripts to generate ROC and precision recall curves to measure tool performance

## references  
- original SWIF(r) publication: https://www.nature.com/articles/s41467-018-03100-7#Sec11
- SWIF(r) repository: https://github.com/ramachandran-lab/SWIFr
- thank you to Dr. Carlos Sarabia for help in setting up much of this initial code structure!
 
