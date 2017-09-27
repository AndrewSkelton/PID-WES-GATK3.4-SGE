#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=5G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Trimmomatic                                        |
#-------------------------------------------------------------------------------------------#

##' $1 - Forward Reads
##' $2 - Reverse Reads
##' $3 - Sample ID
##' $4 - Output Path

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $4/$3'.log'
echo '##################################################' >> $4/$3'.log'
echo 'Copying Fastq Files to Local Node Scratch Space' >> $4/$3'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
# cp $4/*.gz $TMPDIR
cp $4/Original_Data/*.gz $TMPDIR
cp /home/nas151/adapters/Uni_Adapt.fa $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Trimmomatic Started in PE Mode' >> $4/$3'.log'
echo `ls $TMPDIR` >> $4/$3'.log'
echo `ls $TMPDIR`
##'-----------------------------------------------------------------------------------------#

##'Run Trimmomatic
##'-----------------------------------------------------------------------------------------#
java -jar -Xmx2g ~/trimmomatic-0.35.jar \
            PE \
            -threads 5 \
            -phred33 \
            $TMPDIR/$1 \
            $TMPDIR/$2 \
            -baseout $TMPDIR/$3.fastq.gz \
            ILLUMINACLIP:$TMPDIR/Uni_Adapt.fa:2:30:10
##'-----------------------------------------------------------------------------------------#

##'Organise Files
##'-----------------------------------------------------------------------------------------#
echo `ls $TMPDIR`
mv $TMPDIR/$3_1P.fastq.gz $4/$3_R1.fastq.gz
mv $TMPDIR/$3_2P.fastq.gz $4/$3_R2.fastq.gz
mv $TMPDIR/$3_1U.fastq.gz $4/Trimmomatic_Unpaired
mv $TMPDIR/$3_2U.fastq.gz $4/Trimmomatic_Unpaired
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Fastq Files trimmed for Illumina Adapters' >> $4/$3'.log'
echo '##################################################' >> $4/$3'.log'
echo '' >> $4/$3'.log'
echo `ls $TMPDIR`
##'-----------------------------------------------------------------------------------------#
