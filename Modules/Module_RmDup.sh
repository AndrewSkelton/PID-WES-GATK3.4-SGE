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
#  Type        : Cluster Submission Script                                                  |
#  Description : Use Samtools to remove PCR Duplicate Reads                                 |
#  Input       : Clean Bam File                                                             |
#  Input       : Output Bam File                                                            |
#  Input       : Filename                                                                   |
#  Input       : Log File                                                                   |
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


##'Local Filename
##'-----------------------------------------------------------------------------------------#
LOCAL_FILE=$(basename "$1")
##'-----------------------------------------------------------------------------------------#


##'Use SamTools to remove PCR/ Optical duplicates
##'Samtools view to read in the BAM file, -F 0x0400 removes any flags marked as duplcates
##'-----------------------------------------------------------------------------------------#
samtools view -b -F 0x0400 ${TMPDIR}/${LOCAL_FILE} > ${TMPDIR}/${3}
samtools index ${TMPDIR}/${3}
##'-----------------------------------------------------------------------------------------#


##'Copy File back to cluster filesystem
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}
mv ${TMPDIR}/${3}* ${2}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${2}/${3}" ]; then
  echo $(date)" : ${3} DeDuplication Complete" >> ${4}
else
  echo $(date)" : ${3} ERROR - Something wrong with DeDuplication" >> ${4}
fi
##'-----------------------------------------------------------------------------------------#
