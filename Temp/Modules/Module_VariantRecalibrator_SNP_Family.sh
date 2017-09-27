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
#  Description : Run the Haplotype Caller on a family of sample, Call SNPs                  |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Family ID                                                                  |
#  Input 3     : Array of Sample root Preprocessing directories                             |
#  Input 4     : Capture Kit                                                                |
#  Input 5     : Training Set - dbSNP Excluding 129                                         |
#  Input 6     : Training Set - 1000 Genomes, Phase 1 snps                                  |
#  Input 7     : Training Set - Omni                                                        |
#  Input 8     : Training Set - HapMap                                                      |
#  Input 9     : Ped File                                                                   |
#  Input 10    : Family Analysis Output Directory                                           |
#  Resources   : Memory     - 20GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${10}/GATK/${2}.vcf* ${TMPDIR}
cp ${1}/ucsc.hg19.* ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${7} ${TMPDIR}
cp ${8} ${TMPDIR}
cp ${9} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "${4}")
DBSNP=$(basename "${5}")
HAP=$(basename "${8}")
PHASE1SNPS=$(basename "${6}")
OMNI=$(basename "${7}")
PED=$(basename "${9}")
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Hard Filtering
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T SelectVariants \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -V ${TMPDIR}/${2}'.vcf' \
        -selectType SNP \
        -o ${TMPDIR}/${2}_raw_snps.vcf

java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -V ${TMPDIR}/${2}_raw_snps.vcf  \
        --filterExpression "QD < 2.0 || FS > 60.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
        --filterName "hard_snp_filter" \
        -o ${TMPDIR}/${2}_HardFiltered_SNPs.vcf

mkdir ${10}/GATK/Hard_Filtering
mv ${TMPDIR}/${2}_HardFiltered_SNPs.vcf* ${10}/GATK/Hard_Filtering/
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Variant Recalibrator for SNPs
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/${2}'.vcf' \
        -ped ${TMPDIR}/${PED} \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${TMPDIR}/${DBSNP} \
        -resource:1000G,known=false,training=true,truth=false,prior=10.0 ${TMPDIR}/${PHASE1SNPS} \
        -resource:omni,known=false,training=true,truth=true,prior=12.0 ${TMPDIR}/${OMNI} \
        -resource:hapmap,known=false,training=true,truth=true,prior=15.0 ${TMPDIR}/${HAP} \
        --maxGaussians 4 \
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
        -recalFile ${TMPDIR}/${2}'.VR_SNPs.recal' \
        -tranchesFile ${TMPDIR}/${2}'.VR_SNPs.tranches' \
        -rscriptFile ${TMPDIR}/${2}'.VR_SNPs.R'
##'-----------------------------------------------------------------------------------------#



##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -input ${TMPDIR}/${2}'.vcf' \
        -recalFile ${TMPDIR}/${2}'.VR_SNPs.recal' \
        -tranchesFile ${TMPDIR}/${2}'.VR_SNPs.tranches' \
        -mode SNP \
        --ts_filter_level 99.0 \
        -o ${TMPDIR}/${2}'_Recal_SNPs.vcf'
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Select Variants
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R ${TMPDIR}/"ucsc.hg19.fasta" \
      --downsampling_type NONE \
      --variant ${TMPDIR}/${2}'_Recal_SNPs.vcf' \
      -select "vc.isNotFiltered()" \
      -selectType SNP \
      --out ${TMPDIR}/${2}'_SNPs_Selected.vcf'

mv ${TMPDIR}/${2}'_SNPs_Selected.vcf'* ${10}/GATK/
##'-----------------------------------------------------------------------------------------#
