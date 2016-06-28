#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=2G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run the fastqc utility on the raw data                                     |
#  Input       : Sample ID                                                                  |
#  Input       : Path to sample's Preprocessing Directory                                   |
#  Input       : Path to fastq Files                                                        |
#  Input       : Stage of QC                                                                |
#  Resources   : Memory     - 2GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#

##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/fastqc/0.11.2
##'-----------------------------------------------------------------------------------------#

##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Fastqc/${4}
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${3}/*.gz ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Sort Fastq
##'-----------------------------------------------------------------------------------------#
fastqc ${TMPDIR}/*.gz -o ${2}/Fastqc/${4}
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : FastQC Generated -"${4} >> ${2}/${1}'.log'
##'-----------------------------------------------------------------------------------------#
