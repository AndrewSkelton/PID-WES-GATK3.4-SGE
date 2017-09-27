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
#  Description : Job Submission Script - ApplyRecalibration for SNPs (GVCF)               |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - PWD
# $3 - Sample ID

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
cp $2/'GATK_GVCF/GVCF_SNPs.'* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - ApplyRecalibration (SNPs GVCF): '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Parameters:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'VCF In: GVCF_Genotyped.vcf' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Running ApplyRecalibration (SNPs GVCF)' >> $2/'GATK_GVCF/GATK_GVCF.log'

echo 'Files on Scratch:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo `ls $TMPDIR` >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: ApplyRecalibration
##'-----------------------------------------------------------------------------------------#
java -Xmx70g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/'GVCF_Genotyped.vcf' \
        -recalFile $TMPDIR/'GVCF_SNPs.recal' \
        -tranchesFile $TMPDIR/'GVCF_SNPs.tranches' \
        -mode SNP \
        --ts_filter_level 99.0 \
        -o $TMPDIR/'GATK_GVCF_Recal_SNPs.vcf'

mv $TMPDIR/'GATK_GVCF_Recal_SNPs.vcf'* $2/'GATK_GVCF'
# mv $3/'GATK_Pipeline'/$2'.VR_SNPs.'* $3/'GATK_Pipeline/Metrics'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Files Written to WORKING_DATA' >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#
