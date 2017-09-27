#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=5G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Migrate All output files to Bridge Directory for Archiving                 |
#  Input       : Bridge Directory                                                           |
#  Input       : Log File                                                                   |
#  Input       : Batch Year                                                                 |
#  Input       : Batch Run                                                                  |
#  Input       : Preprocessing Base Directory                                               |
#  Resources   : Memory     - 5GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Make Directory Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${1}/Alignment/Clean/${3}/${4}
mkdir -p ${1}/Alignment/DeDup/${3}/${4}
mkdir -p ${1}/Alignment/HaplotypeAssembled/${3}/${4}
mkdir -p ${1}/gVCF/${3}/${4}
mkdir -p ${1}/QC/${3}/${4}
mkdir -p ${1}/SRY/${3}/${4}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Directory Structures Created" >> ${2}
##'-----------------------------------------------------------------------------------------#


##'Move Clean Alignments
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/Alignment/Clean/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - Clean Alignment Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*_Clean_GATK.*"` ${1}/Alignment/Clean/${3}/${4}/
  echo $(date)" : Clean Alignments Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Move DeDup Alignments
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/Alignment/DeDup/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - DeDup Alignment Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*_DeDup.*"` ${1}/Alignment/DeDup/${3}/${4}/
  echo $(date)" : DeDup Alignments Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Move Haplotype Assembled Alignments
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/Alignment/HaplotypeAssembled/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - HaplotypeAssembled Alignment Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*_HaplotypeAssembled.*"` ${1}/Alignment/HaplotypeAssembled/${3}/${4}/
  echo $(date)" : HaplotypeAssembled Alignments Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Move gVCF Files
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/gVCF/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - gVCF Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*.g.vcf*"` ${1}/gVCF/${3}/${4}/
  echo $(date)" : gVCF Files Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Move Fastqc Reports
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/QC/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - Fastqc Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*_fastqc*"` ${1}/QC/${3}/${4}/
  echo $(date)" : Fastqc Files Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Move SRY Coverage Files
##'-----------------------------------------------------------------------------------------#
if [ "$(ls -A ${1}/SRY/${3}/${4}/)" ]; then
  echo $(date)" : WARNING - SRY Directory is not empty, skipping..." >> ${2}
else
  mv `find ${5}/${3}/${4}/ -type f -name "*_Gender_SRY.cov"` ${1}/SRY/${3}/${4}/
  echo $(date)" : SRY Coverage Files Moved" >> ${2}
fi
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Bridge Migration Complete" >> ${2}
##'-----------------------------------------------------------------------------------------#
