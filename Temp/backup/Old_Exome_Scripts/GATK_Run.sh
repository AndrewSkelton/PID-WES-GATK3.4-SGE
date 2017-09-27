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
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/old_samples/Louise"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/old_samples/Rafi"


# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A2463/Batch_113_1"
# BATCH="A2463_Batch_113_1"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A2463/Batch_116_1"
# BATCH="A2463_Batch_116_1"
# CAP_KIT="/home/nas151/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed" #Illumina Nextera

# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_1"
# BATCH="A1969_Batch_1"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_2"
# BATCH="A1969_Batch_2"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_3"
# BATCH="A1969_Batch_3"
BASE_DIR="/home/nas151/WORKING_DATA/Exomes/DEC15"
BATCH="EXOMEBATCH_DEC15"
CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed" #SureSelect V5



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

SCRIPTS="/home/nas151/WORKING_DATA/Scripts"
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19/"
##'-----------------------------------------------------------------------------------------#



##'Loop Through Each Sample
##' for i in $BASE_DIR/'Sample_'*
# DEC15D201259
# DEC15D207049
# DEC1514D4090
# DEC15F0873
##'-----------------------------------------------------------------------------------------#
for i in $BASE_DIR/'SampleRerun_'*
do
##'-----------------------------------------------------------------------------------------#


##'Create Output Directory
##'-----------------------------------------------------------------------------------------#
mkdir $i/'GATK_Pipeline'
mkdir $i/'GATK_Pipeline/VCF_Backups'
mkdir $i/'Original_Data'
mkdir $i/'fastqc'
mkdir $i/'Trimmomatic_Unpaired'
##'-----------------------------------------------------------------------------------------#

##'Get Sample Name
##'-----------------------------------------------------------------------------------------#
SAMPLE_ID=$(basename "$i")
SAMPLE_ID="${SAMPLE_ID##*_}"
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
echo 'FMS Cluster Varient Call Run: Sample '$SAMPLE_ID > $i/$SAMPLE_ID'.log'
echo 'Sample ID: '$SAMPLE_ID >> $i/$SAMPLE_ID'.log'
echo 'Reference Fasta: '$REF_FA >> $i/$SAMPLE_ID'.log'
echo 'Script Location: '$SCRIPTS >> $i/$SAMPLE_ID'.log'
echo 'Batch: '$BATCH >> $i/$SAMPLE_ID'.log'
echo 'Base Directory: '$BASE_DIR >> $i/$SAMPLE_ID'.log'
echo 'Working Directory: '$i >> $i/$SAMPLE_ID'.log'
echo '##################################################' >> $i/$SAMPLE_ID'.log'
echo '' >> $i/$SAMPLE_ID'.log'
##'-----------------------------------------------------------------------------------------#

##'Create Read Group Header Entry (@RG)
##'-----------------------------------------------------------------------------------------#
RG='@RG\tID:'$BATCH'\tSM:'$SAMPLE_ID'\tPL:illumina\tLB:lib1\tPU:unit1'
echo 'Read Group Header: '$RG >> $i/$SAMPLE_ID'.log'
##'-----------------------------------------------------------------------------------------#

##'Assign Variables to Forward and Reverse Reads
##'-----------------------------------------------------------------------------------------#
FORWARD_READS=`ls $i'/'*R1*`
FORWARD_READS=$(basename "$FORWARD_READS")
REVERSE_READS=`ls $i'/'*R2*`
REVERSE_READS=$(basename "$REVERSE_READS")

# Original_Data

echo 'Forward Reads : '$FORWARD_READS >> $i/$SAMPLE_ID'.log'
echo 'Reverse Reads : '$REVERSE_READS >> $i/$SAMPLE_ID'.log'

# rm ${i}/*'R1'*
# rm ${i}/*'R2'*

##'-----------------------------------------------------------------------------------------#


