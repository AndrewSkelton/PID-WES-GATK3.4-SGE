#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Runner Script to Gather Coverage Metrics                                   |
#-------------------------------------------------------------------------------------------#

##'Set Variables
##'-----------------------------------------------------------------------------------------#
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A2463/Batch_113_1"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A2463/Batch_116_1"
# CAP_KIT="/home/nas151/Nextera_Rapid_Capture_Exome/nexterarapidcapture_exome_targetedregions.bed" #Illumina Nextera

BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_1"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_2"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/A1969/Batch_3"
# BASE_DIR="/home/nas151/WORKING_DATA/Exomes/DEC15"
CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed" #SureSelect V5
PID="/home/nas151/PID.bed"

# CAP_KIT="/home/nas151/Agilent_SureSelect_ExomeV5/S04380110_Covered_ensembl.bed" #SureSelect V5 UCSC
# BASE_DIR="/home/nas151/WORKING_DATA/raw_alignments"

SCRIPTS="/home/nas151/WORKING_DATA/Scripts"
OUT=${BASE_DIR}/Coverage_Metrics.txt
##'-----------------------------------------------------------------------------------------#

##'Set Up Files
##'-----------------------------------------------------------------------------------------#
rm $OUT
echo -e "Sample ID \t Number of Bases \t Average Coverage \t % Bases with >= 20x Cov \t % Bases with >= 30x Cov \t % Bases with >= 50x Cov \t % Bases with No Cov \t Average PID Coverage" > $OUT
##'-----------------------------------------------------------------------------------------#



##'Loop Through Each Sample
##' for i in $BASE_DIR/'Sample_'*
# DEC1514D4091
##'-----------------------------------------------------------------------------------------#
# for i in $BASE_DIR/*'.bam'
for i in $BASE_DIR/'Sample_'*
do

# SAMPLE_IN=`ls ${i}"/GATK_Pipeline/Clean_Alignment/"*".bam"`
SAMPLE_ID=$(basename "$i")
SAMPLE_ID=${SAMPLE_ID##*_}

echo $SAMPLE_ID
# SAMPLE_ID="${SAMPLE_ID%.*}" #Filename without extension
echo $i

qsub -N $SAMPLE_ID'_Coverage_Metrics' \
        $SCRIPTS/Coverage_Metrics_Wrapper.sh \
        $i \
        $OUT \
        $SAMPLE_ID \
        $CAP_KIT \
        $PID
done
##'-----------------------------------------------------------------------------------------#
