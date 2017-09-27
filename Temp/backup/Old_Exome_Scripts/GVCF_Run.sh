#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Runner Script for GVCFs on FMS Cluster                                     |
#-------------------------------------------------------------------------------------------#

##'Set Variables
##'-----------------------------------------------------------------------------------------#
BASE_DIR="/home/nas151/WORKING_DATA/Exomes"
REF_FA="/opt/databases/GATK_bundle/2.8/hg19/ucsc.hg19.fasta"
SCRIPTS="/home/nas151/WORKING_DATA/Scripts"
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19/"

G_STANDARD="/opt/databases/GATK_bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.vcf"
G_STANDARD_B="/opt/databases/GATK_bundle/2.8/hg19/1000G_phase1.indels.hg19.vcf"
G_STANDARD_C="/opt/databases/GATK_bundle/2.8/hg19/1000G_phase1.snps.high_confidence.hg19.vcf"
G_STANDARD_D="/opt/databases/GATK_bundle/2.8/hg19/1000G_omni2.5.hg19.vcf"
HAP="/opt/databases/GATK_bundle/2.8/hg19/hapmap_3.3.hg19.vcf"
DB_SNP="/opt/databases/GATK_bundle/2.8/hg19/dbsnp_138.hg19.vcf"
DB_SNP_B="/opt/databases/GATK_bundle/2.8/hg19/dbsnp_138.hg19.excluding_sites_after_129.vcf"
##'-----------------------------------------------------------------------------------------#

##'Create Output Directory
##'-----------------------------------------------------------------------------------------#
mkdir $BASE_DIR/'GATK_GVCF'
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
# echo 'FMS Cluster Varient Call Run: GVCFs' > $BASE_DIR/'GATK_GVCF/GATK_GVCF.log'
# echo 'Script Location: '$SCRIPTS >> $BASE_DIR/'GATK_GVCF/GATK_GVCF.log'
# echo 'Reference Fasta: '$REF_FA >> $BASE_DIR/'GATK_GVCF/GATK_GVCF.log'
# echo 'Base Directory: '$BASE_DIR >> $BASE_DIR/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK to Genotype all gVCF Files
# $1 - Bundle Path
# $2 - PWD
##'-----------------------------------------------------------------------------------------#
qsub -N 'GVCF_Genotype' \
        $SCRIPTS/GenotypeGVCFs_Wrapper.sh \
        $BUNDLE \
        $BASE_DIR
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels GVCF
# $1 - Bundle Path
# $2 - PWD
# $3 - G_STANDARD
# $4 - DB_SNP_B
##'-----------------------------------------------------------------------------------------#
qsub -N 'GVCF_Recal_Indels' \
     -hold_jid 'GVCF_Genotype' \
        $SCRIPTS/GVCF_Recal_Indels_Wrapper.sh \
        $BUNDLE \
        $BASE_DIR \
        $G_STANDARD \
        $DB_SNP_B
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels Apply
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
qsub -N 'GVCF_VCF_Recal_Indel_Apply' \
     -hold_jid 'GVCF_Recal_Indels' \
        $SCRIPTS/GVCF_Recal_Indels_Apply_Wrapper.sh \
        $BUNDLE \
        $BASE_DIR \
        $SAMPLE_ID \
        $i
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs GVCF
# $1 - Bundle Path
# $2 - PWD
# $3 - G_STANDARD
# $4 - DB_SNP_B
# $5 - OMNI
# $6 - HAP
##'-----------------------------------------------------------------------------------------#
qsub -N $SAMPLE_ID'GVCF_Recal_SNPs' \
     -hold_jid 'GVCF_Genotype' \
        $SCRIPTS/GVCF_Recal_SNPs_Wrapper.sh \
        $BUNDLE \
        $BASE_DIR \
        $G_STANDARD_C \
        $DB_SNP_B \
        $G_STANDARD_D \
        $HAP
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs Apply
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
qsub -N $SAMPLE_ID'_VCF_Recal_SNP_Apply' \
     -hold_jid $SAMPLE_ID'_VCF_Recal_SNP' \
        $SCRIPTS/GVCF_Recal_SNPs_Apply_Wrapper.sh \
        $BUNDLE \
        $BASE_DIR \
        $SAMPLE_ID
##'-----------------------------------------------------------------------------------------#
