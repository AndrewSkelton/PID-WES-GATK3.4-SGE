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
#  Description : Run Picard Tools, Mark Duplicates, Index                                   |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Resources   : Memory     - 30GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#

##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/picard/1.130
##'-----------------------------------------------------------------------------------------#



##'Replace Read Group
##'-----------------------------------------------------------------------------------------#
java -Xmx16g -jar ${PICARD_PATH}/picard.jar AddOrReplaceReadGroups \
            I=${2}/Alignment/Clean/${1}_Clean_GATK.bam \
            O=${2}/Alignment/Clean/${1}_Clean_GATK_RG.bam \
            RGID=${3} \
            RGLB=lib1 \
            RGPL=illumina \
            RGPU=unit1 \
            RGSM=${1} \
            CREATE_INDEX=true
##'-----------------------------------------------------------------------------------------#
