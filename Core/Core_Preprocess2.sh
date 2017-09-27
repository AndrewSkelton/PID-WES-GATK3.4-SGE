#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Preprocessing Whole Exome Sequencing (WES) Data          |
#-------------------------------------------------------------------------------------------#


##'Set Base Directory and Reference Datasets
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/DNA_Sequencing/"
BRIDGE_BASE=${PROJ_BASE}/Bridge/
LOG_DIR=${PROJ_BASE}/Logs/
SCRIPTS=${PROJ_BASE}/Scripts
BUNDLE="/opt/databases/GATK_bundle/2.8/b37/"
MILLS=${BUNDLE}/Mills_and_1000G_gold_standard.indels.b37.vcf
PHASE1INDELS=${BUNDLE}/1000G_phase1.indels.b37.vcf
PHASE1SNPS=${BUNDLE}/1000G_phase1.snps.high_confidence.b37.vcf
OMNI=${BUNDLE}/1000G_omni2.5.b37.vcf
HAPMAP=${BUNDLE}/hapmap_3.3.b37.vcf
DBSNP=${BUNDLE}/dbsnp_138.b37.vcf
DBSNPEX=${BUNDLE}/dbsnp_138.b37.excluding_sites_after_129.vcf
REF_FA=${BUNDLE}/human_g1k_v37.fasta
##'-----------------------------------------------------------------------------------------#


