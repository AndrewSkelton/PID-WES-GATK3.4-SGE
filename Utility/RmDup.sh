#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=10G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use Samtools to remove PCR Duplicate Reads                                 |
#  Input       : Clean Bam File                                                             |
#  Input       : Output Bam File                                                            |
#  Input       : Filenames                                                                  |
#  Resources   : Memory     - 10GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/samtools/1.3.1
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${1} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Use SamTools to remove PCR duplicates
##'Samtools view to read in the BAM file, -F 0x0400 removes any flags marked as duplcates
##'-----------------------------------------------------------------------------------------#
samtools view -b -F 0x0400 ${TMPDIR}/${2} > ${TMPDIR}/${4}
samtools index ${TMPDIR}/${4}
rm ${TMPDIR}/${2}
##'-----------------------------------------------------------------------------------------#


##'Copy File back to filesystem
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${5}* ${3}
##'-----------------------------------------------------------------------------------------#
