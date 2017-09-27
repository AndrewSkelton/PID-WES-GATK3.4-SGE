#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Genotyping Whole Exome Sequencing (WES) Data             |
#                Family Mode                                                                |
#  Inputs      : Clean BAM Files, Ped File                                                  |
#  Output      :                                                                            |
#  Modules     : Pedigree Check                                                             |
#-------------------------------------------------------------------------------------------#



##'Set Base Directory and Capture Kits
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/Exome_Project/"
SCRIPTS=${PROJ_BASE}/Scripts
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19"
BASE_DIR="${PROJ_BASE}/SamplePreprocessing"
FAM_OUT=${PROJ_BASE}/VarCalling/
LOG=${PROJ_BASE}VarCalling/PedigreeCheck.log

echo "*** New Family Run ***" >> ${LOG}
##'-----------------------------------------------------------------------------------------#



##'Training/ Reference set variables from GATK bundle
##'-----------------------------------------------------------------------------------------#
MILLS=${BUNDLE}/Mills_and_1000G_gold_standard.indels.hg19.vcf
PHASE1INDELS=${BUNDLE}/1000G_phase1.indels.hg19.vcf
PHASE1SNPS=${BUNDLE}/1000G_phase1.snps.high_confidence.hg19.vcf
OMNI=${BUNDLE}/1000G_omni2.5.hg19.vcf
HAPMAP=${BUNDLE}/hapmap_3.3.hg19.vcf
DBSNP=${BUNDLE}/dbsnp_138.hg19.vcf
DBSNPEX=${BUNDLE}/dbsnp_138.hg19.excluding_sites_after_129.vcf
REF_FA=${BUNDLE}/ucsc.hg19.fasta
##'-----------------------------------------------------------------------------------------#



