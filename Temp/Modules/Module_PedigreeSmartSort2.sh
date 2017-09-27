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
#  Input       : Path to Reference Files                                                    |
#  Input       : Base directory for Family Analysis - Archive                               |
#  Input       : Base directory for Family Analysis - Actionable                            |
#  Resources   : Memory     - 1GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#

# foo == $2
# foo="WORKING_DATA/Exome_Project/Scripts/RefFiles/"
# boo == $3
# boo="WORKING_DATA/Exome_Project/FamilyAnalysis/Archive"
# too == $4
# too="WORKING_DATA/Exome_Project/FamilyAnalysis/Actionable"
# yoo == $1
# yoo="WORKING_DATA/Exome_Project/SamplePreprocessing"

mkdir -p ${3}
mkdir -p ${4}

##' Populate the Family and Singleton File Structures
##'-----------------------------------------------------------------------------------------#
SAMPLE_MAP="${2}/SampleMap.txt"
PROBANDS="${2}/ProbandTemp.txt"

# Write out Proband Samples
awk '$5 == 1 {print;}' ${SAMPLE_MAP} > ${PROBANDS}

  ##' Loop through Proband Samples
  ##'---------------------------------------------------------------------------------------#
  while read line
  do
    # echo ${line}
    SAMPLE_ID=$(echo "${line}" | cut -f 1)
    PATERNAL_ID=$(echo "${line}" | cut -f 2)
    MATERNAL_ID=$(echo "${line}" | cut -f 3)
    SAMPLE_GENDER=$(echo "${line}" | cut -f 4)
    PROBAND=$(echo "${line}" | cut -f 5)

    if [ "${SAMPLE_GENDER}" == "M" ]; then
      SAMPLE_GENDER_IN="1"
    else
      SAMPLE_GENDER_IN="2"
    fi

    ARCHIVE_CHECK=`find ${3} -type d -name "${SAMPLE_ID}"`
    if [ ! -z "${ARCHIVE_CHECK}" ]; then
      echo "Sample ${SAMPLE_ID} Already Exists in Archive"
      # Code to deal with existing entries. (Additional Samples)
      # Check to see if the Paternal/ Maternal Samples are the same,
      # If they are: Do Nothing, skip
      # If they're different:
      #   Move Folder to Actionable,
      #   Backup GATK Output,
      #   Regenerate Ped File,
      #   Copy New Source Files Over.
    else
      if [ "${MATERNAL_ID}" == "0" ] && [ "${PATERNAL_ID}" == "0" ]; then

        echo "Singleton: ${SAMPLE_ID}"
        mkdir -p "${4}/Singletons/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${SAMPLE_ID}_*.ba*"` "${4}/Singletons/${SAMPLE_ID}/Alignments"

        echo -e "FAM${SAMPLE_ID}\t${SAMPLE_ID}\t0\t0\t${SAMPLE_GENDER_IN}\t2" > "${4}/Singletons/${SAMPLE_ID}/${SAMPLE_ID}.ped"

      elif [ ! "${MATERNAL_ID}" == "0" ] && [ "${PATERNAL_ID}" == "0" ]; then

        echo "Incomplete Paternal: ${SAMPLE_ID}"
        mkdir -p "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${SAMPLE_ID}_*.ba*"` "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${MATERNAL_ID}_*.ba*"` "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"

        echo -e "FAM${SAMPLE_ID}\t${SAMPLE_ID}\t0\t${MATERNAL_ID}\t${SAMPLE_GENDER_IN}\t2" > "${4}/IncompleteFamilies/${SAMPLE_ID}/${SAMPLE_ID}.ped"
        echo -e "FAM${SAMPLE_ID}\t${MATERNAL_ID}\t0\t0\t2\t1" >> "${4}/IncompleteFamilies/${SAMPLE_ID}/${SAMPLE_ID}.ped"

      elif [ "${MATERNAL_ID}" == "0" ] && [ ! "${PATERNAL_ID}" == "0" ]; then

        echo "Incomplete Maternal: ${SAMPLE_ID}"
        mkdir -p "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${SAMPLE_ID}_*.ba*"` "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${PATERNAL_ID}_*.ba*"` "${4}/IncompleteFamilies/${SAMPLE_ID}/Alignments"

        echo -e "FAM${SAMPLE_ID}\t${SAMPLE_ID}\t${PATERNAL_ID}\t0\t${SAMPLE_GENDER_IN}\t2" > "${4}/IncompleteFamilies/${SAMPLE_ID}/${SAMPLE_ID}.ped"
        echo -e "FAM${SAMPLE_ID}\t${PATERNAL_ID}\t0\t0\t1\t1" >> "${4}/IncompleteFamilies/${SAMPLE_ID}/${SAMPLE_ID}.ped"

      else

        echo "Trio: ${SAMPLE_ID}"
        mkdir -p "${4}/Trios/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${SAMPLE_ID}_*.ba*"` "${4}/Trios/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${PATERNAL_ID}_*.ba*"` "${4}/Trios/${SAMPLE_ID}/Alignments"
        cp `find ${1} -type f -name "${MATERNAL_ID}_*.ba*"` "${4}/Trios/${SAMPLE_ID}/Alignments"

        echo -e "FAM${SAMPLE_ID}\t${SAMPLE_ID}\t${PATERNAL_ID}\t${MATERNAL_ID}\t${SAMPLE_GENDER_IN}\t2" > "${4}/Trios/${SAMPLE_ID}/${SAMPLE_ID}.ped"
        echo -e "FAM${SAMPLE_ID}\t${PATERNAL_ID}\t0\t0\t1\t1" >> "${4}/Trios/${SAMPLE_ID}/${SAMPLE_ID}.ped"
        echo -e "FAM${SAMPLE_ID}\t${MATERNAL_ID}\t0\t0\t2\t1" >> "${4}/Trios/${SAMPLE_ID}/${SAMPLE_ID}.ped"

      fi
    fi

  done < ${PROBANDS}
  ##'---------------------------------------------------------------------------------------#

rm ${PROBANDS}
##'-----------------------------------------------------------------------------------------#

# find ./ -type f -name "*.bai" -exec sh -c 'd=$(dirname "$1"); f=$(basename "$1"); mv $1 ${d}/"${f#*_}"; ' sh {} \;
