#!/bin/bash
#$ -cwd -V
#$ -pe smp 2
#$ -l h_vmem=2G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Sort Original fastq files                          |
#-------------------------------------------------------------------------------------------#

##' $1 - Sample ID
##' $2 - Output Path

module add apps/fastq-tools/0.7

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/*.gz ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Decompress gunzipped fastq files
##'-----------------------------------------------------------------------------------------#
pigz -p 2 -d ${TMPDIR}/*.gz
##'-----------------------------------------------------------------------------------------#

##'Sort Fastq files
##'-----------------------------------------------------------------------------------------#
fastq-sort --id ${TMPDIR}/${1}'_R1.fastq' > ${TMPDIR}/${1}'_R1_Sorted.fastq'
fastq-sort --id ${TMPDIR}/${1}'_R2.fastq' > ${TMPDIR}/${1}'_R2_Sorted.fastq'
##'-----------------------------------------------------------------------------------------#

##'Compress Fastq files
##'-----------------------------------------------------------------------------------------#
pigz -p 2 ${TMPDIR}/${1}'_R1_Sorted.fastq'
pigz -p 2 ${TMPDIR}/${1}'_R2_Sorted.fastq'
##'-----------------------------------------------------------------------------------------#

##'Organise Files
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}'_R1_Sorted.fastq.gz' ${2}
mv ${TMPDIR}/${1}'_R2_Sorted.fastq.gz' ${2}

rm ${2}/${1}'_R1.fastq.gz'
rm ${2}/${1}'_R2.fastq.gz'

mv ${2}/${1}'_R1_Sorted.fastq.gz' ${2}/${1}'_R1.fastq.gz'
mv ${2}/${1}'_R2_Sorted.fastq.gz' ${2}/${1}'_R2.fastq.gz'
##'-----------------------------------------------------------------------------------------#
