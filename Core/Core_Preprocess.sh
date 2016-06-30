#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Parent Script for Preprocessing Whole Exome Sequencing (WES) Data          |
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
#BASE_DIR=${PROJ_BASE}/SamplePreprocessing/Old_Samples
#BATCH="Old_Samples"
#CAP_KIT=${PROJ_BASE}/Capture_Kits/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed

##'AROS Batches
# BASE_DIR="/home/nas151/WORKING_DATA/Exome_Project/SamplePreprocessing/A2463/Batch_113_1"
# BATCH="A2463_Batch_113_1"
# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/A2463/Batch_116_1"
# BATCH="A2463_Batch_116_1"
# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/APR16"
# BATCH="APR16"
# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/MAY16/Batch_1"
# BATCH="MAY16_1"
#Illumina Nextera
# BASE_DIR="/home/nas151/WORKING_DATA/Exome_Project/Preprocessing/2016/June/"
# BATCH="B2016May"
# CAP_KIT=${PROJ_BASE}/Capture_Kits/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed
BASE_DIR="/home/nas151/WORKING_DATA/Exome_Project/Preprocessing/2015/December/"
BATCH="B2015December"
CAP_KIT=${PROJ_BASE}/Capture_Kits/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed

# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/A1969/Batch_1"
# BATCH="A1969_Batch_1"
# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/A1969/Batch_2"
# BATCH="A1969_Batch_2"
# BASE_DIR="${PROJ_BASE}/SamplePreprocessing/A1969/Batch_3"
# BATCH="A1969_Batch_3"
# BASE_DIR=${PROJ_BASE}/SamplePreprocessing/DEC15
# BATCH="DEC15"
#SureSelect V5

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
for i in ${BASE_DIR}/'Sample_'*
do
##'-----------------------------------------------------------------------------------------#

##'Get Sample ID
##'-----------------------------------------------------------------------------------------#
SAMPLE_ID=$(basename "$i")
SAMPLE_ID="${SAMPLE_ID##*_}"
FORWARD_READS=`ls $i'/Raw_Data/'*R1*`
FORWARD_READS=$(basename "$FORWARD_READS")
REVERSE_READS=`ls $i'/Raw_Data/'*R2*`
REVERSE_READS=$(basename "$REVERSE_READS")
RG='@RG\tID:'${BATCH}'\tSM:'${SAMPLE_ID}'\tPL:Illumina\tLB:Nextera\tPU:NextSeq'
PADDING_TAR="${BASE_DIR}/Sample_${SAMPLE_ID}/Raw_Data/${SAMPLE_ID}_R1.fastq.gz"
PADDING=$(zcat ${PADDING_TAR} | head -10000 | awk '{print length}' | sort -nr | head -1)
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
if [ ! -f "${i}/${SAMPLE_ID}.log" ]; then
  echo "Starting to Preprocess Sample "${SAMPLE_ID} > ${i}/${SAMPLE_ID}.log
else
  echo "Resuming Preprocessing at "${date} >> ${i}/${SAMPLE_ID}.log
fi
##'-----------------------------------------------------------------------------------------#




