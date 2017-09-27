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
#  Type        : Cluster Script                                                             |
#  Description : Run the Haplotype Caller at the sample Level, Call Indels                  |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Sample ID                                                                  |
#  Input 3     : Sample's root Preprocessing directory                                      |
#  Input 4     : Capture Kit                                                                |
#  Input 5     : Training Set - dbSNP Excluding 129                                         |
#  Input 6     : Training Set - Mills                                                       |
#  Resources   : Memory     - 20GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#



##'Create Folder Structure and output File
##'-----------------------------------------------------------------------------------------#
mkdir -p ${3}/GATK
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${3}/GATK/${2}.vcf* ${TMPDIR}
cp ${1}/ucsc.hg19.* ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "${4}")
DBSNP=$(basename "${5}")
MILLS=$(basename "${6}")
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Hard Filtering
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T SelectVariants \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -V ${TMPDIR}/${2}'.vcf' \
        -selectType INDEL \
        -o ${TMPDIR}/${2}_raw_indels.vcf

java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -V ${TMPDIR}/${2}_raw_indels.vcf  \
        --filterExpression "QD < 2.0 || FS > 200.0 || ReadPosRankSum < -20.0" \
        --filterName "hard_indel_filter" \
        -o ${TMPDIR}/${2}_HardFiltered_Indels.vcf

mkdir ${3}/GATK/Hard_Filtering
mv ${TMPDIR}/${2}_HardFiltered_Indels.vcf* ${3}/GATK/Hard_Filtering/
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Variant Recalibrator for SNPs
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/${2}'.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${TMPDIR}/${DBSNP} \
        -resource:mills,known=false,training=true,truth=true,prior=12.0 ${TMPDIR}/${MILLS} \
        --maxGaussians 4 \
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
        -recalFile ${TMPDIR}/${2}'.VR_INDELs.recal' \
        -tranchesFile ${TMPDIR}/${2}'.VR_INDELs.tranches' \
        -rscriptFile ${TMPDIR}/${2}'.VR_INDELs.R'
##'-----------------------------------------------------------------------------------------#



##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/${2}'.vcf' \
        -recalFile ${TMPDIR}/${2}'.VR_INDELs.recal' \
        -tranchesFile ${TMPDIR}/${2}'.VR_INDELs.tranches' \
        -mode INDEL \
        --ts_filter_level 99.0 \
        -o ${TMPDIR}/${2}'_Recal_INDELs.vcf'
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Select Variants
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R ${TMPDIR}/"ucsc.hg19.fasta" \
      --downsampling_type NONE \
      --variant ${TMPDIR}/${2}'_Recal_INDELs.vcf' \
      -select "vc.isNotFiltered()" \
      -selectType INDEL \
      --out ${TMPDIR}/${2}'_Indels_Selected.vcf'

mv ${TMPDIR}/${2}'_Indels_Selected.vcf'* ${3}/GATK/
##'-----------------------------------------------------------------------------------------#
