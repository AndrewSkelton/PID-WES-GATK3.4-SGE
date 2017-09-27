#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=5G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Calculate Exome Seq Metrics                        |
#-------------------------------------------------------------------------------------------#

# $1 - File in
# $2 - File out
# $3 - Sample ID
# $4 - Capture Kit
# $5 - PID bed

##'Notes
##'-----------------------------------------------------------------------------------------#
##' Column Names:
##'   Sample ID
##'   Number of Bases Covered by Capture Kit
##'   Average Coverage
##'   % Bases with > 49x Coverage
##'   % Bases with 0 Coverage
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${1}"/GATK_Pipeline/Clean_Alignment/"*".bam" $TMPDIR
# cp ${1} $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Gather Metrics for Coverage
##'-----------------------------------------------------------------------------------------#
coverageBed -abam ${TMPDIR}/${3}_post_recal.bam -b $4 -d > $TMPDIR/per_base_coverage.txt
coverageBed -abam ${TMPDIR}/${3}_post_recal.bam -b $5 -d > $TMPDIR/pid_per_base_coverage.txt
# coverageBed -abam ${TMPDIR}/${3}.bam -b $4 -d > $TMPDIR/per_base_coverage.txt

NUMBER_OF_BASES=`wc -l ${TMPDIR}/per_base_coverage.txt | awk '{print $1}'`
AV_COV=`awk '{ total += $6 } END { print total/NR }' ${TMPDIR}/per_base_coverage.txt`
BASES_50_TIMES=`awk '{FS="\t"}{if($6 > "49") print $0}' ${TMPDIR}/per_base_coverage.txt | wc -l`
BASES_20_TIMES=`awk '{FS="\t"}{if($6 > "19") print $0}' ${TMPDIR}/per_base_coverage.txt | wc -l`
BASES_30_TIMES=`awk '{FS="\t"}{if($6 > "29") print $0}' ${TMPDIR}/per_base_coverage.txt | wc -l`
BASES_0_TIMES=`awk '{FS="\t"}{if($6 == "0") print $0}' ${TMPDIR}/per_base_coverage.txt | wc -l`
PID_AV_COV=`awk '{ total += $10 } END { print total/NR }' ${TMPDIR}/pid_per_base_coverage.txt`
##'-----------------------------------------------------------------------------------------#

##'Calculations
##'-----------------------------------------------------------------------------------------#
TWENTY_PERC=`echo '('${BASES_30_TIMES}'/'${NUMBER_OF_BASES}')*100' | bc -l | awk '{printf("%.2f",$1)}'`
THIRTY_PERC=`echo '('${BASES_30_TIMES}'/'${NUMBER_OF_BASES}')*100' | bc -l | awk '{printf("%.2f",$1)}'`
FIFTY_PERC=`echo '('${BASES_50_TIMES}'/'${NUMBER_OF_BASES}')*100' | bc -l | awk '{printf("%.2f",$1)}'`
ZERO_PERC=`echo '('${BASES_0_TIMES}'/'${NUMBER_OF_BASES}')*100' | bc -l | awk '{printf("%.2f",$1)}'`
##'-----------------------------------------------------------------------------------------#

echo "Number of Bases: "$NUMBER_OF_BASES
echo "Average Coverage: "$AV_COV
echo "Bases =>20x Coverage: "$TWENTY_PERC"%"
echo "Bases =>30x Coverage: "$THIRTY_PERC"%"
echo "Bases =>50x Coverage: "$FIFTY_PERC"%"
echo "Bases 0 Coverage: "$ZERO_PERC"%"
echo "Average PID Coverage: "$PID_AV_COV
echo ""
echo `ls -lh $TMPDIR`
echo ""
echo ${3}" \t "${NUMBER_OF_BASES}" \t "${AV_COV}" \t "${TWENTY_PERC}"% \t "${THIRTY_PERC}"% \t "${FIFTY_PERC}"% \t "${ZERO_PERC}"% \t "${PID_AV_COV}

##'Write Entry to Metrics Table
##'-----------------------------------------------------------------------------------------#
echo -e ${3}" \t "${NUMBER_OF_BASES}" \t "${AV_COV}" \t "${TWENTY_PERC}"% \t "${THIRTY_PERC}"% \t "${FIFTY_PERC}"% \t "${ZERO_PERC}"% \t "${PID_AV_COV} >> $2
##'-----------------------------------------------------------------------------------------#