##'Check to see if alignment already exists
##'-----------------------------------------------------------------------------------------#
if ! ls ${BASE_DIR}/Sample_${SAMPLE_ID}/Alignment/Clean/${SAMPLE_ID}_Clean_GATK.bam 1> /dev/null 2>&1; then
##'-----------------------------------------------------------------------------------------#

    ##'Run Fastqc
    ##' $1 - Output Path
    ##' $2 - Sample ID
    ##' $3 - Path to Fastq Files
    ##' $4 - Stage
    ##'-----------------------------------------------------------------------------------------#
    qsub -N "Fastqc_${SAMPLE_ID}" \
            -hold_jid "FastqSort_${SAMPLE_ID}" \
              ${SCRIPTS}/Modules/Module_Fastqc.sh \
              ${SAMPLE_ID} \
              ${i} \
              ${i}/Raw_Data \
              "Raw_Data"
    ##'-----------------------------------------------------------------------------------------#


    ##'Run BWA for Paired Reads
    ##' $1 - Read Group
    ##' $2 - Reference Fasta
    ##' $3 - Sample ID
    ##' $4 - Path to Paired Fastq Files
    ##' $5 - Path to Sample's preprocessing base
    ##'---------------------------------------------------------------------------------------#
    # qsub -N "BWA_P_${SAMPLE_ID}" \
    #         -hold_jid "FastqSort_${SAMPLE_ID}" \
    #           ${SCRIPTS}/Modules/Module_BWA_MEM_P.sh \
    #           ${RG} \
    #           ${REF_FA} \
    #           ${SAMPLE_ID} \
    #           ${i}/Raw_Data \
    #           ${i}
    ##'---------------------------------------------------------------------------------------#


    ##'Run Picard Tools to Mark Duplicates
    ##' $1 - Sample ID
    ##' $2 - Path to Sample's preprocessing base
    ##'---------------------------------------------------------------------------------------#
    # qsub -N "Picard_${SAMPLE_ID}" \
    #         -hold_jid "BWA_*_${SAMPLE_ID}" \
    #           ${SCRIPTS}/Modules/Module_PicardNT.sh \
    #           ${SAMPLE_ID} \
    #           ${i}
    ##'---------------------------------------------------------------------------------------#


    ##'Run GATK to locally realign indels and recalibrate BQSR
    ##' $1 - Sample ID
    ##' $2 - Path to Sample's preprocessing base
    ##'---------------------------------------------------------------------------------------#
    # qsub -N "GATKRecal_${SAMPLE_ID}" \
    #         -hold_jid "Picard_${SAMPLE_ID}" \
    #           ${SCRIPTS}/Modules/Module_GATKRecal.sh \
    #           ${SAMPLE_ID} \
    #           ${i} \
    #           ${REF_FA} \
    #           ${MILLS} \
    #           ${PHASE1INDELS} \
    #           ${DBSNP} \
    #           ${CAP_KIT} \
    #           ${BUNDLE} \
    #           ${PADDING}
    ##'---------------------------------------------------------------------------------------#

##'---------------------------------------------------------------------------------------#
fi
##'---------------------------------------------------------------------------------------#


##'Run GATK In gVCF Mode to get exome wide genotype probabilities
##' $1 - Sample ID
##' $2 - Path to Sample's preprocessing base
##'---------------------------------------------------------------------------------------#
# if ! ls ${i}/GATK/${SAMPLE_ID}.g.vcf 1> /dev/null 2>&1; then
#   qsub -N "GATKgVCF_${SAMPLE_ID}" \
#           -hold_jid "GATKRecal_${SAMPLE_ID}" \
#             ${SCRIPTS}/Modules/Module_GATKgVCF.sh \
#             ${SAMPLE_ID} \
#             ${i} \
#             ${REF_FA} \
#             ${BUNDLE} \
#             ${CAP_KIT} \
#             ${DBSNP} \
#             ${PADDING}
# fi
##'---------------------------------------------------------------------------------------#


##'Get Gender coverage from Capture Kits
##' $1 - Sample ID
##' $2 - Path to Sample's preprocessing base
##'---------------------------------------------------------------------------------------#
if ! ls ${i}/Checks/${SAMPLE_ID}_Gender.cov 1> /dev/null 2>&1; then
  qsub -N "GenderCov_${SAMPLE_ID}" \
          -hold_jid "GATKRecal_${SAMPLE_ID}" \
            ${SCRIPTS}/Modules/Module_GenderCov.sh \
            ${SAMPLE_ID} \
            ${i} \
            ${CAP_KIT}
fi
##'---------------------------------------------------------------------------------------#


##'End Loop
##'---------------------------------------------------------------------------------------#
done
##'---------------------------------------------------------------------------------------#
