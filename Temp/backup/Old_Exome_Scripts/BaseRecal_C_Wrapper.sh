#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=35G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Base Recalibration Substage C                      |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $5'/Local_Realignment/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/'GATK_Pipeline'/$2'_recal_data.table' $TMPDIR
cp $3/'GATK_Pipeline'/$2'_post_recal_data.table' $TMPDIR
cp $4 $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "$4")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started: '$(date) >> $3/$2'.log'
echo 'Parameters:' >> $3/$2'.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $3/$2'.log'
echo 'Capture Kit bed: '$CAP_KIT >> $3/$2'.log'
echo 'Recal Data: '$2'_recal_data.table' >> $3/$2'.log'
echo 'Post Recal Data: '$2'_post_recal_data.table' >> $3/$2'.log'
echo 'Running BaseRecalibrator: Plots' >> $3/$2'.log'

echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Second pass to analyze covariation remaining after recalibration
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T AnalyzeCovariates \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -L $TMPDIR/$CAP_KIT \
        --interval_padding 100 \
        -before $TMPDIR/$2'_recal_data.table' \
        -after $TMPDIR/$2'_post_recal_data.table' \
        -plots $TMPDIR/$2'_precalibration_plots.pdf'

mv $TMPDIR/$2'_precalibration_plots.pdf' $3/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'Plots Written to WORKING_DATA' >> $3/$2'.log'
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
