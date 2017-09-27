#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Description : Parent Script for Analysis of Whole Exome Sequencing (WES) Data            |
#-------------------------------------------------------------------------------------------#


##'Set Base Directory and Reference Datasets
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/DNA_Sequencing/"
BRIDGE_BASE=${PROJ_BASE}/Bridge/
LOG_DIR=${PROJ_BASE}/Logs/
SCRIPTS=${PROJ_BASE}/Scripts
NOW=$(date +"%Y%m%d")
##'-----------------------------------------------------------------------------------------#


##'Run MultiQC
##' $1 - Base Bridge Directory
##' $2 - Log File
##'-----------------------------------------------------------------------------------------#
qsub -N "AN_MultiQC" \
        -hold_jid "PP_*" \
          ${SCRIPTS}/Modules/Module_Multiqc.sh \
          $BRIDGE_BASE \
          ${LOG_DIR}/MultiQC_${NOW}.log
##'-----------------------------------------------------------------------------------------#
