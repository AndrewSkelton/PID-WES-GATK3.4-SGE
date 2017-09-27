#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=1G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Rename Clean Alignments to use pedigree notation                           |
#  Input       : Base Directory to Batch Preprocessing Directory                            |
#  Input       : File that contains filename mappings                                       |
#  Resources   : Memory     - 1GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##' Read File Map
##'-----------------------------------------------------------------------------------------#
while read line
do
  Current=$(echo "${line}" | cut -f 1)
  New=$(echo "${line}" | cut -f 2)
  file_check=`find ${1} -type f -name "*${Current}_Clean_GATK.bam"`
  prefix_check=`echo ${file_check} | grep -o "DEC15" - | wc -l`

  if (( prefix_check > 0 )); then
    prefix="DEC15"
  else
    prefix=""
  fi

  occurances=`echo ${file_check} | grep -o ".bam" - | wc -l`

  if (( occurances = 1 )) && [ ! -z "$file_check" ]; then
    echo "Success: ${New}"
    PATH_TO_DIR=${file_check%/*}
    mv ${PATH_TO_DIR}/${prefix}${Current}_Clean_GATK.bam \
       ${PATH_TO_DIR}/${New}_${Current}_Clean_GATK.bam
    mv ${PATH_TO_DIR}/${prefix}${Current}_Clean_GATK.bai \
       ${PATH_TO_DIR}/${New}_${Current}_Clean_GATK.bai
  else
    echo "Something went wrong: ${occurances}"
    echo ${file_check}
    echo "${New} Could have already been renamed..."
    echo `find ${1} -type f -name "*${New}_${Current}_Clean_GATK.bam"`
  fi

done < ${2}
##'-----------------------------------------------------------------------------------------#
