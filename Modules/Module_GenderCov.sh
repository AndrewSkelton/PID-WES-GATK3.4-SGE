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
#  Description : Use bedtools to get sex chromosome statistics from Clean Alignment         |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Capture Kit                                                                |
#  Input       : SRY Target                                                                 |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 10GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/bedtools/2.25
module add apps/samtools/1.3
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node Scratch Space
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}*_Clean_GATK.* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Subset Capture Kit for X and Y
##'-----------------------------------------------------------------------------------------#
CAPKIT=$(basename "$3")
SRY=$(basename "$4")
# grep "SRY" ${TMPDIR}/${CAPKIT} > ${TMPDIR}/CapKitTmpSRY.bed
ls -lh ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Subset Bam
##'-----------------------------------------------------------------------------------------#
samtools view ${TMPDIR}/${1}_Clean_GATK.bam chrY -b > ${TMPDIR}/${1}_ChrY.bam
##'-----------------------------------------------------------------------------------------#


##'Run BedTools to identify intersects
##'-----------------------------------------------------------------------------------------#
echo -e "chrY\t2653896\t2656740\tSRY_Target" | \
bedtools coverage -a - \
         -b ${TMPDIR}/${1}_ChrY.bam \
         -d > ${TMPDIR}/${1}_Gender_SRY.cov
##'-----------------------------------------------------------------------------------------#


##'Make Directory Structure and Copy Results back to Lustre
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Checks/
mv ${TMPDIR}/${1}_Gender_SRY.cov ${2}/Checks/
##'-----------------------------------------------------------------------------------------#