##'Build Family Index
##'---------------------------------------------------------------------------------------#
foo=`grep "FAM" ${PROJ_BASE}Scripts/RefFiles/Samples.ped | cut -f 1 | sort | uniq`
while read -r line
do
  # Check for The Family Directory
  if [ -d "${FAM_OUT}${line}" ]; then
    # Are there New samples?
    CURRENT=`cat ${FAM_OUT}${line}/${line}.ped | wc -l`
    NEW=`grep -P "${line}\t" ${PROJ_BASE}Scripts/RefFiles/Samples.ped | wc -l`

    # echo "Current: ${CURRENT}"
    # echo "NEW: ${NEW}"
    if [ ! "${CURRENT}" = "${NEW}" ]; then
      # echo "Not the Same"
      rm -r ${FAM_OUT}${line}/*
    fi
  else
    mkdir -p ${FAM_OUT}${line}
  fi
  grep -P "${line}\t" ${PROJ_BASE}Scripts/RefFiles/Samples.ped > ${FAM_OUT}${line}/${line}.ped
  CAP_OCC=`grep -P "${line}\t" ${PROJ_BASE}Scripts/RefFiles/SampleMap.txt | cut -f 7 | sort -u | wc -l`
  SAM_PATH_ARRAY=()
  while read lineB
  do
    FAM_ID=$(echo "${lineB}" | cut -f 1)
    SAM_ID=$(echo "${lineB}" | cut -f 2)
    SAM_PATH=`find ${BASE_DIR} -type d -name "Sample_${SAM_ID}"`
    SAM_PATH_ARRAY+=($SAM_PATH)
    while read line_cap
    do
      if [ $(echo "${line_cap}" | cut -f 2) = "${SAM_ID}" ]; then
        CAP_KIT_IN=$(echo "${line_cap}" | cut -f 7)
        if [ "${CAP_KIT_IN}" = "ND" ]; then
          echo "Capture Error: ${SAM_ID} has no capture kit assigned - Check" >> ${LOG}
        fi
        if [ "${CAP_KIT_IN}" = "Nextera Rapid Capture Exome" ]; then
          CAP_KIT_IN=${PROJ_BASE}/Capture_Kits/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed
        fi
        if [ "${CAP_KIT_IN}" = "SureSelect V5" ]; then
          CAP_KIT_IN=${PROJ_BASE}/Capture_Kits/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed
        fi
      fi
    done < ${PROJ_BASE}Scripts/RefFiles/SampleMap.txt
  done < ${FAM_OUT}${line}/${line}.ped
  if (( CAP_OCC > 1 )); then
    echo "Capture Warning: ${line} has multiple capture kit assignments, using Merged bed File" >> ${LOG}
    CAP_KIT_IN=${PROJ_BASE}/Capture_Kits/SS_V5_NRC_Merge/SS_V5_NRC_Merge.bed
  fi
  printf "%s\n" "${SAM_PATH_ARRAY[@]}" > ${FAM_OUT}${line}/Paths_in.txt
##'---------------------------------------------------------------------------------------#



    ##'Run GATK using the Haplotype Caller (none gVCF Mode) - Sample Level
    #  Input 1     : GATK Bundle Path
    #  Input 2     : Sample ID
    #  Input 3     : Sample's root Preprocessing directory
    #  Input 4     : Capture Kit
    #  Input 5     : DBSNP Reference
    #  Input 6     : Ped File
    #  Input 7     : Output Directory
    ##'-----------------------------------------------------------------------------------------#
    if ! ls ${FAM_OUT}${line}/GATK/${line}.vcf 1> /dev/null 2>&1; then
      qsub -N "GATK_HC_Family_${line}" \
              ${SCRIPTS}/Modules/Module_HaplotypeCaller_Family.sh \
              ${BUNDLE} \
              ${line} \
              ${FAM_OUT}${line}/Paths_in.txt \
              ${CAP_KIT_IN} \
              ${DBSNP} \
              ${FAM_OUT}${line}/${line}.ped \
              ${FAM_OUT}${line}
    fi
    ##'-----------------------------------------------------------------------------------------#


    if ! ls ${FAM_OUT}${line}/GATK/${line}_SNPs_Selected.vcf 1> /dev/null 2>&1; then
      if ! ls ${FAM_OUT}${line}/GATK/${line}_Indels_Selected.vcf 1> /dev/null 2>&1; then
        # echo "Indels or SNPs Filtered Files Already Exist"
        ##'Run GATK using the Variant Recalibrator - Sample Level, SNPs
        #  Input 1     : GATK Bundle Path
        #  Input 2     : Family ID
        #  Input 3     : Input Sample Paths
        #  Input 4     : Capture Kit
        #  Input 5     : Training Set - dbSNP Excluding 129
        #  Input 6     : Training Set - 1000 Genomes, Phase 1 snps
        #  Input 7     : Training Set - Omni
        #  Input 8     : Training Set - HapMap
        #  Input 9     : Ped File
        #  Input 10    : Output Directory
        ##'-----------------------------------------------------------------------------------------#
        qsub -N "GATK_Family_SNP_${line}" \
           -hold_jid "GATK_HC_Family_${line}" \
                ${SCRIPTS}/Modules/Module_VariantRecalibrator_SNP_Family.sh \
                ${BUNDLE} \
                ${line} \
                ${FAM_OUT}${line}/Paths_in.txt \
                ${CAP_KIT_IN} \
                ${DBSNPEX} \
                ${PHASE1SNPS} \
                ${OMNI} \
                ${HAPMAP} \
                ${FAM_OUT}${line}/${line}.ped \
                ${FAM_OUT}${line}
        ##'-----------------------------------------------------------------------------------------#


        ##'Run GATK using the Variant Recalibrator - Sample Level, Indels
        #  Input 1     : GATK Bundle Path
        #  Input 2     : Sample ID
        #  Input 3     : Input sample paths
        #  Input 4     : Capture Kit
        #  Input 5     : Training Set - dbSNP Excluding 129
        #  Input 6     : Training Set - Mills
        #  Input 7     : Ped File
        #  Input 8     : Output Directory
        ##'-----------------------------------------------------------------------------------------#
        qsub -N "GATK_Family_Indel_${line}" \
           -hold_jid "GATK_HC_Family_${line}" \
                ${SCRIPTS}/Modules/Module_VariantRecalibrator_Indel_Family.sh \
                ${BUNDLE} \
                ${line} \
                ${FAM_OUT}${line}/Paths_in.txt \
                ${CAP_KIT_IN} \
                ${DBSNPEX} \
                ${MILLS} \
                ${FAM_OUT}${line}/${line}.ped \
                ${FAM_OUT}${line}
        ##'-----------------------------------------------------------------------------------------#
      fi
    fi



##'Loop Through Master Ped File
##'---------------------------------------------------------------------------------------#
done <<< "${foo}"
##'---------------------------------------------------------------------------------------#
