#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=50G
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
module add apps/bedtools/2.20.1
module add apps/samtools/1.3
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node Scratch Space
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}*_Clean_GATK.* ${TMPDIR}
cp ${3} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Subset Capture Kit for X and Y
##'-----------------------------------------------------------------------------------------#
CAPKIT=$(basename "$3")
grep "chrX" ${TMPDIR}/${CAPKIT} > ${TMPDIR}/CapKitTmpX.bed
grep "chrY" ${TMPDIR}/${CAPKIT} > ${TMPDIR}/CapKitTmpY.bed
ls -lh ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Subset Bam
##'-----------------------------------------------------------------------------------------#
samtools view ${TMPDIR}/${1}_Clean_GATK.bam chrX -b > ${TMPDIR}/${1}_ChrX.bam
samtools view ${TMPDIR}/${1}_Clean_GATK.bam chrY -b > ${TMPDIR}/${1}_ChrY.bam
##'-----------------------------------------------------------------------------------------#


##'Run BedTools to identify intersects
##'-----------------------------------------------------------------------------------------#
bedtools coverage \
         -hist \
         -a ${TMPDIR}/CapKitTmpX.bed  \
         -b ${TMPDIR}/${1}_ChrX.bam > ${TMPDIR}/${1}_Gender_ChrX.cov

bedtools coverage \
        -hist \
        -a ${TMPDIR}/CapKitTmpY.bed  \
        -b ${TMPDIR}/${1}_ChrY.bam > ${TMPDIR}/${1}_Gender_ChrY.cov
##'-----------------------------------------------------------------------------------------#


##'Make Directory Structure and Copy Results back to Lustre
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Checks/
mv ${TMPDIR}/${1}_Gender_Chr*.cov ${2}/Checks/
##'-----------------------------------------------------------------------------------------#
