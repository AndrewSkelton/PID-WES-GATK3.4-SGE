#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=50G
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
#  Description : Run GATK to genotype all gVCF Files                                        |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Output Directory                                                           |
#  Input 3     : Raw Callset File                                                           |
#  Input 4     : Pedigree File                                                              |
#  Input 5     : Log File                                                                   |
#  Input 6     : Capture Kit                                                                |
#  Input 7     : Padding                                                                    |
#  Input 8     : SNP Training Set   - dbSNP Excluding 129                                   |
#  Input 9     : SNP Training Set   - 1000 Genomes, Phase 1 snps                            |
#  Input 10    : SNP Training Set   - Omni                                                  |
#  Input 11    : SNP Training Set   - HapMap                                                |
#  Input 12    : Indel Training Set - Mills                                                 |
#  Resources   : Memory     - 50GB                                                          |
#  Resources   : Processors - 10                                                            |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${1}/human_g1k_v37.* ${TMPDIR}
cp ${2}/Raw_Callset.* ${TMPDIR}
cp ${4}  ${TMPDIR}
cp ${6}  ${TMPDIR}
cp ${8}  ${TMPDIR}
cp ${9}  ${TMPDIR}
cp ${10} ${TMPDIR}
cp ${11} ${TMPDIR}
cp ${12} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Starting VQSR" >> ${5}
echo $(date)" : Reference Files and VCF file copied to scratch" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Decompress VCF File
##'-----------------------------------------------------------------------------------------#
pigz -p 10 -d ${TMPDIR}/Raw_Callset.vcf.gz
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VCF File decompressed" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
REF_FA="human_g1k_v37.fasta"
PED=$(basename "${4}")
CAP_KIT=$(basename "${6}")
DBSNP=$(basename "${8}")
HAP=$(basename "${11}")
PHASE1SNPS=$(basename "${9}")
OMNI=$(basename "${10}")
MILLS=$(basename "${12}")
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Running VQSR for SNPs" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Variant Recalibrator for SNPs
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 1 \
        -R ${TMPDIR}/${REF_FA} \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -ped ${TMPDIR}/${PED} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${7} \
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
        -tranche 95.0 \
        -recalFile ${TMPDIR}/VR_SNPs.recal \
        -tranchesFile ${TMPDIR}/VR_SNPs.tranches \
        -rscriptFile ${TMPDIR}/VR_SNPs.R
# -tranche 100.0 \
# -tranche 99.9 \
# -tranche 95.0 \
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VQSR SNP Model Built" >> ${5}
echo $(date)" : Applying SNP Recalibration" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 1 \
        -R ${TMPDIR}/${REF_FA} \
        -input ${TMPDIR}/Raw_Callset.vcf \
        -recalFile ${TMPDIR}/VR_SNPs.recal \
        -tranchesFile ${TMPDIR}/VR_SNPs.tranches \
        -mode SNP \
        --ts_filter_level 95.0 \
        -o ${TMPDIR}/VQSR_SNPs.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : SNP Recalibration Complete" >> ${5}
echo $(date)" : Starting VQSR for Indels" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Variant Recalibrator for Indels
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 1 \
        -R ${TMPDIR}/${REF_FA} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${7} \
        -input ${TMPDIR}/VQSR_SNPs.vcf \
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
        -tranche 95.0 \
        -recalFile ${TMPDIR}/VR_INDELs.recal \
        -tranchesFile ${TMPDIR}/VR_INDELs.tranches \
        -rscriptFile ${TMPDIR}/VR_INDELs.R
# -tranche 100.0 \
# -tranche 99.9 \
# -tranche 95.0 \
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VQSR Indel Model Built" >> ${5}
echo $(date)" : Applying Indel Recalibration" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Indel Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 1 \
        -R ${TMPDIR}/${REF_FA} \
        -input ${TMPDIR}/VQSR_SNPs.vcf \
        -recalFile ${TMPDIR}/VR_INDELs.recal \
        -tranchesFile ${TMPDIR}/VR_INDELs.tranches \
        -mode INDEL \
        --ts_filter_level 95.0 \
        -o ${TMPDIR}/VQSR.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VQSR Complete!" >> ${5}
echo $(date)" : Applying Indel Recalibration" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Copy to Lustre
##'-----------------------------------------------------------------------------------------#
cp ${TMPDIR}/VQSR.vcf* ${2}
pigz -p 10 ${2}/VQSR.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VQSR.vcf Copied to Lustre" >> ${5}
echo $(date)" : Applying Pedigree Priors" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Indel Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T CalculateGenotypePosteriors \
        -R ${TMPDIR}/${REF_FA} \
        -V ${TMPDIR}/VQSR.vcf \
        --skipPopulationPriors \
        -ped ${TMPDIR}/${PED} \
        -o ${TMPDIR}/VQSR.wFamPost.vcf
##'-----------------------------------------------------------------------------------------#


##'Copy to Lustre
##'-----------------------------------------------------------------------------------------#
cp ${TMPDIR}/VQSR.wFamPost.vcf* ${2}
pigz -p 10 ${2}/VQSR.wFamPost.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : VQSR.wFamPost.vcf Copied to Lustre" >> ${5}
echo $(date)" : Doing a little bit of filtering..." >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Filter Low Quality Variants / Non Variants
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R ${TMPDIR}/${REF_FA} \
        -V ${TMPDIR}/VQSR.wFamPost.vcf \
        --filterExpression "GQ<20" \
        --filterName “lowGQ” \
        -o ${TMPDIR}/VQSR.wFamPost.tmp.vcf

java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T SelectVariants \
        -R ${TMPDIR}/${REF_FA} \
        --downsampling_type NONE \
        --excludeNonVariants \
        --variant ${TMPDIR}/VQSR.wFamPost.tmp.vcf \
        -o ${TMPDIR}/VQSR.wFamPost.filtered.vcf


java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantFiltration \
        -R ${TMPDIR}/${REF_FA} \
        -V ${TMPDIR}/VQSR.vcf \
        --filterExpression "GQ<20" \
        --filterName “lowGQ” \
        -o ${TMPDIR}/VQSR.tmp.vcf

java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T SelectVariants \
        -R ${TMPDIR}/${REF_FA} \
        --downsampling_type NONE \
        --excludeNonVariants \
        --variant ${TMPDIR}/VQSR.tmp.vcf \
        -o ${TMPDIR}/VQSR.filtered.vcf
##'-----------------------------------------------------------------------------------------#


##'Copy to Lustre
##'-----------------------------------------------------------------------------------------#
cp ${TMPDIR}/VQSR.filtered.vcf* ${2}
cp ${TMPDIR}/VQSR.wFamPost.filtered.vcf* ${2}
pigz -p 10 ${2}/VQSR.filtered.vcf
pigz -p 10 ${2}/VQSR.wFamPost.filtered.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Filtered Files copied to Lustre" >> ${5}
echo $(date)" : Tidied Up, Done!" >> ${5}
##'-----------------------------------------------------------------------------------------#
