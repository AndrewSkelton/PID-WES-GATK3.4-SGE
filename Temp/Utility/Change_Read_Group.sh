#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Gateway Script                                                             |
#  Description : Run Picard Tools to change the read group                                  |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#-------------------------------------------------------------------------------------------#
module add apps/picard/1.130


##'Set Variables
##'-----------------------------------------------------------------------------------------#
DIR_IN="/home/nas151/WORKING_DATA/Exome_Project/SamplePreprocessing/DEC15/"
SCRIPT_DIR="/home/nas151/WORKING_DATA/Exome_Project/Scripts/Utility/"
RG_IN="DEC15"
#RG='@RG\tID:'${BATCH}'\tSM:'${SAMPLE_ID}'\tPL:illumina\tLB:lib1\tPU:unit1'
##'-----------------------------------------------------------------------------------------#



##'Change Read Group
##'-----------------------------------------------------------------------------------------#
for i in ${DIR_IN}/'Sample_'*
do
  SAMPLE_ID=$(basename "$i")
  SAMPLE_ID="${SAMPLE_ID##*_}"

  # qsub -N "ChangeReadGroup_${SAMPLE_ID}" \
  #         ${SCRIPT_DIR}Change_Read_Group_Run.sh \
  #         ${SAMPLE_ID} \
  #         ${i} \
  #         ${RG_IN}

  # mkdir ${i}/Alignment/Backup
  # mv ${i}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.ba* ${i}/Alignment/Backup

  # mv ${i}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK_RG.bam ${i}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.bam
  # mv ${i}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK_RG.bai ${i}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.bai
done
##'-----------------------------------------------------------------------------------------#
