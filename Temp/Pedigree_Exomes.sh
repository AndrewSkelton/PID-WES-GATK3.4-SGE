#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Genotyping Whole Exome Sequencing (WES) Data             |
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
LOG=${PROJ_BASE}VarCalling/PedigreeCheck.log
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



##'Rename based on naming convention
##' $1 - Path to preprocessing base directory
##' $2 - Filename Map
##'---------------------------------------------------------------------------------------#
sh ${SCRIPTS}/Modules/Module_PedigreeCheck.sh \
        ${PROJ_BASE}SamplePreprocessing/ \
        ${PROJ_BASE}Scripts/RefFiles/ \
        ${PROJ_BASE}VarCalling/
##'---------------------------------------------------------------------------------------#



##'Loop Through Master Ped File
#  Check for any Samples with no capture kits assigned
##'---------------------------------------------------------------------------------------#
while read line
do
  FAM_ID=$(echo "${line}" | cut -f 1)
  SAM_ID=$(echo "${line}" | cut -f 2)
  SAM_PATH=`find ${BASE_DIR} -type d -name "Sample_${SAM_ID}"`

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
##'---------------------------------------------------------------------------------------#



##'Run GATK using the Haplotype Caller (none gVCF Mode) - Sample Level
#  Input 1     : GATK Bundle Path
#  Input 2     : Sample ID
#  Input 3     : Sample's root Preprocessing directory
#  Input 4     : Capture Kit
#  Input 5     : DBSNP Reference
##'-----------------------------------------------------------------------------------------#
# if ! ls ${SAM_PATH}/GATK/${SAM_ID}.vcf 1> /dev/null 2>&1; then
# qsub -N "GATK_HC_Single_Sample_${SAM_ID}" \
#         ${SCRIPTS}/Modules/Module_HaplotypeCaller_Sample.sh \
#         ${BUNDLE} \
#         ${SAM_ID} \
#         ${SAM_PATH} \
#         ${CAP_KIT_IN} \
#         ${DBSNP}
# fi
##'-----------------------------------------------------------------------------------------#



# if ! ls ${SAM_PATH}/GATK/${SAM_ID}_SNPs_Selected.vcf 1> /dev/null 2>&1; then
#   if ! ls ${SAM_PATH}/GATK/${SAM_ID}_Indels_Selected.vcf 1> /dev/null 2>&1; then
    ##'Run GATK using the Variant Recalibrator - Sample Level, SNPs
    #  Input 1     : GATK Bundle Path
    #  Input 2     : Sample ID
    #  Input 3     : Sample's root Preprocessing directory
    #  Input 4     : Capture Kit
    #  Input 5     : Training Set - dbSNP Excluding 129
    #  Input 6     : Training Set - 1000 Genomes, Phase 1 snps
    #  Input 7     : Training Set - Omni
    #  Input 8     : Training Set - HapMap
    ##'-----------------------------------------------------------------------------------------#
    # qsub -N "GATK_HC_Single_Sample_SNP_${SAM_ID}" \
    #    -hold_jid "GATK_HC_Single_Sample_${SAM_ID}" \
    #         ${SCRIPTS}/Modules/Module_VariantRecalibrator_SNP_Sample.sh \
    #         ${BUNDLE} \
    #         ${SAM_ID} \
    #         ${SAM_PATH} \
    #         ${CAP_KIT_IN} \
    #         ${DBSNPEX} \
    #         ${PHASE1SNPS} \
    #         ${OMNI} \
    #         ${HAPMAP}
    ##'-----------------------------------------------------------------------------------------#



    ##'Run GATK using the Variant Recalibrator - Sample Level, Indels
    #  Input 1     : GATK Bundle Path
    #  Input 2     : Sample ID
    #  Input 3     : Sample's root Preprocessing directory
    #  Input 4     : Capture Kit
    #  Input 5     : Training Set - dbSNP Excluding 129
    #  Input 6     : Training Set - Mills
    ##'-----------------------------------------------------------------------------------------#
    # qsub -N "GATK_HC_Single_Sample_Indel_${SAM_ID}" \
    #    -hold_jid "GATK_HC_Single_Sample_${SAM_ID}" \
    #         ${SCRIPTS}/Modules/Module_VariantRecalibrator_Indel_Sample.sh \
    #         ${BUNDLE} \
    #         ${SAM_ID} \
    #         ${SAM_PATH} \
    #         ${CAP_KIT_IN} \
    #         ${DBSNPEX} \
    #         ${MILLS}
    ##'-----------------------------------------------------------------------------------------#
#   fi
# fi



##'Loop Through Master Ped File
##'---------------------------------------------------------------------------------------#
# done < ${PROJ_BASE}Scripts/RefFiles/Samples.ped
##'---------------------------------------------------------------------------------------#
