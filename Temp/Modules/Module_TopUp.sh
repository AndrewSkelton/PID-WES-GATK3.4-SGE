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

##'Raw Data Backup
##'Make a directory and move the raw Data
##'Concatenation output will go in the raw data folder
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Backup/Raw_Data
mv ${2}/Raw_Data/*.gz ${2}/Backup/Raw_Data
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node and Decompress
##'-----------------------------------------------------------------------------------------#
cp ${2}/Backup/Raw_Data/*.gz $TMPDIR
mv ${TMPDIR}/${1}_R1.fastq.gz ${TMPDIR}/${1}_R1_raw.fastq.gz
mv ${TMPDIR}/${1}_R2.fastq.gz ${TMPDIR}/${1}_R2_raw.fastq.gz
cp ${2}/TopUp/*.gz $TMPDIR

ls $TMPDIR

pigz -p 2 -d ${TMPDIR}/*.gz
##'-----------------------------------------------------------------------------------------#

##'Concatenate Fastq
##'-----------------------------------------------------------------------------------------#
cat ${TMPDIR}/${1}_R1_raw.fastq >> ${TMPDIR}/${1}_R1.fastq
cat ${TMPDIR}/${1}_R2_raw.fastq >> ${TMPDIR}/${1}_R2.fastq
##'-----------------------------------------------------------------------------------------#

##'Compress and Move back Lustre
##'-----------------------------------------------------------------------------------------#
pigz -p 2 ${TMPDIR}/${1}_R1.fastq
pigz -p 2 ${TMPDIR}/${1}_R2.fastq

ls ${TMPDIR}
mv ${TMPDIR}/${1}_R*.fastq.gz ${2}/Raw_Data
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Concatenated Fastq as there are topup files" >> ${1}/${2}'.log'
##'-----------------------------------------------------------------------------------------#
