#!/bin/bash

#SBATCH -J swifr_sts_test 			# name
#SBATCH -N 1 						# all cores are on one node
#SBATCH -n 1                        # cores
#SBATCH -t 1-0 					    # time 10 days	
#SBATCH --mem 1G 				    # memory

fold=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/neutral
file="neutral"
foldhead=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/headers
foldglobal=/users/hsnell/data/hsnell/swifr/pop1_AF1_selCoef0.0862/output/sts_output/globals

# XP-EHH.p1vp2
for i in $(eval echo "{1..100}"); do 
tail -n+2 $fold/pop1.neutral.$i.xpehh.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6, $7, $8}' | cat $foldhead/header.xpehh - > $foldglobal/pop1.neutral.xpehh.global

# DDAF
for i in $(eval echo "{1..100}"); do 
file="neutral.$i"
tail -n+2 $fold/pop1.$file.DDAF.out; done | sort -k1,1 -n | cat $foldhead/header.ddaf - > $foldglobal/pop1.neutral.DDAF.global

# nSL 
for i in $(eval echo "{1..100}"); do 
file="neutral.$i"
cat $fold/pop1.$file.nsl.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' > $foldglobal/pop1.neutral.nsl.global

# iHS
for i in $(eval echo "{1..100}"); do 
file="neutral.$i"
cat $fold/pop1.$file.ihs.out; done | sort -k2,2 -n | awk -v OFS='\t' '{print $1, $2, $3, $4, $5, $6}' > $foldglobal/pop1.neutral.ihs.global

# Fst
for i in $(eval echo "{1..100}"); do 
file="neutral.$i"
tail -n+2 $fold/pop1.$file.fst.out; done | sort -k1,1 -n | cat $foldhead/header.fst - > $foldglobal/pop1.neutral.fst.global

