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
#  Description : Map files to their pedigree and dynamically create ped files               |
#  Input       : Base Directory to Batch Preprocessing Directory                            |
#  Input       : File that contains filename mappings                                       |
#  Input       : Base directory for Family Analysis - Archive                               |
#  Input       : Base directory for Family Analysis - Actionable                            |
#  Resources   : Memory     - 1GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


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
    ##' Check if Patient information already exists
    ##'-------------------------------------------------------------------------------------#
    patient_exists=`find ${3} -type d -name "*P${i}*"`
    if [ ! -z "${patient_exists}" ]; then
      # Move folder to Actionable
      # Copy New Bam File
      # Add to ped file
      # Actionable for Genotyping + Downstream
    else
      Paternal=false
      PaternalSampleID="0"
      Maternal=false
      MaternalSampleID="0"
      query_list=`find ${1} -type f -name "*P${i}_*"`
      occurances=`echo $query_list | grep -o ".ba" - | wc -l`

      ##' Check if Patient information already exists
      ##'-----------------------------------------------------------------------------------#
      while read line
      do
        if [ "P${i}" = $(echo "P"`echo "${line}" | cut -f 2 | cut -d 'P' -f 2`) ]; then
          PatientSampleID=$(echo "${line}" | cut -f 1)
          if [ $(echo "${line}" | cut -f 4) = "M" ]; then
            PatientSex="1"
          else
            PatientSex="2"
          fi
        fi
      done < ${2}
      ##'-----------------------------------------------------------------------------------#

      ##' Case: Singleton
      ##'-----------------------------------------------------------------------------------#
      if (( occurances = 1 )); then
        echo "Singleton Match: P${i}"
        mkdir -p ${4}/Singleton/P${i}/Alignments
        touch ${4}/Singleton/P${i}/P${i}.ped
        cp `find ${1} -type f -name "*P${i}_*"` ${4}/Singleton/P${i}/Alignments
        echo -e "B4P${i}\t${5}${PatientSampleID}\t0\t0\t${PatientSex}\t2" > ${4}/Singleton/P${i}/P${i}.ped
      fi
      ##'-----------------------------------------------------------------------------------#

      ##' Case: Trio or Incomplete
      ##'-----------------------------------------------------------------------------------#
      if (( occurances = 6 )); then
        ## Find Maternal Sample, check if variable is empty.
        class_find_maternal=`find ${1} -type f -name "M*P${i}_*"`
        class_find_paternal=`find ${1} -type f -name "F*P${i}_*"`
        class_find_patient=`find ${1} -type f -name "P${i}_*"`
        if [ ! -z "${class_find_maternal}" ] && [ ! -z "${class_find_paternal}" ] && [ ! -z "${class_find_patient}" ]; then
          echo "Trio Match: P${i}"
          mkdir -p ${4}/Singleton/P${i}/Alignments
          cp `find ${1} -type f -name "*P${i}_*"` ${4}/Trios/P${i}/Alignments
        fi
        echo "Trio or Incomplete Match: P${i}"




        mkdir -p ${4}/Singleton/P${i}/Alignments
        touch ${4}/Singleton/P${i}/P${i}.ped
        cp `find ${1} -type f -name "*P${i}_*"` ${4}/Singleton/P${i}/Alignments
        echo -e "B4P${i}\t${5}${PatientSampleID}\t0\t0\t${PatientSex}\t2" > ${4}/Singleton/P${i}/P${i}.ped
      fi
      ##'-----------------------------------------------------------------------------------#

    fi
    ##'-------------------------------------------------------------------------------------#







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

i="1"
class_find_maternal=`find ./ -type f -name "M*P${i}_*"`
class_find_paternal=`find ./ -type f -name "F*P${i}_*"`
class_find_patient=`find ./ -type f -name "*P${i}_*"`
if [ ! -z "${class_find_maternal}" ] && [ ! -z "${class_find_paternal}" ] && [ ! -z "${class_find_patient}" ]; then
  echo "Trio"
else
  echo "Not Trio"
fi
