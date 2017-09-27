#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Description : Parent Script for Analysis of Whole Exome Sequencing (WES) Data            |
#-------------------------------------------------------------------------------------------#


##'Set Base Directory and Reference Datasets
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/DNA_Sequencing/"
BRIDGE_BASE=${PROJ_BASE}/Bridge/
LOG_DIR=${PROJ_BASE}/Logs/
SCRIPTS=${PROJ_BASE}/Scripts
NOW=$(date +"%Y%m%d")
BUNDLE="/opt/databases/GATK_bundle/2.8/b37/"
MILLS=${BUNDLE}/Mills_and_1000G_gold_standard.indels.b37.vcf
PHASE1INDELS=${BUNDLE}/1000G_phase1.indels.b37.vcf
PHASE1SNPS=${BUNDLE}/1000G_phase1.snps.high_confidence.b37.vcf
OMNI=${BUNDLE}/1000G_omni2.5.b37.vcf
HAPMAP=${BUNDLE}/hapmap_3.3.b37.vcf
DBSNP=${BUNDLE}/dbsnp_138.b37.vcf
DBSNPEX=${BUNDLE}/dbsnp_138.b37.excluding_sites_after_129.vcf
REF_FA=${BUNDLE}/human_g1k_v37.fasta
PED_FILE=${BRIDGE_BASE}/Genotyping/Pedigree/master.ped
PADDING_MIN=75
CAP_KIT="${PROJ_BASE}/Capture_Kits/SureSelectV5_Union_RapidCapture_b37.bed"

echo "$(date) : Starting Genotype Run" > ${LOG_DIR}/Genotype_${NOW}.log
mkdir -p ${BRIDGE_BASE}/Genotyping/Pedigree/
##'-----------------------------------------------------------------------------------------#


##' Validate Pedigree File
##'-----------------------------------------------------------------------------------------#
# module add apps/R/3.4.0
# Rscript ${SCRIPTS}/Modules/Module_PedigreeValidate.R
##'-----------------------------------------------------------------------------------------#


##' Submit CombineGVCFs Script to Queue
##' $1 - GATK Bundle
##' $2 - Output Directory
##' $3 - gVCF Directory
##' $4 - Pedigree File
##' $5 - Log File
##' $6 - Capture Kit
##' $7 - Minimum Padding
##'-----------------------------------------------------------------------------------------#
# qsub -N "JC_GATK_Joint_Calling" \
#         -hold_jid "MA_*" \
#           ${SCRIPTS}/Modules/Module_Genotyping_gVCF.sh \
#           ${BUNDLE} \
#           ${BRIDGE_BASE}/Genotyping/ \
#           ${BRIDGE_BASE}/gVCF_Combined/ \
#           ${PED_FILE} \
#           ${LOG_DIR}/Genotype_${NOW}.log \
#           ${CAP_KIT} \
#           ${PADDING_MIN}
##'-----------------------------------------------------------------------------------------#


##' Submit VQSR Script to Queue
##' $1  - GATK Bundle
##' $2  - Output Directory
##' $3  - gVCF Directory
##' $4  - Pedigree File
##' $5  - Log File
##' $6  - Capture Kit
##' $7  - Minimum Padding
##' $8  - SNP Training Set - dbSNP Excluding 129
##' $9  - SNP Training Set - 1000 Genomes, Phase 1 snps
##' $10 - SNP Training Set - Omni
##' $11 - SNP Training Set - HapMap
##'-----------------------------------------------------------------------------------------#
qsub -N "FT_Variant_Refinement" \
        -hold_jid "JC_GATK_Joint_Calling" \
          ${SCRIPTS}/Modules/Module_VQSR.sh \
          ${BUNDLE} \
          ${BRIDGE_BASE}/Genotyping/ \
          ${BRIDGE_BASE}/gVCF_Combined/ \
          ${PED_FILE} \
          ${LOG_DIR}/Genotype_${NOW}.log \
          ${CAP_KIT} \
          ${PADDING_MIN} \
          ${DBSNPEX} \
          ${PHASE1SNPS} \
          ${OMNI} \
          ${HAPMAP} \
          ${MILLS}
##'-----------------------------------------------------------------------------------------#
