#!/bin/bash
#$ -cwd -V
#$ -pe smp 2
#$ -l h_vmem=5G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Handle Technical replication by merging fastq files                        |
#  Input       : Sample ID                                                                  |
#  Input       : Path to sample's Preprocessing Directory                                   |
#  Resources   : Memory     - 5GB                                                           |
#  Resources   : Processors - 2                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/fastq-tools/0.7
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node and Decompress
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Backup/Pre_Sort/

cp ${2}/Raw_Data/*.gz ${TMPDIR}
mv ${2}/Raw_Data/*.gz ${2}/Backup/Pre_Sort/

pigz -p 2 -d ${TMPDIR}/*.gz
ls ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Sort Fastq
##'-----------------------------------------------------------------------------------------#
fastq-sort --id ${TMPDIR}/${1}'_R1.fastq' > ${TMPDIR}/${1}'_R1_Sorted.fastq'
fastq-sort --id ${TMPDIR}/${1}'_R2.fastq' > ${TMPDIR}/${1}'_R2_Sorted.fastq'
##'-----------------------------------------------------------------------------------------#

##'Compress and Move back Lustre
##'-----------------------------------------------------------------------------------------#
pigz -p 2 ${TMPDIR}/${1}_R1_Sorted.fastq
pigz -p 2 ${TMPDIR}/${1}_R2_Sorted.fastq
ls ${TMPDIR}

mkdir -p ${2}/Raw_Data/Backup
mv ${2}/Raw_Data/*.gz ${2}/Raw_Data/Backup

mv ${TMPDIR}/${1}_R1_Sorted.fastq.gz ${2}/Raw_Data/${1}_R1.fastq.gz
mv ${TMPDIR}/${1}_R2_Sorted.fastq.gz ${2}/Raw_Data/${1}_R2.fastq.gz
ls ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Sorted Fastq Files" >> ${2}/${1}'.log'
##'-----------------------------------------------------------------------------------------#
