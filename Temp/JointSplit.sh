#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Split VCF File                                                             |
#  Inputs      : Clean BAM Files, Ped File                                                  |
#  Output      :                                                                            |
#  Modules     :                                                                            |
#-------------------------------------------------------------------------------------------#



module add apps/gatk/3.4-protected



##'Set Base Directory and Capture Kits
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/Exome_Project/"
SCRIPTS=${PROJ_BASE}/Scripts
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19"
VERSION="2016MAY"
OUT_DIR="${PROJ_BASE}/JointCalling/${VERSION}/Filtered_Results/"
IN_DIR="${PROJ_BASE}/JointCalling/${VERSION}/Raw_Callset/VQSR/"
LOG=${PROJ_BASE}JointCalling/${VERSION}/JointCalling.log
##'-----------------------------------------------------------------------------------------#



##'Create Directory Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${OUT_DIR}SNPs ${OUT_DIR}Indels
##'-----------------------------------------------------------------------------------------#



##'Split SNPs
##'-----------------------------------------------------------------------------------------#
list=(`vcfutils.pl listsam ${IN_DIR}VQSR_SNPs.vcf`)
for i in ${list[@]}
do
    vcfutils.pl subsam ${IN_DIR}VQSR_SNPs.vcf ${i} > ${OUT_DIR}SNPs/${i}.all.vcf
    java -Xmx4g -jar \
        ${GATK_ROOT}/GenomeAnalysisTK.jar \
          -T SelectVariants \
          -R ${BUNDLE}/ucsc.hg19.fasta \
          --downsampling_type NONE \
          --variant ${OUT_DIR}SNPs/${i}.all.vcf \
          -select "vc.isNotFiltered()" \
          -selectType SNP \
          --out ${OUT_DIR}SNPs/${i}.filtered.vcf
    rm ${OUT_DIR}SNPs/${i}.all.vcf
done
##'-----------------------------------------------------------------------------------------#




##'Split Indels
##'-----------------------------------------------------------------------------------------#
list=(`vcfutils.pl listsam ${IN_DIR}VQSR_INDELs.vcf`)
for i in ${list[@]}
do
    vcfutils.pl subsam ${IN_DIR}VQSR_INDELs.vcf ${i} > ${OUT_DIR}Indels/${i}.all.vcf
    java -Xmx4g -jar \
        ${GATK_ROOT}/GenomeAnalysisTK.jar \
          -T SelectVariants \
          -R ${BUNDLE}/ucsc.hg19.fasta \
          --downsampling_type NONE \
          --variant ${OUT_DIR}Indels/${i}.all.vcf \
          -select "vc.isNotFiltered()" \
          -selectType INDEL \
          --out ${OUT_DIR}Indels/${i}.filtered.vcf
    rm ${OUT_DIR}Indels/${i}.all.vcf
done
##'-----------------------------------------------------------------------------------------#
