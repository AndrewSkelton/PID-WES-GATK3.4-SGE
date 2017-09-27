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
#  Input       : Log File                                                                   |
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
cp ${8}/human_g1k_v37.* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
cp ${7} ${TMPDIR}
cp ${3}.* ${TMPDIR}
ls ${TMPDIR}
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
# --fix_misencoded_quality_scores
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Realignment Target File Created" >> ${10}
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


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} Realignment Complete" >> ${10}
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


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} BQSR Training Complete" >> ${10}
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


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${1} BQSR Applied to Alignment" >> ${10}
##'-----------------------------------------------------------------------------------------#


##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${1}_Clean_GATK.* ${2}/Alignment/Clean
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${2}/Alignment/Clean/${1}_Clean_GATK.bam" ]; then
  echo $(date)" : ${1} Clean BAM Moved to cluster storage from Node Scratch" >> ${10}
  rm ${2}/Alignment/Clean/*_Marked*
  rm ${2}/Alignment/Clean/*_metrics.txt
  rm -r ${2}/Alignment/Paired
  rm -r ${2}/Alignment/Unpaired
  echo $(date)" : ${1} Redundent Directories Removed" >> ${10}
  echo $(date)" : ${1} Alignment Prep Complete!" >> ${10}
else
  echo $(date)" : ${1} ERROR - Something went wrong" >> ${10}
fi
##'-----------------------------------------------------------------------------------------#
