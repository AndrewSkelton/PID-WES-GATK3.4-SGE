#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Joint Genotyping Whole Exome Sequencing (WES) Data       |
#                Family Mode                                                                |
#  Inputs      : Clean BAM Files, Ped File                                                  |
#  Output      :                                                                            |
#  Modules     :                                                                            |
#-------------------------------------------------------------------------------------------#



##'Set Base Directory and Capture Kits
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/Exome_Project/"
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19"
VERSION="2016JUNE"
BASE_DIR="${PROJ_BASE}/Preprocessing"
SCRIPTS=${PROJ_BASE}/Scripts
DIR_OUT=${PROJ_BASE}/JointCalling/
LOG=${PROJ_BASE}JointCalling/${VERSION}/JointCalling.log
CAP_KIT=${PROJ_BASE}/Capture_Kits/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed

mkdir -p ${DIR_OUT}/${VERSION}/Raw_Callset
echo "*** New Joint Calling Run ***" >> ${LOG}
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



##'Build File Path Index
##'---------------------------------------------------------------------------------------#
# while read lineB
# do
#   SAM_ID=$(echo "${lineB}" | cut -f 2)
#   SAM_PATH=`find ${BASE_DIR} -type d -name "Sample_${SAM_ID}"`
#   SAM_PATH_ARRAY+=(${SAM_PATH})
# done < ${PROJ_BASE}Scripts/RefFiles/Samples2.ped
# CAP_KIT_IN=${PROJ_BASE}/Capture_Kits/SS_V5_NRC_Merge/SS_V5_NRC_Merge.bed
# printf "%s\n" "${SAM_PATH_ARRAY[@]}" > ${DIR_OUT}/${VERSION}/Paths_in.txt
##'---------------------------------------------------------------------------------------#



##'Run GATK In gVCF Mode for Families and Single Samples. Pedigree data included.
#  Input 1     : GATK Bundle Path
#  Input 2     : Paths In
#  Input 3     : Output Directory
#  Input 4     : Ped File
##'-----------------------------------------------------------------------------------------#
qsub -N "GATK_Joint_Calling_${VERSION}" \
   -hold_jid '*gVCF*' \
        ${SCRIPTS}/Modules/Module_Genotyping_gVCF.sh \
        ${BUNDLE} \
        ${DIR_OUT}/${VERSION}/Paths_in.txt \
        ${DIR_OUT}/${VERSION}/Raw_Callset \
        ${PROJ_BASE}Scripts/RefFiles/Samples.ped \
        ${LOG} \
        ${CAP_KIT}
##'-----------------------------------------------------------------------------------------#



##'Run VQSR for raw callset from Joint Genotyping - SNPs
#  Input 1     : GATK Bundle Path
#  Input 2     : Raw Callset Folder
#  Input 3     : Ped File
#  Input 4     : Log File
#  Input 5     : Training Set - dbSNP Excluding 129
#  Input 6     : Training Set - 1000 Genomes, Phase 1 snps
#  Input 7     : Training Set - Omni
#  Input 8     : Training Set - HapMap
#  Input 9     : VQSR Output Folder
##'-----------------------------------------------------------------------------------------#
qsub -N "GATK_Joint_VQSR_SNP_${VERSION}" \
   -hold_jid 'GATK_Joint_Calling_*' \
       ${SCRIPTS}/Modules/Module_VQSR_SNP_gVCF.sh \
       ${BUNDLE} \
       ${DIR_OUT}/${VERSION}/Raw_Callset \
       ${PROJ_BASE}Scripts/RefFiles/Samples.ped \
       ${LOG} \
       ${DBSNPEX} \
       ${PHASE1SNPS} \
       ${OMNI} \
       ${HAPMAP} \
       ${DIR_OUT}/${VERSION}/Raw_Callset/VQSR \
       ${CAP_KIT}
##'-----------------------------------------------------------------------------------------#



##'Run VQSR for raw callset from Joint Genotyping - Indels
#  Input 1     : GATK Bundle Path
#  Input 2     : Raw Callset Folder
#  Input 3     : Ped File
#  Input 4     : Log File
#  Input 5     : Training Set - dbSNP Excluding 129
#  Input 6     : Training Set - 1000 Genomes, Phase 1 snps
#  Input 7     : Training Set - Omni
#  Input 8     : Training Set - HapMap
#  Input 9     : VQSR Output Folder
##'-----------------------------------------------------------------------------------------#
qsub -N "GATK_Joint_VQSR_Indel_${VERSION}" \
   -hold_jid 'GATK_Joint_VQSR_SNP_*' \
       ${SCRIPTS}/Modules/Module_VQSR_Indels_gVCF.sh \
       ${BUNDLE} \
       ${DIR_OUT}/${VERSION}/Raw_Callset \
       ${PROJ_BASE}Scripts/RefFiles/Samples.ped \
       ${LOG} \
       ${DBSNPEX} \
       ${MILLS} \
       ${DIR_OUT}/${VERSION}/Raw_Callset/VQSR \
       ${CAP_KIT}
##'-----------------------------------------------------------------------------------------#
