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
#  Description : Job Submission Script - Recalibrate and Select SNPs                        |
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
cp $6* $TMPDIR
cp $7* $TMPDIR
cp $3/*.bam* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
GS=$(basename "$4")
DBSNP=$(basename "$5")
GS_A=$(basename "$6")
HAP=$(basename "$7")
VCFS=`find $TMPDIR -type f -name "*bam" | sed 's/^/-I /' -`
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Recalibration Targets
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 $TMPDIR/$DBSNP \
        -resource:1000G,known=false,training=true,truth=false,prior=10.0 $TMPDIR/$GS \
        -resource:omni,known=false,training=true,truth=true,prior=12.0 $TMPDIR/$GS_A \
        -resource:hapmap,known=false,training=true,truth=true,prior=15.0 $TMPDIR/$HAP \
        -ped $8 \
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
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -ped $8 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -input $TMPDIR/$2'.vcf' \
        -recalFile $TMPDIR/$2'.VR_SNPs.recal' \
        -tranchesFile $TMPDIR/$2'.VR_SNPs.tranches' \
        -mode SNP \
        --ts_filter_level 99.0 \
        -o $TMPDIR/$2'_Recal_SNPs.vcf'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Select Variants
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R $TMPDIR/"ucsc.hg19.fasta" \
      --downsampling_type NONE \
      --variant $TMPDIR/$2'_Recal_SNPs.vcf' \
      -select "vc.isNotFiltered()" \
      -selectType SNP \
      --out $TMPDIR/$2'_SNPs_Selected.vcf'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Annotate
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T VariantAnnotator \
        -nt 5 \
        -ped $8 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -V $TMPDIR/$2'_SNPs_Selected.vcf' \
        -L $TMPDIR/$2'_SNPs_Selected.vcf' \
        $VCFS \
        -A Coverage \
        -A GenotypeSummaries \
        -A PossibleDeNovo \
        -A SnpEff \
        -A VariantType \
        -A DepthPerAlleleBySample \
        -A DepthPerSampleHC \
        -o $TMPDIR/$2'_SNPs_Selected_Anno.vcf'
##'-----------------------------------------------------------------------------------------#

mv $TMPDIR/$2'_SNPs_Selected_Anno'* $3
