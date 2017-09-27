#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=42G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Base Recalibration Substage A                      |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Gold Indels VCF
# $3 - Gold Indels VCF B
# $4 - Sample ID
# $5 - PWD
# $6 - Capture Kit Bed File
# $7 - DB SNP

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $5'/Local_Realignment/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $5/$4'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $5/'GATK_Pipeline'/$4'_realignment.'* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $2 $TMPDIR
cp $3 $TMPDIR
cp $6 $TMPDIR
cp $7 $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS_A=$(basename "$2")
GS_B=$(basename "$3")
REF_FA=$(basename "$1")
CAP_KIT=$(basename "$6")
DBSNP=$(basename "$7")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $5/$4'.log'
echo 'GATK Started: '$(date) >> $5/$4'.log'
echo 'Parameters:' >> $5/$4'.log'
echo 'Known: '$GS_A >> $5/$4'.log'
echo 'Known: '$GS_B >> $5/$4'.log'
echo 'Known: '$DBSNP >> $5/$4'.log'
echo 'Reference Fa: '$REF_FA >> $5/$4'.log'
echo 'Capture Kit bed: '$CAP_KIT >> $5/$4'.log'
echo 'Alignment: '$4'_realignment.bam' >> $5/$4'.log'
echo 'Running BaseRecalibrator' >> $5/$4'.log'

echo 'Files on Scratch:' >> $5/$4'.log'
echo `ls $TMPDIR` >> $5/$4'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK to Analyze patterns of covariation in the sequence dataset
##'-----------------------------------------------------------------------------------------#
java -Xmx35g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T BaseRecalibrator \
        -nct 10 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -I $TMPDIR/$4'_realignment.bam' \
        -L $TMPDIR/$CAP_KIT \
        --interval_padding 100 \
        -knownSites $TMPDIR/$GS_A \
        -knownSites $TMPDIR/$GS_B \
        -knownSites $TMPDIR/$DBSNP \
        -o $TMPDIR/$4'_recal_data.table'

mv $TMPDIR/$4'_recal_data.table' $5/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $5/$4'.log'
echo 'Recal Table Written to WORKING_DATA' >> $5/$4'.log'
##'-----------------------------------------------------------------------------------------#

# qlogin -l h_vmem=100G -q bigmem.q -pe smp 1
# module add apps/gatk/3.3-protected
# java -Xmx70g -jar \
#     $GATK_ROOT/GenomeAnalysisTK.jar \
#         -T RealignerTargetCreator \
#         -nt 10 \
#         -R /opt/databases/GATK_bundle/2.8/hg19/ucsc.hg19.fasta \
#         -I /home/nas151/WORKING_DATA/Test_Data/Sample_D05685/Picard/D05685_dedup_sorted.bam \
#         -L /home/nas151/Agilent_SureSelect_ExomeV5/S04380110_Covered.bed \
#         --interval_padding 100 \
#         -known /opt/databases/GATK_bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.vcf \
#         -known /opt/databases/GATK_bundle/2.8/hg19/1000G_phase1.indels.hg19.vcf \
#         -o ./realignment_targets.list

# Genotyper
