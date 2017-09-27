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
#  Description : Job Submission Script - VariantRecalibrator for SNPs                     |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - G_STANDARD
# $5 - DB_SNP_B
# $6 - OMNI
# $7 - HAP

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
cp $4* $TMPDIR
cp $5* $TMPDIR
cp $6* $TMPDIR
cp $7* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS=$(basename "$4")
DBSNP=$(basename "$5")
GS_A=$(basename "$6")
HAP=$(basename "$7")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - VariantRecalibrator (Indels): '$(date) >> $3/$2'.log'
echo 'Parameters:' >> $3/$2'.log'
echo 'Resource: '$GS >> $3/$2'.log'
echo 'Resource: '$DBSNP >> $3/$2'.log'
echo 'Resource: '$GS_A >> $3/$2'.log'
echo 'Resource: '$HAP >> $3/$2'.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $3/$2'.log'
echo 'VCF In: '$2'.vcf' >> $3/$2'.log'
echo 'Running VariantRecalibrator (SNPs)' >> $3/$2'.log'
echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx35g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $TMPDIR/$DBSNP \
        -resource:1000G,known=false,training=true,truth=false,prior=10.0 $TMPDIR/$GS \
        -resource:omni,known=false,training=true,truth=true,prior=12.0 $TMPDIR/$GS_A \
        -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $TMPDIR/$HAP \
        --maxGaussians 4 \
        -an MQ \
        -an QD \
        -an FS \
        -an SOR \
        -an MQRankSum \
        -an ReadPosRankSum \
        -mode SNP \
        -tranche 100.0 \
        -tranche 99.9 \
        -tranche 99.0 \
        -tranche 95.0 \
        -recalFile $TMPDIR/$2'.VR_SNPs.recal' \
        -tranchesFile $TMPDIR/$2'.VR_SNPs.tranches' \
        -rscriptFile $TMPDIR/$2'.VR_SNPs.R'


mv $TMPDIR/$2'.VR_SNPs.recal' $3/'GATK_Pipeline'
mv $TMPDIR/$2'.VR_SNPs.tranches' $3/'GATK_Pipeline'
mv $TMPDIR/$2'.VR_SNPs.R' $3/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'Files Written to WORKING_DATA' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#
