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
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use bedtools to get sex chromosome statistics from Clean Alignment         |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Capture Kit                                                                |
#  Resources   : Memory     - 5GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/bedtools/2.25
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node Scratch Space
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}*_Clean_GATK.* ${TMPDIR}
cp ${3} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Subset Capture Kit for X and Y
##'-----------------------------------------------------------------------------------------#
CAPKIT=$(basename "$3")
touch ${TMPDIR}/CapKitTmp.bed
grep "chrX" ${CAPKIT} >> ${TMPDIR}/CapKitTmp.bed
grep "chrY" ${CAPKIT} >> ${TMPDIR}/CapKitTmp.bed
##'-----------------------------------------------------------------------------------------#


##'Run BedTools to identify intersects
##'-----------------------------------------------------------------------------------------#
bedtools coverage \
         -hist \
         -a ${TMPDIR}/CapKitTmp.bed  \
         -b ${TMPDIR}/${1}_Clean_GATK.bam > ${TMPDIR}/${1}_Gender.cov
##'-----------------------------------------------------------------------------------------#


##'Make Directory Structure and Copy Results back to Lustre
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Checks/
mv ${TMPDIR}/${1}_Gender.cov ${2}/Checks/
##'-----------------------------------------------------------------------------------------#
