#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=20G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Recalibrate and Select Indels                      |
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

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/*.vcf* $TMPDIR
cp $1/ucsc.hg19.dict $TMPDIR
cp $1/ucsc.hg19.fasta.fai $TMPDIR
cp $1/ucsc.hg19.fasta $TMPDIR
cp $4* $TMPDIR
cp $5* $TMPDIR
cp $3/*.bam* $TMPDIR
# cp $6* $TMPDIR
# cp $7* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS=$(basename "$4")
DBSNP=$(basename "$5")
VCFS=`find $TMPDIR -type f -name "*bam" | sed 's/^/-I /' -`
##'-----------------------------------------------------------------------------------------#

##'Run GATK: INDEL Recalibration Targets
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $TMPDIR/$DBSNP \
        -resource:mills,known=false,training=true,truth=true,prior=12.0 $TMPDIR/$GS \
        -ped $8 \
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
        -recalFile $TMPDIR/$2'.VR_INDELs.recal' \
        -tranchesFile $TMPDIR/$2'.VR_INDELs.tranches' \
        -rscriptFile $TMPDIR/$2'.VR_INDELs.R'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: INDEL Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -ped $8 \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -recalFile $TMPDIR/$2'.VR_INDELs.recal' \
        -tranchesFile $TMPDIR/$2'.VR_INDELs.tranches' \
        -mode INDEL \
        --ts_filter_level 99.0 \
        -o $TMPDIR/$2'_Recal_INDELs.vcf'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: INDEL Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R $TMPDIR/"ucsc.hg19.fasta" \
      --downsampling_type NONE \
      --variant $TMPDIR/$2'_Recal_INDELs.vcf' \
      --out $TMPDIR/$2'_Recal_INDELs_Selected.vcf' \
      -selectType INDEL \
      -select "vc.isNotFiltered()"
##'-----------------------------------------------------------------------------------------#

##'Run GATK: INDEL Annotation
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantAnnotator \
        -nt 5 \
        -ped $8 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -V $TMPDIR/$2'_Recal_INDELs_Selected.vcf' \
        -L $TMPDIR/$2'_Recal_INDELs_Selected.vcf' \
        $VCFS \
        -A Coverage \
        -A GenotypeSummaries \
        -A PossibleDeNovo \
        -A SnpEff \
        -A VariantType \
        -A DepthPerAlleleBySample \
        -A DepthPerSampleHC \
        -o $TMPDIR/$2'_Recal_INDELs_Selected_Anno.vcf'
##'-----------------------------------------------------------------------------------------#

mv $TMPDIR/$2'_Recal_INDELs_Selected_Anno'* $3
