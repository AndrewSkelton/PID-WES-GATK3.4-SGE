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
#  Description : Run BWA MEM to align unpaired reads                                        |
#  Input       : Read Group                                                                 |
#  Input       : Reference Fasta                                                            |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Unpaired Fastq Files                                               |
#  Input       : Path to Sample's preprocessing base                                        |
#  Resources   : Memory     - 40GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#

##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${5}/Alignment/Unpaired
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${4}/*.gz ${TMPDIR}
cp ${2} ${TMPDIR}
pigz -p 5 -d ${TMPDIR}/${3}_1U.fastq.gz
pigz -p 5 -d ${TMPDIR}/${3}_2U.fastq.gz
mv ${TMPDIR}/${3}_1U.fastq ${TMPDIR}/${3}_U.fastq
cat ${TMPDIR}/${3}_2U.fastq >> ${TMPDIR}/${3}_U.fastq
pigz -p 5 ${TMPDIR}/${3}_U.fastq
FA_REF=$(basename "$2")
##'-----------------------------------------------------------------------------------------#

##'Run BWA MEM With Unpaired Reads
##'-----------------------------------------------------------------------------------------#
bwa mem \
        -t 5 \
        -M \
        -R ${1} \
        -p \
        ${2} \
        ${TMPDIR}/${3}_U.fastq.gz > ${TMPDIR}/${3}'_U_BWA.sam'
##'-----------------------------------------------------------------------------------------#

##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${3}'_U_BWA.sam' ${5}/Alignment/Unpaired
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Unpaired Reads Aligned" >> ${5}/${3}'.log'
##'-----------------------------------------------------------------------------------------#
