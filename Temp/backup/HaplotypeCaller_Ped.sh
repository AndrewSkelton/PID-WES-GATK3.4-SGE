#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=25G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Haplotype Caller, none gVCF mode, Pedigree $6      |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
# $5 - DB SNP

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/*.bam* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $4* $TMPDIR
cp $5* $TMPDIR
##'-----------------------------------------------------------------------------------------#

VCFS=`find $TMPDIR -type f -name "*bam" | sed 's/^/-I /' -`

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "$4")
DBSNP=$(basename "$5")
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx18g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T HaplotypeCaller \
        -nct 10 \
        -ped $6 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -L $TMPDIR/$CAP_KIT \
        --interval_padding 100 \
        --dbsnp $TMPDIR/$DBSNP \
        --max_alternate_alleles 50 \
        --pcr_indel_model CONSERVATIVE \
        $VCFS \
        -A QualByDepth \
        -A Coverage \
        -A VariantType \
        -A ClippingRankSumTest \
        -A DepthPerSampleHC \
        -A InbreedingCoeff \
        -o $TMPDIR/$2'.vcf'

#--genotyping_mode DISCOVERY \
mv $TMPDIR/$2'.vcf'* $3
##'-----------------------------------------------------------------------------------------#
