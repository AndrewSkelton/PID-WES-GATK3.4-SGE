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
#  Type        : Gateway Script                                                             |
#  Description : Create PED File from Filemap, and Check for sample's existence             |
#  Version     : 1.0                                                                        |
#  Input       : Base Directory to Batch Preprocessing Directory                            |
#  Input       : Path to Reference Files                                                    |
#  Input       : Log Output Folder                                                          |
#-------------------------------------------------------------------------------------------#



##'Create Folder Structure and output File
##'-----------------------------------------------------------------------------------------#
mkdir -p ${3}
LOG=${3}PedigreeCheck.log
PED=${2}Samples.ped
##'-----------------------------------------------------------------------------------------#


##'Create Folder Structure and output File
##'-----------------------------------------------------------------------------------------#
dos2unix ${2}SampleMap.txt
mac2unix ${2}SampleMap.txt
cp ${2}SampleMap.txt ${2}SampleMap_original.txt
sed '1d' ${2}SampleMap.txt > ${2}/tmpfile; mv ${2}/tmpfile ${2}SampleMap.txt
##'-----------------------------------------------------------------------------------------#


##'Check if Log File Exists
##'-----------------------------------------------------------------------------------------#
if ls ${LOG} 1> /dev/null 2>&1; then
  echo "*** New Run ***" >> ${LOG}
else
  touch ${PED}
  echo "*** New Run ***" >> ${LOG}
fi
##'-----------------------------------------------------------------------------------------#



##'Check if PED File Exists
##'-----------------------------------------------------------------------------------------#
rm ${PED}
touch ${PED}
echo "Removing Old Ped Files... Done." >> ${LOG}
echo "Creating Ped File... Done." >> ${LOG}
##'-----------------------------------------------------------------------------------------#



##' Loop through Samples in filemap
##' Check if P/Maternal Sample Exists
##'   False: Set Entry to 0
##' Recode for Gender
##' Check if File Exists
##'   True: Make Ped Entry
##'   False: Add to Log
##'-----------------------------------------------------------------------------------------#
while read line
do
  FAM_ID=$(echo "${line}" | cut -f 1)
  SAM_ID=$(echo "${line}" | cut -f 2)
  PROBAN=$(echo "${line}" | cut -f 6)
  PAT_ID=$(echo "${line}" | cut -f 3)
  MAT_ID=$(echo "${line}" | cut -f 4)
  SEX=$(echo "${line}" | cut -f 5)
  # echo "${SAM_ID}: ${SEX}"
  if [[ $SEX == *"M"* ]]; then
    SEX="1"
  else
    SEX="2"
  fi

  if [[ $PROBAN == *"0"* ]]; then
    PROBAN="1"
  else
    PROBAN="2"
  fi
  # echo "${SAM_ID}: ${SEX}"

  # echo $FAM_ID
  # if [[ $FAM_ID == "FAM"* ]]; then
  #   echo "Family Sample"
  # else
  #   echo "Singleton Sample"
  # fi

  if [[ $FAM_ID == "FAM"* ]]; then

    if [[ $PAT_ID != "0" ]]; then
      # Check Paternal Sample Exists
      PAT_QUERY=`find ${1} -type f -name "${PAT_ID}.g.vcf" | wc -l`
      if (( PAT_QUERY == 0 )); then
        echo "Pedigree Error: ${SAM_ID} is part of ${FAM_ID}, Paternal Sample: ${PAT_ID} Not Found, setting to 0" >> ${LOG}
        PAT_ID="0"
      fi
    fi

    if [[ $MAT_ID != "0" ]]; then
      # Check Maternal Sample Exists
      MAT_QUERY=`find ${1} -type f -name "${MAT_ID}.g.vcf" | wc -l`
      if (( MAT_QUERY == 0 )); then
        echo "Pedigree Error: ${SAM_ID} is part of ${FAM_ID}, Maternal Sample: ${MAT_ID} Not Found, setting to 0" >> ${LOG}
        MAT_ID="0"
      fi
    fi

    # Check if File Exists
    query_list=`find ${1} -type f -name "${SAM_ID}.g.vcf" | wc -l`
    if (( query_list > 0 )); then
      echo -e "${FAM_ID}\t${SAM_ID}\t${PAT_ID}\t${MAT_ID}\t${SEX}\t${PROBAN}" >> ${PED}
    else
      if [[ ${FAM_ID} == "FAM"* ]]; then
        echo "Sample Missing: *WARNING* ${SAM_ID} is part of ${FAM_ID}" >> ${LOG}
      else
        echo "Sample Missing: ${SAM_ID}" >> ${LOG}
      fi
    fi
  fi

  if [[ $FAM_ID == "SGL"* ]]; then
    query_list=`find ${1} -type f -name "${SAM_ID}.g.vcf" | wc -l`
    if (( query_list > 0 )); then
      echo -e "${FAM_ID}\t${SAM_ID}\t${PAT_ID}\t${MAT_ID}\t${SEX}\t${PROBAN}" >> ${PED}
    else
      echo "Sample Missing: *WARNING* ${SAM_ID}" >> ${LOG}
    fi
  fi

done < ${2}SampleMap.txt
##'-----------------------------------------------------------------------------------------#
