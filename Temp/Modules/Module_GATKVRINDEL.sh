#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=20G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use GATK to Select Variants, Indel Specific                                |
#  Input       : Family ID                                                                  |
#  Input       : Path to Family's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : GATK Bundle Path                                                           |
#  Input       : Capture Kit                                                                |
#  Input       : Training Set - dbSNP Excluding 129                                         |
#  Input       : Training Set - mills                                                       |
#  Resources   : Memory     - 20GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/GATK/${1}.* ${TMPDIR}
cp ${2}/Alignments/* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4}/ucsc.hg19.* ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${7} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Gather BAMs that are to be used as input
##'-----------------------------------------------------------------------------------------#
BAMS=`find ${TMPDIR} -type f -name "*bam" | sed 's/^/-I /' -`
##'-----------------------------------------------------------------------------------------#

##'Get Reference Filenames
##'-----------------------------------------------------------------------------------------#
REF_FA=$(basename "$3")
CAP_KIT=$(basename "$5")
DBSNP=$(basename "$6")
MILLS=$(basename "$7")
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Recalibration Targets
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantRecalibrator \
        -nt 5 \
        -R ${TMPDIR}/${REF_FA} \
        -input ${TMPDIR}/${1}'.vcf' \
        -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 ${TMPDIR}/${DBSNP} \
        -resource:mills,known=false,training=true,truth=true,prior=12.0 ${TMPDIR}/${MILLS} \
        -ped ${2}/${1}.ped \
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
        -recalFile ${TMPDIR}/${1}'.VR_INDELs.recal' \
        -tranchesFile ${TMPDIR}/${1}'.VR_INDELs.tranches' \
        -rscriptFile ${TMPDIR}/${1}'.VR_INDELs.R'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Recalibration Apply
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T ApplyRecalibration \
        -nt 5 \
        -ped ${2}/${1}.ped \
        -R ${TMPDIR}/${REF_FA} \
        -input ${TMPDIR}/${1}'.vcf' \
        -recalFile ${TMPDIR}/${1}'.VR_INDELs.recal' \
        -tranchesFile ${TMPDIR}/${1}'.VR_INDELs.tranches' \
        -mode INDEL \
        --ts_filter_level 99.0 \
        -o ${TMPDIR}/${1}'_Recal_INDELs.vcf'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Select Variants
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R ${TMPDIR}/${REF_FA} \
      --downsampling_type NONE \
      --variant ${TMPDIR}/${1}'_Recal_INDELs.vcf' \
      -selectType INDEL \
      --out ${TMPDIR}/${1}'_INDELs_Selected.vcf' \
      -select "vc.isNotFiltered()"
##'-----------------------------------------------------------------------------------------#

##'Run GATK: SNP Annotate
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T VariantAnnotator \
        -nt 5 \
        -ped ${2}/${1}.ped \
        -R ${TMPDIR}/${REF_FA} \
        -V ${TMPDIR}/${1}'_INDELs_Selected.vcf' \
        -L ${TMPDIR}/${1}'_INDELs_Selected.vcf' \
        $BAMS \
        -A Coverage \
        -A GenotypeSummaries \
        -A PossibleDeNovo \
        -A SnpEff \
        -A VariantType \
        -A DepthPerAlleleBySample \
        -A DepthPerSampleHC \
        -o ${TMPDIR}/${1}'_INDELs.vcf'
##'-----------------------------------------------------------------------------------------#

##' Move VCF file back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}_INDELs.vcf* ${2}/GATK/
##'-----------------------------------------------------------------------------------------#