##'Make Log Files
##'-----------------------------------------------------------------------------------------#
NOW=$(date +"%Y%m%d")
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/Preprocessing_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/BWA_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/Fastqc_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/Picard_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/GATKRecal_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/GATKgVCF_BAM${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/GATKgVCF_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/GenderCov_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/DeDup_${NOW}.log"
echo "Starting a Preprocessing Run..." > "${LOG_DIR}/BridgeMigration_${NOW}.log"
##'-----------------------------------------------------------------------------------------#


##'Loop through Preprocessing by Years (Outer Loop)
##' Testing: for i in ${PROJ_BASE}/'Preprocessing/2014/'
##'-----------------------------------------------------------------------------------------#
for i in ${PROJ_BASE}/'Preprocessing/'*
do
##'-----------------------------------------------------------------------------------------#

  ##'Loop through Preprocessing by Batch Run (1st Inner Loop)
  ##' Testing: for j in ${i}'/July/'
  ##'-----------------------------------------------------------------------------------------#
  for j in ${i}/*
  do
  ##'-----------------------------------------------------------------------------------------#


    ##'Get Batch Settings
    ##'-----------------------------------------------------------------------------------------#
    if [ ! -f ${j}/settings.sh ]; then
      echo "Missing Settings File! - ${j}" >> ${LOG_DIR}/Preprocessing_${NOW}.log
      continue
    fi

    BATCH_YEAR=`basename $i`
    BATCH_RUN=`basename $j`
    source ${j}/settings.sh
    # echo $BATCH_YEAR; echo $BATCH_RUN; echo $CAP_KIT; echo $RG_BATCH; echo $SEQUENCER
    ##'-----------------------------------------------------------------------------------------#


    ##'Loop Through Each Sample (2nd Inner Loop)
    ##'-----------------------------------------------------------------------------------------#
    for k in ${j}/'Sample_'*
    do
      echo $k
    ##'-----------------------------------------------------------------------------------------#


    ##'Get Sample level variables
    ##'-----------------------------------------------------------------------------------------#
    SAMPLE_ID=$(basename "$k")
    SAMPLE_ID="${SAMPLE_ID##*_}"
    FORWARD_READS=`ls $k'/Raw_Data/'*R1*`
    FORWARD_READS=$(basename "$FORWARD_READS")
    REVERSE_READS=`ls $k'/Raw_Data/'*R2*`
    REVERSE_READS=$(basename "$REVERSE_READS")
    ##'-----------------------------------------------------------------------------------------#


    ##'Set ReadGroup String
    ##'-----------------------------------------------------------------------------------------#
    RG='@RG\tID:'${RG_BATCH}'\tSM:'${SAMPLE_ID}'\tPL:Illumina\tLB:'${RG_KIT}'\tPU:'${SEQUENCER}
    ##'-----------------------------------------------------------------------------------------#


    ##'Set Padding Parameter Dynamically by sampling the first 10K lines of the forward reads
    ##'-----------------------------------------------------------------------------------------#
    PADDING_TAR="${k}/Raw_Data/${SAMPLE_ID}_R1.fastq.gz"
    PADDING=$(zcat ${PADDING_TAR} | head -10000 | awk '{print length}' | sort -nr | head -1)
    ##'-----------------------------------------------------------------------------------------#


    ##'Check to see if alignment already exists
    ##'-----------------------------------------------------------------------------------------#
    if ! ls ${k}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.bam 1> /dev/null 2>&1; then
    if ! ls ${BRIDGE_BASE}/Alignment/Clean/${BATCH_YEAR}/${BATCH_RUN}/${SAMPLE_ID}_Clean_GATK.bam 1> /dev/null 2>&1; then
    ##'-----------------------------------------------------------------------------------------#

        ##'Run Fastqc
        ##' $1 - Output Path
        ##' $2 - Sample ID
        ##' $3 - Path to Fastq Files
        ##' $4 - Stage
        ##' $5 - Log File
        ##'-----------------------------------------------------------------------------------------#
        qsub -N "PP_${RG_BATCH}_Fastqc_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_FastqSort_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_Fastqc.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${k}/Raw_Data \
                  "Raw_Data" \
                  ${LOG_DIR}/Fastqc_${NOW}.log
        ##'-----------------------------------------------------------------------------------------#


        ##'Run BWA for Paired Reads
        ##' $1 - Read Group
        ##' $2 - Reference Fasta
        ##' $3 - Sample ID
        ##' $4 - Path to Paired Fastq Files
        ##' $5 - Path to Sample's preprocessing base
        ##' $6 - Log File
        ##'---------------------------------------------------------------------------------------#
        qsub -N "PP_${RG_BATCH}_BWA_P_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_FastqSort_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_BWA_MEM_P.sh \
                  ${RG} \
                  ${REF_FA} \
                  ${SAMPLE_ID} \
                  ${k}/Raw_Data \
                  ${k} \
                  ${LOG_DIR}/BWA_${NOW}.log
        ##'---------------------------------------------------------------------------------------#


        ##'Run Picard Tools to Mark Duplicates
        ##' $1 - Sample ID
        ##' $2 - Path to Sample's preprocessing base
        ##' $3 - Log File
        ##'---------------------------------------------------------------------------------------#
        qsub -N "PP_${RG_BATCH}_Picard_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_BWA_*_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_PicardNT.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${LOG_DIR}/Picard_${NOW}.log
        ##'---------------------------------------------------------------------------------------#


        ##'Run GATK to locally Realign Indels and Perform Qual Score Recalibration
        ##' $1  - Sample ID
        ##' $2  - Path to Sample's preprocessing base
        ##' $3  - Reference Fasta File
        ##' $4  - Mills Truth Set
        ##' $5  - 1KG Phase I Indel Truth Set
        ##' $6  - dbSNP Reference Set
        ##' $7  - Capture Kit
        ##' $8  - GATK Reference Bundle Directory
        ##' $9  - Padding Value
        ##' $10 - Log File
        ##'---------------------------------------------------------------------------------------#
        qsub -N "PP_${RG_BATCH}_GATKRecal_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_Picard_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_GATKRecal.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${REF_FA} \
                  ${MILLS} \
                  ${PHASE1INDELS} \
                  ${DBSNP} \
                  ${CAP_KIT} \
                  ${BUNDLE} \
                  ${PADDING} \
                  ${LOG_DIR}/GATKRecal_${NOW}.log
        ##'---------------------------------------------------------------------------------------#


    ##'Check to see if alignment already exists (close)
    ##'-----------------------------------------------------------------------------------------#
    fi
    fi
    ##'-----------------------------------------------------------------------------------------#


    ##'Run Samtools to Remove Duplicate Reads
    ##' $1 - Clean Bam File
    ##' $2 - Output Directory
    ##' $3 - Filename
    ##' $4 - Log File
    ##'---------------------------------------------------------------------------------------#
    if ! ls ${k}/Alignment/DeDup/${SAMPLE_ID}_DeDup.bam 1> /dev/null 2>&1; then
      if ! ls ${BRIDGE_BASE}/Alignment/DeDup/${BATCH_YEAR}/${BATCH_RUN}/${SAMPLE_ID}_DeDup.bam 1> /dev/null 2>&1; then
        qsub -N "PP_${RG_BATCH}_DeDup_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_GATKRecal_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_RmDup.sh \
                  ${k}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.bam \
                  ${k}/Alignment/DeDup/ \
                  ${SAMPLE_ID}_DeDup.bam \
                  ${LOG_DIR}/DeDup_${NOW}.log
      fi
    fi
    ##'---------------------------------------------------------------------------------------#


    ##'Run GATK In gVCF Mode to get exome wide genotype probabilities
    ##' $1 - Sample ID
    ##' $2 - Path to Sample's preprocessing base
    ##' $3 - Reference Fasta File
    ##' $4 - GATK Reference Bundle Path
    ##' $5 - Capture Kit
    ##' $6 - dbSNP Reference
    ##' $7 - Interval Padding
    ##' $8 - Log File
    ##'---------------------------------------------------------------------------------------#
    if ! ls ${k}/GATK/${SAMPLE_ID}.g.vcf.gz 1> /dev/null 2>&1; then
      if ! ls ${BRIDGE_BASE}/gVCF/${BATCH_YEAR}/${BATCH_RUN}/${SAMPLE_ID}.g.vcf.gz 1> /dev/null 2>&1; then
        qsub -N "PP_${RG_BATCH}_GATKgVCF_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_GATKRecal_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_GATKgVCF.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${REF_FA} \
                  ${BUNDLE} \
                  ${CAP_KIT} \
                  ${DBSNP} \
                  ${PADDING} \
                  ${LOG_DIR}/GATKgVCF_${NOW}.log
      fi
    fi
    ##'---------------------------------------------------------------------------------------#


    ##'Run GATK In gVCF Mode to get Haplotype Assembled Alignment
    ##' $1 - Sample ID
    ##' $2 - Path to Sample's preprocessing base
    ##'---------------------------------------------------------------------------------------#
    if ! ls ${k}/Alignment/HaplotypeAssembled/${SAMPLE_ID}_HaplotypeAssembled.bam 1> /dev/null 2>&1; then
      if ! ls ${BRIDGE_BASE}/Alignment/HaplotypeAssembled/${BATCH_YEAR}/${BATCH_RUN}/${SAMPLE_ID}_HaplotypeAssembled.bam 1> /dev/null 2>&1; then
        qsub -N "PP_${RG_BATCH}_GATKgVCF_BAM_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_GATKRecal_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_GATK_HaplotypeAssembledBam.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${REF_FA} \
                  ${BUNDLE} \
                  ${CAP_KIT} \
                  ${DBSNP} \
                  ${PADDING} \
                  ${LOG_DIR}/GATKgVCF_BAM${NOW}.log
      fi
    fi
    ##'---------------------------------------------------------------------------------------#


    ##'Get Gender coverage from Capture Kits
    ##' $1 - Sample ID
    ##' $2 - Path to Sample's preprocessing base
    ##'---------------------------------------------------------------------------------------#
    if ! ls ${k}/Checks/${SAMPLE_ID}_Gender_SRY.cov 1> /dev/null 2>&1; then
      if ! ls ${BRIDGE_BASE}/SRY/${BATCH_YEAR}/${BATCH_RUN}/${SAMPLE_ID}_Gender_SRY.cov 1> /dev/null 2>&1; then
        qsub -N "PP_${RG_BATCH}_GenderCov_${SAMPLE_ID}" \
                -hold_jid "PP_${RG_BATCH}_GATKRecal_${SAMPLE_ID}" \
                  ${SCRIPTS}/Modules/Module_GenderCov.sh \
                  ${SAMPLE_ID} \
                  ${k} \
                  ${CAP_KIT} \
                  ${LOG_DIR}/GenderCov_${NOW}.log
      fi
    fi
    ##'---------------------------------------------------------------------------------------#


    ##'Close 2nd Inner Loop
    ##'-----------------------------------------------------------------------------------------#
    done
    ##'-----------------------------------------------------------------------------------------#


    ##' Batch Migration to Bridge
    ##' Move Alignments (GATK Read, DeDup, Haplo Assembled)
    ##' Move gVCF
    ##' Move Fastqc Report
    ##' Move SRY Coverate File
    ##' $1 - Bridge Base Directory
    ##' $2 - Log File
    ##' $3 - Batch Year
    ##' $4 - Batch Run
    ##' $5 - Preprocessing Base Directory
    ##'---------------------------------------------------------------------------------------#
    qsub -N "PP_${RG_BATCH}_BridgeMigration" \
            -hold_jid "PP_${RG_BATCH}_*" \
              ${SCRIPTS}/Modules/Module_BridgeMigration.sh \
              ${BRIDGE_BASE} \
              ${LOG_DIR}/BridgeMigration_${NOW}.log \
              ${BATCH_YEAR} \
              ${BATCH_RUN} \
              ${PROJ_BASE}/Preprocessing/
    ##'---------------------------------------------------------------------------------------#


  ##'Close 1st Inner Loop
  ##'-----------------------------------------------------------------------------------------#
  done
  ##'-----------------------------------------------------------------------------------------#


##'Close Outer Loop
##'-----------------------------------------------------------------------------------------#
done
##'-----------------------------------------------------------------------------------------#
