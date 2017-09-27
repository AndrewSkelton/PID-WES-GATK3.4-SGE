#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=45G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Base Recalibration Substage D                      |
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
cp $3/'GATK_Pipeline'/$2'_realignment.'* $TMPDIR
cp $3/'GATK_Pipeline'/$2'_recal_data.table' $TMPDIR
cp $3/'GATK_Pipeline'/$2'_post_recal_data.table' $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $4 $TMPDIR
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
echo 'Reference Fa: '$REF_FA >> $3/$2'.log'
echo 'Capture Kit bed: '$CAP_KIT >> $3/$2'.log'
echo 'Alignment: '$2'_realignment.bam' >> $3/$2'.log'
echo 'Recal Data: '$2'_recal_data.table' >> $3/$2'.log'
echo 'Recal Data: '$2'_post_recal_data.table' >> $3/$2'.log'
echo 'Running BaseRecalibrator: BAM Adjustment' >> $3/$2'.log'

echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Apply Recalibration
##'-----------------------------------------------------------------------------------------#
java -Xmx35g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T PrintReads \
        -nct 10 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -I $TMPDIR/$2'_realignment.bam' \
        -L $TMPDIR/$CAP_KIT \
        --interval_padding 100 \
        -BQSR $TMPDIR/$2'_recal_data.table' \
        -o $TMPDIR/$2'_post_recal.bam'

samtools index $TMPDIR/$2'_post_recal.bam'

mv $TMPDIR/$2'_post_recal.bam' $3/'GATK_Pipeline'
mv $TMPDIR/$2'_post_recal.bam.bai' $3/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'Post Recal BAM Written to WORKING_DATA' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Clean Up
##'-----------------------------------------------------------------------------------------#
mkdir $3/'GATK_Pipeline/Metrics'
mv $3/'GATK_Pipeline'/$2'_metrics.txt' $3/'GATK_Pipeline/Metrics'
mv $3/'GATK_Pipeline'/$2'_post_recal_data.table' $3/'GATK_Pipeline/Metrics'
mv $3/'GATK_Pipeline'/$2'_precalibration_plots.pdf' $3/'GATK_Pipeline/Metrics'
mv $3/'GATK_Pipeline'/$2'_realignment_targets.list' $3/'GATK_Pipeline/Metrics'
mv $3/'GATK_Pipeline'/$2'_recal_data.table' $3/'GATK_Pipeline/Metrics'

mkdir $3/'GATK_Pipeline/Clean_Alignment'
mv $3/'GATK_Pipeline'/$2'_post_recal.bam'* $3/'GATK_Pipeline/Clean_Alignment'

# rm $3/'GATK_Pipeline'/$2'_dedup_sorted'*
# rm $3/'GATK_Pipeline'/$2'_realignment'*
##'-----------------------------------------------------------------------------------------#
