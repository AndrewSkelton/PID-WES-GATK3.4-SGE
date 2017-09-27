#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
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
#  Description : Job Submission Script - VariantRecalibrator for Indels - Apply             |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD


##'Notes
##'-----------------------------------------------------------------------------------------#
# --maxGaussians 4 : Set for Single Samples
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/'GATK_Pipeline'/$2'.vcf'* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $3/'GATK_Pipeline'/$2'.VR_indels.recal' $TMPDIR
cp $3/'GATK_Pipeline'/$2'.VR_indels.tranches' $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - VariantRecalibrator (Indels - Apply): '$(date) >> $3/$2'.log'
echo 'Parameters:' >> $3/$2'.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $3/$2'.log'
echo 'VCF In: '$2'.vcf' >> $3/$2'.log'
echo 'Running VariantRecalibrator (Indels)' >> $3/$2'.log'

echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller - Apply Recalibration of Indels
##'-----------------------------------------------------------------------------------------#
java -Xmx35g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -recalFile $TMPDIR/$2'.VR_indels.recal' \
        -tranchesFile $TMPDIR/$2'.VR_indels.tranches' \
        -mode INDEL \
        --ts_filter_level 99.0 \
        -o $TMPDIR/$2'_Recal_indels.vcf' \

mv $TMPDIR/$2'_Recal_indels.vcf'* $3/'GATK_Pipeline'
mv $3/'GATK_Pipeline'/$2'.VR_indels.'* $3/'GATK_Pipeline/Metrics'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'Files Written to WORKING_DATA' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#
