#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=30G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use GATK to locally realign around Indels, and Recalibrate base quality    |
#                scores                                                                     |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : Training Set - MILLS                                                       |
#  Input       : Training Set - 1000 Genomes, Phase 1 Indels                                |
#  Input       : Training Set - dbSNP                                                       |
#  Input       : Capture Kit                                                                |
#  Input       : GATK Bundle Path                                                           |
#  Input       : PADDING                                                                    |
#  Resources   : Memory     - 30GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}*_Marked.* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${7} ${TMPDIR}
cp ${8}/ucsc.hg19.* ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Get Reference Filenames
##'-----------------------------------------------------------------------------------------#
REF_FA=$(basename "$3")
MILLS=$(basename "$4")
PHASE1INDELS=$(basename "$5")
DBSNP=$(basename "$6")
CAP_KIT=$(basename "$7")
##'-----------------------------------------------------------------------------------------#

##' Find Indel Realignment Targets
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T RealignerTargetCreator \
        -nt 5 \
        -R ${TMPDIR}/${REF_FA} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${9} \
        -known ${TMPDIR}/${MILLS} \
        -known ${TMPDIR}/${PHASE1INDELS} \
        -I ${TMPDIR}/${1}*_Marked.bam \
        -o ${TMPDIR}/realignment_targets.list
##'-----------------------------------------------------------------------------------------#

##' Apply Realignment
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T IndelRealigner \
        -R ${TMPDIR}/${REF_FA} \
        -known ${TMPDIR}/${MILLS} \
        -known ${TMPDIR}/${PHASE1INDELS} \
        -LOD 0.4 \
        --maxReadsForRealignment 10000000 \
        --maxConsensuses 300 \
        --maxReadsForConsensuses 1200 \
        -targetIntervals ${TMPDIR}/realignment_targets.list \
        -I ${TMPDIR}/${1}*_Marked.bam \
        -o ${TMPDIR}/${1}_Realigned.bam
##'-----------------------------------------------------------------------------------------#

##' BQSR
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T BaseRecalibrator \
        -nct 5 \
        -R ${TMPDIR}/${REF_FA} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${9} \
        -knownSites ${TMPDIR}/${MILLS} \
        -knownSites ${TMPDIR}/${PHASE1INDELS} \
        -knownSites ${TMPDIR}/${DBSNP} \
        -I ${TMPDIR}/${1}_Realigned.bam \
        -o ${TMPDIR}/recal_data.table
##'-----------------------------------------------------------------------------------------#

##' Apply Recalibrated Base Quality Scores
##'-----------------------------------------------------------------------------------------#
java -Xmx25g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T PrintReads \
        -nct 5 \
        -R ${TMPDIR}/${REF_FA} \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${9} \
        -BQSR ${TMPDIR}/recal_data.table \
        -I ${TMPDIR}/${1}_Realigned.bam \
        -o ${TMPDIR}/${1}_Clean_GATK.bam
##'-----------------------------------------------------------------------------------------#

##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}_Clean_GATK.* ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#

##'If Clean Alignment is produced, Clean the directory of SAM files. Update Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${2}/Alignment/Clean/${1}_Clean_GATK.bam" ]; then
  echo $(date)" : GATK - Indel Realignment Targets Found" >> ${2}/${1}'.log'
  echo $(date)" : GATK - Realignment Complete" >> ${2}/${1}'.log'
  echo $(date)" : GATK - BQSR Calculated" >> ${2}/${1}'.log'
  echo $(date)" : GATK - Base Quality Scores Recalibrated" >> ${2}/${1}'.log'
  rm ${2}/Alignment/Clean/*_Marked*
  rm ${2}/Alignment/Clean/*_metrics.txt
  rm -r ${2}/Alignment/Paired
  rm -r ${2}/Alignment/Unpaired
else
  echo $(date)" : Error in GATK Procedure" >> ${2}/${1}'.log'
fi
##'-----------------------------------------------------------------------------------------#
