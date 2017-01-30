#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Core Script for Genotyping Whole Exome Sequencing (WES) Data               |
#                Create pedigree file based on existing Structure                           |
#  Modules     : Pedigree Check                                                             |
#-------------------------------------------------------------------------------------------#



##'Set Base Directory and Capture Kits
##'-----------------------------------------------------------------------------------------#
PROJ_BASE="/home/nas151/WORKING_DATA/Exome_Project/"
SCRIPTS=${PROJ_BASE}/Scripts
BUNDLE="/opt/databases/GATK_bundle/2.8/hg19"
BASE_DIR="${PROJ_BASE}/SamplePreprocessing"
LOG=${PROJ_BASE}Scripts/Ref/PedigreeGen.log
##'-----------------------------------------------------------------------------------------#



##'Rename based on naming convention
##' $1 - Path to preprocessing base directory
##' $2 - Filename Map
##'---------------------------------------------------------------------------------------#
sh ${SCRIPTS}/Modules/Module_PedigreeGen.sh \
        ${PROJ_BASE}Preprocessing/ \
        ${PROJ_BASE}Scripts/Ref/ \
        ${PROJ_BASE}Scripts/Ref/
##'---------------------------------------------------------------------------------------#
