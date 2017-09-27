#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=60G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - BWA_MEM                                            |
#-------------------------------------------------------------------------------------------#

# $1 - Read Group String
# $2 - Reference fasta
# $3 - Sample ID
# $4 - Forward Reads
# $5 - Reverse Reads
# $6 - Output Path

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $6'/BWA_Align/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Fastq Files to Local Node Scratch Space' >> $6/$3'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp $6/*.gz $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'BWA MEM Parameters: -M, -R' >> $6/$3'.log'
echo 'BWA MEM Started: '$(date) >> $6/$3'.log'
echo `ls $TMPDIR` >> $6/$3'.log'
##'-----------------------------------------------------------------------------------------#

##'Run Alignment BWA MEM
##'-----------------------------------------------------------------------------------------#
bwa mem \
        -t 5 \
        -M \
        -R $1 \
        $2 \
        $TMPDIR/$4 \
        $TMPDIR/$5 > $TMPDIR/$3'_BWA.sam'

# mv $TMPDIR/$3'_BWA.sam' $6/'GATK_Pipeline'
mv $TMPDIR/$3'_BWA.sam' $6
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'BWA MEM Complete: '$(date) >> $6/$3'.log'
##'-----------------------------------------------------------------------------------------#
