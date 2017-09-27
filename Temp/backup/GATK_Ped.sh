#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Runner Script for GATK on FMS Cluster                                      |
#-------------------------------------------------------------------------------------------#

##'Set Variables
##'-----------------------------------------------------------------------------------------#
BASE_DIR="/home/nas151/WORKING_DATA/Exomes/DEC15"
BATCH="EXOMEBATCH_DEC15"
CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed"
G_STANDARD="/opt/databases/GATK_bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.vcf"
G_STANDARD_B="/opt/databases/GATK_bundle/2.8/hg19/1000G_phase1.indels.hg19.vcf"
G_STANDARD_C="/opt/databases/GATK_bundle/2.8/hg19/1000G_phase1.snps.high_confidence.hg19.vcf"
G_STANDARD_D="/opt/databases/GATK_bundle/2.8/hg19/1000G_omni2.5.hg19.vcf"
HAP="/opt/databases/GATK_bundle/2.8/hg19/hapmap_3.3.hg19.vcf"
DB_SNP="/opt/databases/GATK_bundle/2.8/hg19/dbsnp_138.hg19.vcf"
DB_SNP_B="/opt/databases/GATK_bundle/2.8/hg19/dbsnp_138.hg19.excluding_sites_after_129.vcf"
REF_FA="/opt/databases/GATK_bundle/2.8/hg19/ucsc.hg19.fasta"
# CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV1/S0274956_Covered.bed" #SureSelect V1
# CAP_KIT="/home/nas151/Agilent_SureSelect_Exome50MB/S04380110_Covered.bed" #SureSelect 50MB
SCRIPTS="/home/nas151/WORKING_DATA/Trios"
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19/"

FAM_IN="B4P11"
FAM_PATH="/home/nas151/WORKING_DATA/Trios/"${FAM_IN}"_Family"
##'-----------------------------------------------------------------------------------------#


##'Run GATK using the Haplotype Caller (none gVCF Mode)
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
# $5 - DB SNP
##'-----------------------------------------------------------------------------------------#
# qsub -N "B4P10_Family_GATK_Pedigree_HC" \
#         $SCRIPTS/HaplotypeCaller_Ped.sh \
#         $BUNDLE \
#         "B4P10_Family" \
#         /home/nas151/WORKING_DATA/Trios/B4P10_Family \
#         $CAP_KIT \
#         $DB_SNP \
#         /home/nas151/WORKING_DATA/Trios/B4P10_Family/B4P10.ped
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
# qsub -N ${FAM_IN}"_Family_GATK_Pedigree_SNP_Recal" \
#      -hold_jid ${FAM_IN}"_Family_GATK_Pedigree_HC" \
#         $SCRIPTS/SNP_Recal_Ped.sh \
#         $BUNDLE \
#         ${FAM_IN}"_Family" \
#         ${FAM_PATH} \
#         $G_STANDARD_C \
#         $DB_SNP_B \
#         $G_STANDARD_D \
#         $HAP \
#         ${FAM_PATH}/${FAM_IN}.ped
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for INDELs
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD_C
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP MAP
##'-----------------------------------------------------------------------------------------#
qsub -N ${FAM_IN}"_Family_GATK_Pedigree_INDEL_Recal" \
     -hold_jid ${FAM_IN}"_Family_GATK_Pedigree_HC" \
        $SCRIPTS/INDEL_Recal_Ped.sh \
        $BUNDLE \
        ${FAM_IN}"_Family" \
        ${FAM_PATH} \
        $G_STANDARD \
        $DB_SNP_B \
        $G_STANDARD_D \
        $HAP \
        ${FAM_PATH}/${FAM_IN}.ped
##'-----------------------------------------------------------------------------------------#
