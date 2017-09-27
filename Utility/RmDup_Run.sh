#!/bin/bash

WORKING_DIR="/home/nas151/WORKING_DATA/Exome_Project/Preprocessing/2017/2017_06_Manchester/"
SCRIPTS="/home/nas151/WORKING_DATA/Exome_Project/Scripts/Utility"

for i in `find $WORKING_DIR -type f -name "*Clean_GATK.bam"`
do
  DIR=$(dirname "${i}")
  DIR=$(dirname "${DIR}")
  FILE_=$(basename "${i}")
  FILE_IN=${FILE_%%_*}
  FILE_OUT=${FILE_IN}_Clean_GATK_DeDup.bam
  FILE_OUT_NoExt=${FILE_IN}_Clean_GATK_DeDup.
  DIR_OUT=${DIR}/DeDup/
  FILEDIR_OUT=${DIR_OUT}${FILE_OUT}

  mkdir ${DIR_OUT}
  qsub -N "DeDup_${FILE_IN}" \
      ${SCRIPTS}/RmDup.sh ${i} ${FILE_} ${DIR_OUT} ${FILE_OUT} ${FILE_OUT_NoExt}
done
