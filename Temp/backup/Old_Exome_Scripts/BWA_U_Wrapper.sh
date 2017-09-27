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
#  Description : Job Submission Script - BWA_MEM Unpaired                                   |
#-------------------------------------------------------------------------------------------#

##' $1 - Read Group String
##' $2 - Reference fasta
##' $3 - Sample ID
##' $4 - Output Path

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $6'/BWA_Align/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Fastq Files to Local Node Scratch Space' >> $4/$3'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
zcat $4/*'_1U'* > $4/$3'_U.fastq'
zcat $4/*'_2U'* >> $4/$3'_U.fastq'
pigz $4/$3'_U.fastq'
cp $4/$3'_U.fastq.gz' $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'BWA MEM Parameters: -M, -R' >> $4/$3'.log'
echo 'BWA MEM Started: '$(date) >> $4/$3'.log'
echo `ls $TMPDIR` >> $4/$3'.log'
##'-----------------------------------------------------------------------------------------#

##'Run Alignment BWA MEM
##'-----------------------------------------------------------------------------------------#
bwa mem \
        -t 5 \
        -M \
        -R $1 \
        -p \
        $2 \
        $TMPDIR/$3'_U.fastq.gz' > $TMPDIR/$3'_U_BWA.sam'

# mv $TMPDIR/$3'_BWA.sam' $6/'GATK_Pipeline'
mv $TMPDIR/$3'_U_BWA.sam' $5
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'BWA MEM Complete: '$(date) >> $4/$3'.log'
##'-----------------------------------------------------------------------------------------#