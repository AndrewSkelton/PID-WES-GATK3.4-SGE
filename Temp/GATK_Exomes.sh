#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Running GATK's Haplotype Caller with Families and        |
#                Singletons                                                                 |
#  Inputs      : BAM Alignment Files                                                        |
#  Output      : VCF Files                                                                  |
#  Modules     : Manditory: GATK Haplotype Caller                                           |
#-------------------------------------------------------------------------------------------#

##'Set Base Directory and Capture Kits
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/Exome_Project"
SCRIPTS=${PROJ_BASE}/Scripts
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19"

##'Older Samples - Still to be organised
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/old_samples/Louise"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/old_samples/Rafi"
# CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV1/S0274956_Covered.bed" #SureSelect V1
# CAP_KIT="/home/nas151/Agilent_SureSelect_Exome50MB/S04380110_Covered.bed" #SureSelect 50MB

##'AROS Batches
# BASE_DIR="/home/nas151/WORKING_DATA/Exome_Project/SamplePreprocessing/A2463/Batch_113_1"
# BATCH="A2463_Batch_113_1"

# BASE_DIR="/home/nas151/WORKING_DATA/Exome_Project/SamplePreprocessing/A2463/Batch_116_1"
# BATCH="A2463_Batch_116_1"

#Illumina Nextera
# CAP_KIT=${PROJ_BASE}/Capture_Kits/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed

# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_1"
# BATCH="A1969_Batch_1"

# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_2"
# BATCH="A1969_Batch_2"

# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_3"
# BATCH="A1969_Batch_3"
FAM_BASE_DIR=${PROJ_BASE}/FamilyAnalysis/DEC15
SIN_BASE_DIR=${PROJ_BASE}/SingletonAnalysis/DEC15
BATCH="DEC15"
#SureSelect V5
CAP_KIT=${PROJ_BASE}/Capture_Kits/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed
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

##'Loop Through Each Sample
##'-----------------------------------------------------------------------------------------#
for i in ${FAM_BASE_DIR}/*
do
##'-----------------------------------------------------------------------------------------#

##'Get Sample ID
##'-----------------------------------------------------------------------------------------#
FAMILY_ID=$(basename "$i")
# echo ${FAMILY_ID}
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
if [ ! -f "${i}/${SAMPLE_ID}_Preprocessing.log" ]; then
  echo "Starting to Genotype Sample "${FAMILY_ID} > ${i}/${FAMILY_ID}.log
else
  echo "Resuming Genotyping at "${date} >> ${i}/${FAMILY_ID}.log
fi
##'-----------------------------------------------------------------------------------------#


##'Run GATK Haplotype Caller
##' $1 - Family ID
##' $2 - Family Analysis Base Path
##' $3 - Reference Fasta
##' $4 - GATK Bundle Path
##' $5 - Capture Kit
##' $6 - dbSNP
##'---------------------------------------------------------------------------------------#
qsub -N ${FAMILY_ID}'_GATK_HC' \
        ${SCRIPTS}/Modules/Module_GATKHC.sh \
        ${FAMILY_ID} \
        ${i} \
        ${REF_FA} \
        ${BUNDLE} \
        ${CAP_KIT} \
        ${DBSNP}
##'---------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
# qsub -N ${FAMILY_ID}'_GATK_VR_SNP' \
#         -hold_jid ${FAMILY_ID}'_GATK_HC' \
#           ${SCRIPTS}/Modules/Module_GATKVRSNP.sh \
#           ${FAMILY_ID} \
#           ${i} \
#           ${REF_FA} \
#           ${BUNDLE} \
#           ${CAP_KIT} \
#           ${DBSNPEX} \
#           ${PHASE1SNPS} \
#           ${OMNI} \
#           ${HAPMAP}
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
# qsub -N ${FAMILY_ID}'_GATK_VR_INDEL' \
#         -hold_jid ${FAMILY_ID}'_GATK_HC' \
#           ${SCRIPTS}/Modules/Module_GATKVRINDEL.sh \
#           ${FAMILY_ID} \
#           ${i} \
#           ${REF_FA} \
#           ${BUNDLE} \
#           ${CAP_KIT} \
#           ${DBSNPEX} \
#           ${MILLS}
##'-----------------------------------------------------------------------------------------#


##'End Loop
##'-----------------------------------------------------------------------------------------#
done
##'-----------------------------------------------------------------------------------------#


##'Loop Through Each Singleton
##'-----------------------------------------------------------------------------------------#
for i in ${SIN_BASE_DIR}/*
do
##'-----------------------------------------------------------------------------------------#

##'Get Sample ID
##'-----------------------------------------------------------------------------------------#
FAMILY_ID=$(basename "$i")
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
if [ ! -f "${i}/${SAMPLE_ID}_Preprocessing.log" ]; then
  echo "Starting to Genotype Sample "${FAMILY_ID} > ${i}/${FAMILY_ID}.log
else
  echo "Resuming Genotyping at "${date} >> ${i}/${FAMILY_ID}.log
fi
##'-----------------------------------------------------------------------------------------#


##'Run GATK Haplotype Caller
##' $1 - Family ID
##' $2 - Family Analysis Base Path
##' $3 - Reference Fasta
##' $4 - GATK Bundle Path
##' $5 - Capture Kit
##' $6 - dbSNP
##'---------------------------------------------------------------------------------------#
qsub -N ${FAMILY_ID}'_GATK_HC' \
        ${SCRIPTS}/Modules/Module_GATKHC.sh \
        ${FAMILY_ID} \
        ${i} \
        ${REF_FA} \
        ${BUNDLE} \
        ${CAP_KIT} \
        ${DBSNP}
##'---------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
# qsub -N ${FAMILY_ID}'_GATK_VR_SNP' \
#         -hold_jid ${FAMILY_ID}'_GATK_HC' \
#           ${SCRIPTS}/Modules/Module_GATKVRSNP.sh \
#           ${FAMILY_ID} \
#           ${i} \
#           ${REF_FA} \
#           ${BUNDLE} \
#           ${CAP_KIT} \
#           ${DBSNPEX} \
#           ${PHASE1SNPS} \
#           ${OMNI} \
#           ${HAPMAP}
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
# qsub -N ${FAMILY_ID}'_GATK_VR_INDEL' \
#         -hold_jid ${FAMILY_ID}'_GATK_HC' \
#           ${SCRIPTS}/Modules/Module_GATKVRINDEL.sh \
#           ${FAMILY_ID} \
#           ${i} \
#           ${REF_FA} \
#           ${BUNDLE} \
#           ${CAP_KIT} \
#           ${DBSNPEX} \
#           ${MILLS}
##'-----------------------------------------------------------------------------------------#


##'End Loop
##'-----------------------------------------------------------------------------------------#
done
##'-----------------------------------------------------------------------------------------#
