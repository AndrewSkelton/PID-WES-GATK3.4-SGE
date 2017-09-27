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
BUNDLE="/opt/databases/GATK_bundle/2.8/b37/"

echo "$(date) : Starting gVCF Combination Run" > ${LOG_DIR}/CombinegVCFs_${NOW}.log
mkdir -p ${BRIDGE_BASE}/gVCF_Combined
##'-----------------------------------------------------------------------------------------#


##' Loop through Years
##'-----------------------------------------------------------------------------------------#
for i in ${BRIDGE_BASE}/gVCF/*
do
##'-----------------------------------------------------------------------------------------#


  ##' Collect Variables
  ##'-----------------------------------------------------------------------------------------#
  PARENT=$(basename "${i}")
  ##'-----------------------------------------------------------------------------------------#


  ##' Submit CombineGVCFs Script to Queue
  ##' $1 - Log File
  ##' $2 - Name of parent Directory
  ##' $3 - Bridge Base Directory
  ##' $4 - Output Directory
  ##' $5 - GATK Bundle Directory
  ##'-----------------------------------------------------------------------------------------#
  qsub -N "MA_gVCF_Combine_${PARENT}" \
          -hold_jid "PP_*" \
            ${SCRIPTS}/Modules/Module_CombinegVCFs.sh \
            ${LOG_DIR}/CombinegVCFs_${NOW}.log \
            ${PARENT} \
            ${BRIDGE_BASE} \
            ${BRIDGE_BASE}/gVCF_Combined \
            ${BUNDLE}
  ##'-----------------------------------------------------------------------------------------#


##' Close Loop
##'-----------------------------------------------------------------------------------------#
done
##'-----------------------------------------------------------------------------------------#
