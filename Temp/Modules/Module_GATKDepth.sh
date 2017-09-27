#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
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
#  Description : Use GATK to calculate sample Depth                                         |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : Capture Kit                                                                |
#  Input       : GATK Bundle Path                                                           |
#  Resources   : Memory     - 15GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${2}/Alignment/Clean/${1}_Clean_GATK.* ${TMPDIR}
cp ${3} ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5}/ucsc.hg19.* ${TMPDIR}
##'-----------------------------------------------------------------------------------------#

##'Get Reference Filenames
##'-----------------------------------------------------------------------------------------#
REF_FA=$(basename "$3")
CAP_KIT=$(basename "$4")
##'-----------------------------------------------------------------------------------------#

##' Find Indel Realignment Targets
##'-----------------------------------------------------------------------------------------#
java -Xmx15g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
    -T DepthOfCoverage \
    -R ${TMPDIR}/${REF_FA} \
    -L ${TMPDIR}/${CAP_KIT} \
    -I ${TMPDIR}/${1}_Clean_GATK.bam \
    -o ${2}/Alignment/Clean/${1}_Coverage
##'-----------------------------------------------------------------------------------------#

##'If Clean Alignment is produced, Update Log
##'-----------------------------------------------------------------------------------------#
if [ -f "${2}/Alignment/Clean/${1}_Coverage*" ]; then
  echo $(date)" : GATK - Coverage Calculated" >> ${2}/${1}'.log'
else
  echo $(date)" : Error in GATK Procedure for Coverage Calculation" >> ${2}/${1}'.log'
fi
##'-----------------------------------------------------------------------------------------#