##'Run fastq-sort
##' $1 - Output Path
##' $2 - Sample ID
##'-----------------------------------------------------------------------------------------#
# cp ${i}/*.gz ${i}/Original_Data/
# qsub -N $SAMPLE_ID'_fastq-tools_sort' \
#         $SCRIPTS/Fastq_Sort_Wrapper.sh \
#         $SAMPLE_ID \
#         ${i}/Original_Data/
##'-----------------------------------------------------------------------------------------#

##'Run Samtools sort by name
##' $1 - Output Path
##' $2 - Sample ID
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_samtools_sort' \
#         $SCRIPTS/Samtools_Sort_Wrapper.sh \
#         $i \
#         $SAMPLE_ID
##'-----------------------------------------------------------------------------------------#

##'Run bedtools to convert to gunzipped fastq
##' $1 - Output Path
##' $2 - Sample ID
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_bam_to_fastq_gz' \
#         $SCRIPTS/bedtools_bamtofastq_Wrapper.sh \
#         $i \
#         $SAMPLE_ID
##'-----------------------------------------------------------------------------------------#

#'Run Trimmomatic
#' $1 - Forward Reads
#' $2 - Reverse Reads
#' $3 - Sample ID
#' $4 - Output Path
#'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Trimmomatic' \
#         $SCRIPTS/Trimmomatic_Wrapper.sh \
#         $FORWARD_READS \
#         $REVERSE_READS \
#         $SAMPLE_ID \
#         $i
#'-----------------------------------------------------------------------------------------#

#'Run Fastqc
#' $1 - Sample ID
#' $2 - Output Path
#'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_fastqc' \
#         -hold_jid $SAMPLE_ID'_Trimmomatic' \
#         $SCRIPTS/fastqc_Wrapper.sh \
#         $SAMPLE_ID \
#         $i
#'-----------------------------------------------------------------------------------------#

##'Run BWA MEM to align paired reads
##' $1 - Read Group String
##' $2 - Reference fasta
##' $3 - Sample ID
##' $4 - Forward Reads
##' $5 - Reverse Reads
##' $6 - Output Path
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_BWA_PE' \
#         -hold_jid $SAMPLE_ID'_Trimmomatic' \
#         $SCRIPTS/BWA_Wrapper.sh \
#         $RG \
#         $REF_FA \
#         $SAMPLE_ID \
#         $FORWARD_READS \
#         $REVERSE_READS \
#         ${i}
##'-----------------------------------------------------------------------------------------#

##'Run BWA MEM to align unpaired reads
##' $1 - Read Group String
##' $2 - Reference fasta
##' $3 - Sample ID
##' $4 - Output Path
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_BWA_U' \
#         -hold_jid $SAMPLE_ID'_Trimmomatic' \
#         $SCRIPTS/BWA_U_Wrapper.sh \
#         $RG \
#         $REF_FA \
#         $SAMPLE_ID \
#         ${i}'/Trimmomatic_Unpaired' \
#         $i
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools
##' $1 - Output Path
##' $2 - Sample ID
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_Picard' \
#      -hold_jid $SAMPLE_ID'_Exome_BWA' \
#         $SCRIPTS/Picard_Wrapper.sh \
#         $i \
#         $SAMPLE_ID
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools with a sam join
##' $1 - Output Path
##' $2 - Sample ID
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_Picard' \
#      -hold_jid $SAMPLE_ID'_Exome_BWA*' \
#         $SCRIPTS/Picard_Wrapper_Join.sh \
#         $i \
#         $SAMPLE_ID
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Local Realignment Indel Targets
# $1 - Bundle Path
# $2 - Gold Indels VCF
# $3 - Gold Indels VCF B
# $4 - Sample ID
# $5 - PWD
# $6 - Capture Kit bed file
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_Targets' \
#      -hold_jid $SAMPLE_ID'_Exome_Picard' \
#         $SCRIPTS/Local_Realignment_Wrapper.sh \
#         $BUNDLE \
#         $G_STANDARD \
#         $G_STANDARD_B \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Local Realignment
# $1 - Bundle Path
# $2 - Gold Indels VCF
# $3 - Gold Indels VCF B
# $4 - Sample ID
# $5 - PWD
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_Realign' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_Targets' \
#         $SCRIPTS/Realignment_Wrapper.sh \
#         $BUNDLE \
#         $G_STANDARD \
#         $G_STANDARD_B \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Base Recalibration (Stage A)
# $1 - Bundle Path
# $2 - Gold Indels VCF
# $3 - Gold Indels VCF B
# $4 - Sample ID
# $5 - PWD
# $6 - Capture Kit bed
# $7 - DB SNP Ref
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_BaseRecal_A' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_Realign' \
#         $SCRIPTS/BaseRecal_A_Wrapper.sh \
#         $BUNDLE \
#         $G_STANDARD \
#         $G_STANDARD_B \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT \
#         $DB_SNP
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Base Recalibration (Stage B)
# $1 - Bundle Path
# $2 - Gold Indels VCF
# $3 - Gold Indels VCF B
# $4 - Sample ID
# $5 - PWD
# $6 - Capture Kit bed
# $7 - DB SNP Ref
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_BaseRecal_B' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_BaseRecal_A' \
#         $SCRIPTS/BaseRecal_B_Wrapper.sh \
#         $BUNDLE \
#         $G_STANDARD \
#         $G_STANDARD_B \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT \
#         $DB_SNP
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Base Recalibration (Stage C)
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_BaseRecal_C' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_BaseRecal_B' \
#         $SCRIPTS/BaseRecal_C_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT
##'-----------------------------------------------------------------------------------------#

