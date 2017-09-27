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
#  Input       : PADDING                                                                    |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}_Clean_GATK.ba* ${TMPDIR}
cp ${4}/human_g1k_v37.* ${TMPDIR}
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


##' Haplotype Caller in gVCF Mode to output BAM file
##'-----------------------------------------------------------------------------------------#
java -Xmx18g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T HaplotypeCaller \
        -nct 1 \
        -R ${TMPDIR}/${REF_FA} \
        -I ${TMPDIR}/${1}'_Clean_GATK.bam' \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${7} \
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
        --bamWriterType CALLED_HAPLOTYPES \
        --bamOutput ${TMPDIR}/${1}'_HaplotypeAssembled.bam' #\
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${TMPDIR}/${1}_HaplotypeAssembled.bam" ]; then
  echo $(date)" : ${1} BAM File Generated" >> ${8}
else
  echo $(date)" : ${1} ERROR - BAM Missing on Scratch" >> ${8}
fi
##'-----------------------------------------------------------------------------------------#


##' Move Alignment file back to Lustre
##'-----------------------------------------------------------------------------------------#
mkdir -p ${2}/Alignment/HaplotypeAssembled/
mv ${TMPDIR}/${1}'_HaplotypeAssembled.bam' ${2}/Alignment/HaplotypeAssembled/
mv ${TMPDIR}/${1}'_HaplotypeAssembled.bai' ${2}/Alignment/HaplotypeAssembled/
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${2}/Alignment/HaplotypeAssembled/${1}_HaplotypeAssembled.bam" ]; then
  echo $(date)" : ${1} BAM File Successfully moved to Cluster Storage" >> ${8}
else
  echo $(date)" : ${1} ERROR - BAM Missing on Cluster Storage" >> ${8}
fi
##'-----------------------------------------------------------------------------------------#
