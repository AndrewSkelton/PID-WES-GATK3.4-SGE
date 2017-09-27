#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=25G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use GATK to Gentotype and phase (If appropriate)                           |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : GATK Bundle Path                                                           |
#  Input       : Capture Kit                                                                |
#  Input       : Training Set - dbSNP                                                       |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 1                                                            |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}_Clean_GATK.ba* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4}/ucsc.hg19.* ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Make Directory Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/GATK
##'-----------------------------------------------------------------------------------------#

##'Get Reference Filenames
##'-----------------------------------------------------------------------------------------#
REF_FA=$(basename "$3")
CAP_KIT=$(basename "$5")
DBSNP=$(basename "$6")
##'-----------------------------------------------------------------------------------------#

##' Family Based Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx18g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T HaplotypeCaller \
        -nct 1 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -I ${TMPDIR}/${1}'_Clean_GATK.bam' \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding 100 \
        --dbsnp ${TMPDIR}/${DBSNP} \
        --max_alternate_alleles 50 \
        --pcr_indel_model CONSERVATIVE \
        --emitRefConfidence GVCF \
        -variant_index_type LINEAR \
        -variant_index_parameter 128000 \
        -A QualByDepth \
        -A Coverage \
        -A VariantType \
        -A ClippingRankSumTest \
        -A DepthPerSampleHC \
        -A InbreedingCoeff \
        -o ${TMPDIR}/${1}'.g.vcf'
##'-----------------------------------------------------------------------------------------#

##' Move VCF file back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}.g.vcf* ${2}/GATK/
##'-----------------------------------------------------------------------------------------#
