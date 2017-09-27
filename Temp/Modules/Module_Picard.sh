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
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run Picard Tools, Join SAM files, Mark Duplicates, Index                   |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Resources   : Memory     - 30GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#

##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/picard/1.130
##'-----------------------------------------------------------------------------------------#

##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Paired/${1}_P_BWA.sam ${TMPDIR}
cp ${2}/Alignment/Unpaired/${1}_U_BWA.sam ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools and Join SAM Files
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  MergeSamFiles \
                                  INPUT=${TMPDIR}/${1}_P_BWA.sam \
                                  INPUT=${TMPDIR}/${1}_U_BWA.sam \
                                  OUTPUT=${TMPDIR}/${1}'_Merged.sam'
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools - Sort and Convert to BAM, then remove any left over SAMs on scratch
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  SortSam \
                                  INPUT=${TMPDIR}/${1}'_Merged.sam' \
                                  OUTPUT=${TMPDIR}/${1}'_Merged.bam' \
                                  SORT_ORDER=coordinate
rm ${TMPDIR}/*.sam
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools - Sort and Convert to BAM, then remove any left over SAMs on scratch
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  MarkDuplicates \
                                  INPUT=${TMPDIR}/${1}'_Merged.bam' \
                                  OUTPUT=${TMPDIR}/${1}'_Merged_Marked.bam' \
                                  METRICS_FILE=${TMPDIR}/${1}'_metrics.txt'
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools - Sort and Convert to BAM, then remove any left over SAMs on scratch
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  BuildBamIndex \
                                  INPUT=${TMPDIR}/${1}'_Merged_Marked.bam'
##'-----------------------------------------------------------------------------------------#

##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}_Merged_Marked.* ${2}/Alignment/Clean
mv ${TMPDIR}/${1}_metrics.txt ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Merged SAM Files" >> ${2}/${1}'.log'
echo $(date)" : Sort and Convert to BAM" >> ${2}/${1}'.log'
echo $(date)" : Mark Duplicates and Index Bam" >> ${2}/${1}'.log'
##'-----------------------------------------------------------------------------------------#
