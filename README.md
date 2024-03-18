# swifr-hmm
additions to the SWIF(r) framework using and AODE HMM

## environment setup 

see yamls/ folder for two main envs: 
- **swifr_tools**: contains plink, vcftools, selscan, scikit-allel, etc.
- **swifr_example**: help from CCV to build since this was tricky. used python version 3.7 

## metadata structure 
for all of the following scripts, i used metadata files to indicate the unique values of each sim. the file had the following structure: 
| simulation number | population | generations | allele frequency | selection coefficient | AF min threshold |
| ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
| 1  | pop1 | 200 | 0.2 | 0.0376 | 0.2 |
| 2  | pop1 | 200 | 0.2 | 0.0376 | 0.2 |
| ... | ... | ... | ... | ... | ... |
| 100 | pop1 | 200 | 0.2 | 0.0376 | 0.2 | 
| 1 | pop1 | 200 | 0.4 | 0.0415 | 0.3 | 
| ... | ... | ... | ... | ... | ... |

## pipeline structure  
1. _SLiM simulations:_ scripts to generate corresponding sweep and neutral simulations - these are hard-coded for different sweep mutation introduction times.  
   - *run_slim.sh*: contains actual SLiM command with corresponding simulation script
   - *slim_array.sh*: job array set up for sweep simulations based on metadata file of all sweep scenarios  
2. _STS calculations:_ five scripts to generate input for SWIF(r) tool  

For the sweep files, these scripts have been more efficiently set up:  
   - *swifr_pipeline/sts/sts_sweep_array.sh*: job array to generate statistics from sweep files
   -  *swifr_pipeline/sts/sts_normalize_sweep_array.sh*: job array to normalize statistics
   -   *swifr_pipeline/sts/sts_train_test.sh*: job array to create training and testing sets depending on sweep mutation location   

For the neutral files, the original file structure is used: 
   -  *swifr_pipeline/sts/sts_prepare_neutral.sh*: generate single-population VCF files and MAP files  
   -  *swifr_pipeline/sts/sts_execute_neutral.sh*: calculate five point statistics for population 1  
   -  *swifr_pipeline/sts/sts_global_neutral.sh*: use neutral files to create global statistics for normalization  
   -  *swifr_pipeline/sts/sts_normalize_neutral.sh*: normalize all statistics against global files  
   -  *swifr_pipeline/sts/sts_concatenate_neutral.sh*: concatenate training and testing statistic files for input to SWIF(r)  

3. _SWIF(r):_ script to train and test with SWIF(r), Python scripts to generate ROC and precision recall curves to measure tool performance   
   - *swifr_pipeline/run_swifr/run_swifr.sh*: script to actually run swifr on training and testing data  
   - *swifr_pipeline/run_swifr/swifr_alltests.sh*: reference script for all swifr training and testing commands  
   - *swifr_pipeline/run_swifr/ROC_curves_SWIFr.py*: generate ROC curves from classified output  
   - *swifr_pipeline/run_swifr/precision_recall_curves_SWIFr.py*: generate precision-recall curves from classified output   

## references  
- original SWIF(r) publication: https://www.nature.com/articles/s41467-018-03100-7#Sec11
- SWIF(r) repository: https://github.com/ramachandran-lab/SWIFr
- thank you to Dr. Carlos Sarabia for help in setting up much of this initial code structure!
 
