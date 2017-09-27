#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=5G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run the Trimmomatic utility on the raw data                                |
#  Input       : Sample ID                                                                  |
#  Input       : Path to sample's Preprocessing Directory                                   |
#  Input       : Path to fastq Files                                                        |
#  Input       : Forward Reads                                                              |
#  Input       : Reverse Reads                                                              |
#  Resources   : Memory     - 5GB                                                           |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#

TRIMMOMATIC="/home/nas151/Backup/Trimming/trimmomatic-0.35.jar"
ADAPTERS="/home/nas151/Backup/Adapters/adapters/Uni_Adapt.fa"

##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Trimming/Paired
mkdir -p ${2}/Trimming/Unpaired
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Raw_Data/*.gz ${TMPDIR}
cp ${ADAPTERS} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Sort Fastq
##'-----------------------------------------------------------------------------------------#
java -jar -Xmx2g ${TRIMMOMATIC} \
            PE \
            -threads 5 \
            -phred33 \
            ${TMPDIR}/${4} \
            ${TMPDIR}/${5} \
            -baseout ${TMPDIR}/${1}.fastq.gz \
            ILLUMINACLIP:${TMPDIR}/Uni_Adapt.fa:2:30:10
##'-----------------------------------------------------------------------------------------#

##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv $TMPDIR/${1}_1P.fastq.gz ${2}/Trimming/Paired/${1}_R1.fastq.gz
mv $TMPDIR/${1}_2P.fastq.gz ${2}/Trimming/Paired/${1}_R2.fastq.gz
mv $TMPDIR/${1}_1U.fastq.gz ${2}/Trimming/Unpaired
mv $TMPDIR/${1}_2U.fastq.gz ${2}/Trimming/Unpaired
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Reads Trimmed" >> ${2}/${1}'.log'
##'-----------------------------------------------------------------------------------------#
