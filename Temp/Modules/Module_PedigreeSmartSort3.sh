#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=1G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Map files to their pedigree and dynamically create ped files               |
#  Version     : 3.0                                                                        |
#  Input       : Base Directory to Batch Preprocessing Directory                            |
#  Input       : Path to Reference Files                                                    |
#  Input       : Base directory for Family Analysis - Archive                               |
#  Input       : Base directory for Family Analysis - Actionable                            |
#  Resources   : Memory     - 1GB                                                           |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#
