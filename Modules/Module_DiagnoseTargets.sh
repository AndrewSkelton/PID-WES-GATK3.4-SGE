#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=25G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use GATK to Gentotype and phase (If appropriate)                           |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Reference Fasta                                                            |
#  Input       : GATK Bundle Path                                                           |
#  Input       : Capture Kit                                                                |
#  Input       : PADDING                                                                    |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#
