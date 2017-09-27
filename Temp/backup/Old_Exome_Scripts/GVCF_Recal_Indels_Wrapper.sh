#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=100G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - VariantRecalibrator for Indels (GVCF)              |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - PWD
# $3 - G_STANDARD
# $4 - DB_SNP_B

##'Notes
##'-----------------------------------------------------------------------------------------#
#
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $2/'GATK_GVCF/GVCF_Genotyped.vcf'* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $3* $TMPDIR
cp $4* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS=$(basename "$3")
DBSNP=$(basename "$4")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - VariantRecalibrator (Indels GVCF): '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Parameters:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Resource: '$GS >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Resource: '$DBSNP >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'VCF In: GVCF_Genotyped.vcf' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Running VariantRecalibrator (Indels GVCF)' >> $2/'GATK_GVCF/GATK_GVCF.log'

echo 'Files on Scratch:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo `ls $TMPDIR` >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx70g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 10 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/'GVCF_Genotyped.vcf' \
        -resource:mills,known=false,training=true,truth=true,prior=12.0 $TMPDIR/$GS \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $TMPDIR/$DBSNP \
        -an MQ \
        -an QD \
        -an FS \
        -an SOR \
        -an MQRankSum \
        -an ReadPosRankSum \
        -mode INDEL \
        -tranche 100.0 \
        -tranche 99.9 \
        -tranche 99.0 \
        -tranche 95.0 \
        -recalFile $TMPDIR/'GVCF_indels.recal' \
        -tranchesFile $TMPDIR/'GVCF_indels.tranches' \
        -rscriptFile $TMPDIR/'GVCF_indels.R'

mv $TMPDIR/'GVCF_indels.'* $2/'GATK_GVCF'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Files Written to WORKING_DATA' >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#
