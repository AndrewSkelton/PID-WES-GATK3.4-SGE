#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=15G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile
module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Script                                                             |
#  Description : Run DiagnoseTargets to gather coverage information                         |
#  Version     : 1.0                                                                        |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : GATK Bundle Path                                                           |
#  Input       : Capture Kit                                                                |
#  Input       : Training Set - dbSNP                                                       |
#  Input       : PADDING                                                                    |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 15GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${2}/VQSR_INDELs_Only.vcf* ${TMPDIR}
cp ${2}/VQSR_SNPs_Only.vcf* ${TMPDIR}
cp ${1}/ucsc.hg19.fasta* ${TMPDIR}
cp ${1}/ucsc.hg19.dict ${TMPDIR}
mkdir ${4}
##'-----------------------------------------------------------------------------------------#



##'Run GATK: CombineVariants
##'-----------------------------------------------------------------------------------------#
java -Xmx10g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T DiagnoseTargets \
        -R ${TMPDIR}/${REF_FA} \
        ${BAM_LIST} \
        -L ${CAP_KIT} \
        -o ${TMPDIR}/${BATCH}_Coverage.vcf
##'-----------------------------------------------------------------------------------------#



##'Move Callset to Cluster File System
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${BATCH}_Coverage.vcf* ${4}
##'-----------------------------------------------------------------------------------------#
