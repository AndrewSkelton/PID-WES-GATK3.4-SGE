#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=80G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - VariantRecalibrator for SNPs (GVCF)              |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - PWD
# $3 - G_STANDARD
# $4 - DB_SNP_B
# $5 - OMNI
# $6 - HAP

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
cp $5* $TMPDIR
cp $6* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS=$(basename "$3")
DBSNP=$(basename "$4")
OMNI=$(basename "$5")
HAP=$(basename "$6")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - VariantRecalibrator (SNPs GVCF): '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Parameters:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Resource: '$GS_A >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Resource: '$GS_B >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'VCF In: GVCF_Genotyped.vcf' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Running VariantRecalibrator (SNPs GVCF)' >> $2/'GATK_GVCF/GATK_GVCF.log'

echo 'Files on Scratch:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo `ls $TMPDIR` >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx70g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/'GVCF_Genotyped.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $TMPDIR/$DBSNP \
        -resource:1000G,known=false,training=true,truth=false,prior=10.0 $TMPDIR/$GS \
        -resource:omni,known=false,training=true,truth=true,prior=12.0 $TMPDIR/$OMNI \
        -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $TMPDIR/$HAP \
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
        -recalFile $TMPDIR/'GVCF_SNPs.recal' \
        -tranchesFile $TMPDIR/'GVCF_SNPs.tranches' \
        -rscriptFile $TMPDIR/'GVCF_SNPs.R'

mv $TMPDIR/'GVCF_SNPs.'* $2/'GATK_GVCF'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Files Written to WORKING_DATA' >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#
