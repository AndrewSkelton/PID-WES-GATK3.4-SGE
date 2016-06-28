#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=40G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run BWA MEM on the Paired Reads                                            |
#  Input       : Read Group                                                                 |
#  Input       : Reference Fasta                                                            |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Paired Fastq Files                                                 |
#  Input       : Path to Sample's preprocessing base                                        |
#  Resources   : Memory     - 40GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#

##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${5}/Alignment/Paired
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${4}/*.gz ${TMPDIR}
cp ${2} ${TMPDIR}
# FA_REF=$(basename "$2")
# ${TMPDIR}/${FA_REF}
##'-----------------------------------------------------------------------------------------#

##'Run BWA MEM With Paired Reads
##'-----------------------------------------------------------------------------------------#
bwa mem \
        -t 5 \
        -M \
        -R ${1} \
        ${2} \
        ${TMPDIR}/${3}_R1.fastq.gz \
        ${TMPDIR}/${3}_R2.fastq.gz > ${TMPDIR}/${3}'_P_BWA.sam'
##'-----------------------------------------------------------------------------------------#

##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${3}'_P_BWA.sam' ${5}/Alignment/Paired
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Paired Reads Aligned" >> ${5}/${3}'.log'
##'-----------------------------------------------------------------------------------------#