##'Run GATK for Base Recalibration (Stage D)
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_BaseRecal_D' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_BaseRecal_C' \
#         $SCRIPTS/BaseRecal_D_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the Haplotype Caller (none gVCF Mode)
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
# $5 - DB SNP
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_HapCaller_A' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_BaseRecal_D' \
#         $SCRIPTS/HapCaller_A_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT \
#         $DB_SNP
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the Haplotype Caller (gVCF Mode)
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
# $5 - DB SNP
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_Exome_GATK_HapCaller_B' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_BaseRecal_D' \
#         $SCRIPTS/HapCaller_B_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $CAP_KIT \
#         $DB_SNP
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD
# $5 - DB_SNP_B
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_VCF_Recal_Indel' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_HapCaller_A' \
#         $SCRIPTS/Recal_Indels_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $G_STANDARD \
#         $DB_SNP_B
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for Indels Apply
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_VCF_Recal_Indel_Apply' \
#      -hold_jid $SAMPLE_ID'_VCF_Recal_Indel' \
#         $SCRIPTS/Recal_Indels_Apply_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the SelectVariants for Indels
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_SelectVariants_Indels' \
#      -hold_jid $SAMPLE_ID'_VCF_Recal_Indel_Apply' \
#         $SCRIPTS/SelectVariants_Indels_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i
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
# qsub -N $SAMPLE_ID'_VCF_Recal_SNP' \
#      -hold_jid $SAMPLE_ID'_Exome_GATK_HapCaller_A' \
#         $SCRIPTS/Recal_SNPs_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i \
#         $G_STANDARD_C \
#         $DB_SNP_B \
#         $G_STANDARD_D \
#         $HAP
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the VariantRecalibrator for SNPs Apply
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_VCF_Recal_SNP_Apply' \
#      -hold_jid $SAMPLE_ID'_VCF_Recal_SNP' \
#         $SCRIPTS/Recal_SNPs_Apply_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i
##'-----------------------------------------------------------------------------------------#

##'Run GATK using the SelectVariants for SNPs
# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
##'-----------------------------------------------------------------------------------------#
# qsub -N $SAMPLE_ID'_SelectVariants_SNPs' \
#      -hold_jid $SAMPLE_ID'_VCF_Recal_SNP_Apply' \
#         $SCRIPTS/SelectVariants_SNPs_Wrapper.sh \
#         $BUNDLE \
#         $SAMPLE_ID \
#         $i
##'-----------------------------------------------------------------------------------------#

##'End Loop
##'-----------------------------------------------------------------------------------------#
done
##'-----------------------------------------------------------------------------------------#
