#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=35G
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
#  Description : Run the VQSR on a raw callset, Indel specific                              |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Raw Callset Folder                                                         |
#  Input 3     : Ped File                                                                   |
#  Input 4     : Log File                                                                   |
#  Input 5     : Training Set - dbSNP Excluding 129                                         |
#  Input 6     : Training Set - Mills                                                       |
#  Input 7     : VQSR Output Folder                                                         |
#  Input 8     : Capture Kit                                                                |
#  Resources   : Memory     - 35GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
# cp ${2}/*.vcf* ${TMPDIR}
cp ${7}/Raw_Callset.vcf* ${TMPDIR}
cp ${1}/ucsc.hg19.fasta* ${TMPDIR}
cp ${1}/ucsc.hg19.dict ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${8} ${TMPDIR}

mkdir ${7}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
DBSNP=$(basename "${5}")
MILLS=$(basename "${6}")
PED=$(basename "${3}")
CAP_KIT=$(basename "${8}")
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Variant Recalibrator for Indels
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 1 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${9} \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -ped ${TMPDIR}/${PED} \
        -resource:mills,known=false,training=true,truth=true,prior=12.0 ${TMPDIR}/${MILLS} \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${TMPDIR}/${DBSNP} \
        --maxGaussians 4 \
        -an QD \
        -an DP \
        -an FS \
        -an SOR \
        -an MQRankSum \
        -an ReadPosRankSum \
        -an InbreedingCoeff \
        -mode INDEL \
        -tranche 100.0 \
        -tranche 99.9 \
        -tranche 99.0 \
        -tranche 95.0 \
        -recalFile ${TMPDIR}/VR_INDELs.recal \
        -tranchesFile ${TMPDIR}/VR_INDELs.tranches \
        -rscriptFile ${TMPDIR}/VR_INDELs.R

        #-resource:axiom,known=false,training=true,truth=false,prior=10.0 ${TMPDIR}/${AXIOM} \
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Indel Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 1 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -recalFile ${TMPDIR}/VR_INDELs.recal \
        -tranchesFile ${TMPDIR}/VR_INDELs.tranches \
        -mode INDEL \
        --ts_filter_level 99.0 \
        -o ${TMPDIR}/VQSR_Indels.vcf
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Print Just INDELs
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T SelectVariants \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -V ${TMPDIR}/VQSR_Indels.vcf \
        -selectType INDEL \
        -o ${TMPDIR}/VQSR_INDELs_Only.vcf
##'-----------------------------------------------------------------------------------------#



##'Move Callset to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/VQSR_INDELs_Only.vcf* ${7}/VQSR/
##'-----------------------------------------------------------------------------------------#
