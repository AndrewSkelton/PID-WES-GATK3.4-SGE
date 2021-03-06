#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=30G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run Picard Tools, Mark Duplicates, Index                                   |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 30GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/picard/1.130
module add apps/samtools/1.3.1
##'-----------------------------------------------------------------------------------------#


##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Paired/${1}_P_BWA.bam ${TMPDIR}
samtools index ${TMPDIR}/${1}_P_BWA.bam
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools - Sort and Convert to BAM, then remove any left over SAMs on scratch
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  SortSam \
                                  INPUT=${TMPDIR}/${1}_P_BWA.bam \
                                  OUTPUT=${TMPDIR}/${1}'.bam' \
                                  SORT_ORDER=coordinate
rm ${TMPDIR}/${1}_P_BWA.bam
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Bam Sorted" >> ${3}
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools - Mark Duplicate reads (PCR and Optical driven)
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  MarkDuplicates \
                                  INPUT=${TMPDIR}/${1}'.bam' \
                                  OUTPUT=${TMPDIR}/${1}'_Marked.bam' \
                                  METRICS_FILE=${TMPDIR}/${1}'_metrics.txt'
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Duplicates Marked" >> ${3}
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools - Create Bam index for clean alignment
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  BuildBamIndex \
                                  INPUT=${TMPDIR}/${1}'_Marked.bam'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Clean Index Created" >> ${3}
##'-----------------------------------------------------------------------------------------#


##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}_Marked.* ${2}/Alignment/Clean
mv ${TMPDIR}/${1}_metrics.txt ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Moved Alignment to Cluster Storage from Scratch" >> ${3}
echo $(date)" : ${1} Picard Tools Complete" >> ${3}
##'-----------------------------------------------------------------------------------------#
