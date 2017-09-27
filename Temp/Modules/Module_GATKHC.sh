#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
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
#  Input       : Family ID                                                                  |
#  Input       : Path to Family's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : GATK Bundle Path                                                           |
#  Input       : Capture Kit                                                                |
#  Input       : Training Set - dbSNP                                                       |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 10                                                            |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignments/* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4}/ucsc.hg19.* ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Gather BAMs that are to be used as input
##'-----------------------------------------------------------------------------------------#
BAMS=`find ${TMPDIR} -type f -name "*bam" | sed 's/^/-I /' -`
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
        -nct 10 \
        -ped ${2}/${1}.ped \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding 100 \
        --dbsnp ${TMPDIR}/${DBSNP} \
        --max_alternate_alleles 50 \
        --pcr_indel_model CONSERVATIVE \
        ${BAMS} \
        -A QualByDepth \
        -A Coverage \
        -A VariantType \
        -A ClippingRankSumTest \
        -A DepthPerSampleHC \
        -A InbreedingCoeff \
        -o ${TMPDIR}/${1}.vcf
##'-----------------------------------------------------------------------------------------#

##' Move VCF file back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}.vcf* ${2}/GATK/
##'-----------------------------------------------------------------------------------------#
