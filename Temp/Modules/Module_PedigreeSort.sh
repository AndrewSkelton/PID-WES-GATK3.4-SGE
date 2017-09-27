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
#  Input       : Path to Family Analysis Base                                               |
#  Input       : Path to singleton base                                                     |
#  Input       : Batch Prefix                                                               |
#  Resources   : Memory     - 1GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##' Read File Map
##'-----------------------------------------------------------------------------------------#
while read line
do
  Current=$(echo "${line}" | cut -f 1)
  New=$(echo "${line}" | cut -f 2)

  # echo Current: ${Current}
  # echo New: ${New}

  mv ${1}/Sample_${Current}/Alignment/Clean/${Current}_Clean_GATK.bam \
     ${1}/Sample_${Current}/Alignment/Clean/${New}_${Current}_Clean_GATK.bam
  mv ${1}/Sample_${Current}/Alignment/Clean/${Current}_Clean_GATK.bai \
     ${1}/Sample_${Current}/Alignment/Clean/${New}_${Current}_Clean_GATK.bai
done < ${2}
##'-----------------------------------------------------------------------------------------#

##' Populate the Family and Singleton File Structures
##'-----------------------------------------------------------------------------------------#

  ##' Find Unique Patient Identifiers
  ##'---------------------------------------------------------------------------------------#
  arr=()
  while read line
  do
    New=$(echo "${line}" | cut -f 2)
    PedSplit=(${New//P/ })
    arr+=("${PedSplit[1]}")
  done < ${2}
  sorted_unique=$(echo "${arr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
  ##'---------------------------------------------------------------------------------------#

  ##' Loop through each patient
  ##'---------------------------------------------------------------------------------------#
  for i in ${sorted_unique[@]}
  do
    Paternal=false
    PaternalSampleID="0"
    Maternal=false
    MaternalSampleID="0"
    query_list=`find ${1} -type f -name "*P${i}_*"`
    occurances=`echo $query_list | grep -o ".ba" - | wc -l`
    while read line
    do
      if [ "B4P${i}" = $(echo "${line}" | cut -f 2) ]; then
        PatientSampleID=$(echo "${line}" | cut -f 1)
        if [ $(echo "${line}" | cut -f 4) = "M" ]; then
          PatientSex="1"
        else
          PatientSex="2"
        fi
      fi
    done < ${2}
    if (( occurances > 2 )); then
      # Make Family Folder and Ped File
      mkdir -p ${3}/B4P${i}/Alignments
      touch ${3}/B4P${i}/B4P${i}.ped
      # Copy over all Family Alignments
      cp `find ${1} -type f -name "*P${i}_*"` ${3}/B4P${i}/Alignments

      # Check for Paternal Sample, get Ped Variables
      if ls ${3}/B4P${i}/Alignments/MB*P${i}_* 1> /dev/null 2>&1; then
        Maternal=true
        while read line
        do
          if [ "MB4P${i}" = $(echo "${line}" | cut -f 2) ]; then
            MaternalSampleID=$(echo "${line}" | cut -f 1)
            # echo "Maternal: ${MaternalSampleID}"
          fi
        done < ${2}
      fi

      # Check for Paternal Sample, get Ped Variables
      if ls ${3}/B4P${i}/Alignments/FB*P${i}_* 1> /dev/null 2>&1; then
        Paternal=true
        while read line
        do
          if [ "FB4P${i}" = $(echo "${line}" | cut -f 2) ]; then
            PaternalSampleID=$(echo "${line}" | cut -f 1)
            # echo "Paternal: ${PaternalSampleID}"
          fi
        done < ${2}
      fi

      # Populate Ped File
      # Patient
      echo -e "B4P${i}\t${5}${PatientSampleID}\t${5}${PaternalSampleID}\t${5}${MaternalSampleID}\t${PatientSex}\t2" > ${3}/B4P${i}/B4P${i}.ped
      # Paternal
      if [ ${Paternal} = true ]; then
        echo -e "B4P${i}\t${5}${PaternalSampleID}\t0\t0\t1\t1" >> ${3}/B4P${i}/B4P${i}.ped
      fi
      # Maternal
      if [ ${Maternal} = true ]; then
        echo -e "B4P${i}\t${5}${MaternalSampleID}\t0\t0\t2\t1" >> ${3}/B4P${i}/B4P${i}.ped
      fi

    else
      # echo "B4P${i} Singleton"
      mkdir -p ${4}/B4P${i}/Alignments
      touch ${4}/B4P${i}/B4P${i}.ped
      echo -e "B4P${i}\t${5}${PatientSampleID}\t0\t0\t${PatientSex}\t2" > ${4}/B4P${i}/B4P${i}.ped
      cp `find ${1} -type f -name "*P${i}_*"` ${4}/B4P${i}/Alignments
    fi
  done
  ##'---------------------------------------------------------------------------------------#
##'-----------------------------------------------------------------------------------------#
