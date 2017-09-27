#!/bin/bash

# DIR_IN="/home/nas151/WORKING_DATA/DNA_Sequencing/Preprocessing/Bill/2015_05/"
# DIR_OUT="/home/nas151/WORKING_DATA/DNA_Sequencing/Preprocessing/Bill/2015_05/"
# SAMPLES_IN=`ls ${DIR_IN}/*R1*`
#
# for i in $SAMPLES_IN
# do
#   # echo $i
#   SAMPLE_BASE=`basename $i`
#   FILE_OUT_R1=$(echo $SAMPLE_BASE | sed 's/L001_R1/R1/g')
#   FILE_OUT_R2=$(echo $SAMPLE_BASE | sed 's/L001_R1/R2/g')
#   SAMPLE_ID=$(echo $FILE_OUT_R1 | sed 's/_R1.fastq.gz//g')
#   echo $SAMPLE_ID
#
#   # touch ${DIR_OUT}/${FILE_OUT_R1}
#   # touch ${DIR_OUT}/${FILE_OUT_R2}
#   #
#   # for j in ${DIR_IN}/${SAMPLE_ID}*R1*
#   # do
#   #   echo $j
#   #   zcat $j >> ${DIR_OUT}/${FILE_OUT_R1}
#   # done
#   #
#   # for j in ${DIR_IN}/${SAMPLE_ID}*R2*
#   # do
#   #   echo $j
#   #   zcat $j >> ${DIR_OUT}/${FILE_OUT_R2}
#   # done
#
#   mkdir -p ${DIR_OUT}/Sample_${SAMPLE_ID}/Raw_Data/
#   mv ${DIR_OUT}/${SAMPLE_ID}* ${DIR_OUT}/Sample_${SAMPLE_ID}/Raw_Data/
#
# done

DIR_IN="/home/nas151/WORKING_DATA/DNA_Sequencing/Preprocessing/Bill/2016_05/"
for i in ${DIR_IN}/Sample_*
do
  FILE_IN=`ls ${i}/Raw_Data/*R1*`
  SAMPLE_BASE=$(basename $FILE_IN)
  SAMPLE_PATH=$(dirname $FILE_IN)
  FILE_OUT=$(echo $SAMPLE_BASE | sed 's/.gz//g')

  echo ${SAMPLE_PATH}/$SAMPLE_BASE
  echo ${SAMPLE_PATH}/$FILE_OUT

  mv ${SAMPLE_PATH}/$SAMPLE_BASE ${SAMPLE_PATH}/$FILE_OUT
  pigz -p 18 ${SAMPLE_PATH}/$FILE_OUT

  FILE_IN=`ls ${i}/Raw_Data/*R2*`
  SAMPLE_BASE=$(basename $FILE_IN)
  SAMPLE_PATH=$(dirname $FILE_IN)
  FILE_OUT=$(echo $SAMPLE_BASE | sed 's/.gz//g')

  echo ${SAMPLE_PATH}/$SAMPLE_BASE
  echo ${SAMPLE_PATH}/$FILE_OUT

  mv ${SAMPLE_PATH}/$SAMPLE_BASE ${SAMPLE_PATH}/$FILE_OUT
  pigz -p 20 ${SAMPLE_PATH}/$FILE_OUT
done
