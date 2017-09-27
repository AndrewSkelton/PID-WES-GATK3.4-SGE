#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=50G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Samtools sort                                      |
#-------------------------------------------------------------------------------------------#

# $1 - Output Path
# $2 - Sample ID

##'Run Alignment BWA MEM
##'-----------------------------------------------------------------------------------------#
samtools sort -n $1/$2'.sorted.bam' $1/$2
##'-----------------------------------------------------------------------------------------#
