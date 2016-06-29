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
#  Description : Run the Haplotype Caller on a family of sample, Call SNPs                  |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Raw Callset Folder                                                         |
#  Input 3     : Ped File                                                                   |
#  Input 4     : Log File                                                                   |
#  Input 5     : Training Set - dbSNP Excluding 129                                         |
#  Input 6     : Training Set - 1000 Genomes, Phase 1 snps                                  |
#  Input 7     : Training Set - Omni                                                        |
#  Input 8     : Training Set - HapMap                                                      |
#  Input 9     : VQSR Output Folder                                                         |
#  Input 10    : Capture Kits                                                               |
#  Resources   : Memory     - 35GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${2}/*.vcf* ${TMPDIR}
cp ${1}/ucsc.hg19.* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${7} ${TMPDIR}
cp ${8} ${TMPDIR}
cp ${10} ${TMPDIR}

mkdir ${9}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
DBSNP=$(basename "${5}")
HAP=$(basename "${8}")
PHASE1SNPS=$(basename "${6}")
OMNI=$(basename "${7}")
PED=$(basename "${3}")
CAP_KIT=$(basename "${10}")
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Variant Recalibrator for SNPs
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 1 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -ped ${TMPDIR}/${PED} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${10} \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${TMPDIR}/${DBSNP} \
        -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${TMPDIR}/${PHASE1SNPS} \
        -resource:omni,known=false,training=true,truth=true,prior=12.0 ${TMPDIR}/${OMNI} \
        -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${TMPDIR}/${HAP} \
        -an DP \
        -an QD \
        -an FS \
        -an SOR \
        -an MQ \
        -an MQRankSum \
        -an ReadPosRankSum \
        -an InbreedingCoeff \
        -mode SNP \
        -tranche 100.0 \
        -tranche 99.9 \
        -tranche 99.0 \
        -tranche 95.0 \
        -recalFile ${TMPDIR}/VR_SNPs.recal \
        -tranchesFile ${TMPDIR}/VR_SNPs.tranches \
        -rscriptFile ${TMPDIR}/VR_SNPs.R
##'-----------------------------------------------------------------------------------------#



##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 1 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -recalFile ${TMPDIR}/VR_SNPs.recal \
        -tranchesFile ${TMPDIR}/VR_SNPs.tranches \
        -mode SNP \
        --ts_filter_level 99.0 \
        -o ${TMPDIR}/VQSR_SNPs.vcf
##'-----------------------------------------------------------------------------------------#



##'Move Callset to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/VQSR_SNPs.vcf* ${9}
##'-----------------------------------------------------------------------------------------#
