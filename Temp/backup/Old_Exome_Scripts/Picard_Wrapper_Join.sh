#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=30G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/picard/1.130

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Picard Tools                                       |
#-------------------------------------------------------------------------------------------#

# $1 - Output Path
# $2 - Sample ID

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $1'/Picard/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying SAM File to Local Node Scratch Space' >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
# cp $1/'GATK_Pipeline'/$2'_BWA.sam' $TMPDIR
cp $1/$2'_BWA.sam' $TMPDIR
cp $1/$2'_U_BWA.sam' $TMPDIR
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $1/$2'.log'
echo 'Picard Tools Started: '$(date) >> $1/$2'.log'
echo 'Sorting SAM and Converting to BAM' >> $1/$2'.log'
# echo `ls $TMPDIR` >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools to sort and convert to BAM
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  MergeSamFiles \
                                  INPUT=$TMPDIR/$2'_BWA.sam' \
                                  INPUT=$TMPDIR/$2'_U_BWA.sam' \
                                  OUTPUT=$TMPDIR/$2'_merged.sam'
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools to sort and convert to BAM
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  SortSam \
                                  INPUT=$TMPDIR/$2'_merged.sam' \
                                  OUTPUT=$TMPDIR/$2'_sorted.bam' \
                                  SORT_ORDER=coordinate

rm $TMPDIR/*'.sam'
# OUTPUT=$TMPDIR/$2'_sorted.bam' \
# echo `ls $TMPDIR` >> $1/$2'.log'
# rm $1/'Original_Data'/$2'_BWA.sam'
# echo `ls $TMPDIR` >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Picard Tools Finished: '$(date) >> $1/$2'.log'
echo 'BAM File Written to local scratch '$TMPDIR >> $1/$2'.log'
echo 'Picard Tools Started: '$(date) >> $1/$2'.log'
echo 'Marking Duplicates' >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#


##'Run Picard Tools to mark duplicates, and move output from local scratch
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  MarkDuplicates \
                                  INPUT=$TMPDIR/$2'_sorted.bam' \
                                  OUTPUT=$TMPDIR/$2'_dedup_sorted.bam' \
                                  METRICS_FILE=$TMPDIR/$2'_metrics.txt'
# rm $1/'GATK_Pipeline'/$2'_BWA.sam'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Picard Tools Finished: '$(date) >> $1/$2'.log'
echo 'BAM File Written to Wroking Directory '$TMPDIR >> $1/$2'.log'
echo 'Picard Tools Started: '$(date) >> $1/$2'.log'
echo 'Indexing BAM' >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run Picard Tools to Index the BAM
##'-----------------------------------------------------------------------------------------#
java -Xmx20g -jar $PICARD_PATH/picard.jar \
                                  BuildBamIndex \
                                  INPUT=$TMPDIR/$2'_dedup_sorted.bam'

# mv $TMPDIR/$2'_sorted.bam'* $1/'GATK_Pipeline'
# mv $TMPDIR/$2'_sorted_Original.bam' $1/'Original_Data'
mv $TMPDIR/$2'_dedup_sorted.bam' $1/'GATK_Pipeline'
mv $TMPDIR/$2'_dedup_sorted.bai' $1/'GATK_Pipeline'
mv $TMPDIR/$2'_metrics.txt' $1/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Picard Tools Finished: '$(date) >> $1/$2'.log'
echo 'BAM Index File Written to Working Directory '$TMPDIR >> $1/$2'.log'
echo 'Stage 2 Complete' >> $1/$2'.log'
##'-----------------------------------------------------------------------------------------#
