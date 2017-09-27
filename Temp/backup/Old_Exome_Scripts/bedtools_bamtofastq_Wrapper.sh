#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=10G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - bedtools bamtofastq                                |
#-------------------------------------------------------------------------------------------#

# $1 - Output Path
# $2 - Sample ID

##'Run bedtools to convert bam to fastq
##'-----------------------------------------------------------------------------------------#
cp $1/$2'.bam' $TMPDIR
bedtools bamtofastq -i $TMPDIR/$2'.bam' -fq $TMPDIR/$2'_R1.fastq' -fq2 $TMPDIR/$2'_R2.fastq'
rm $TMPDIR/$2'.bam'
##'-----------------------------------------------------------------------------------------#

##'Convert to fastq.gz and move to working directory
##'-----------------------------------------------------------------------------------------#
pigz $TMPDIR/$2'_R1.fastq'
pigz $TMPDIR/$2'_R2.fastq'
mv $TMPDIR/*.gz $1
##'-----------------------------------------------------------------------------------------#
