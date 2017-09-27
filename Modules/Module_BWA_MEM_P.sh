#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=40G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Run BWA MEM on Paired-End Reads                                            |
#  Input       : Read Group                                                                 |
#  Input       : Reference Fasta                                                            |
#  Input       : Sample ID                                                                  |
#  Input       : Path to Paired Fastq Files                                                 |
#  Input       : Path to Sample's preprocessing base                                        |
#  Input       : Log File                                                                   |
#  Resources   : Memory     - 40GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${3} Starting Alignment" >> ${6}
##'-----------------------------------------------------------------------------------------#


##'Add Dep
##'-----------------------------------------------------------------------------------------#
module add apps/samtools/1.3.1
##'-----------------------------------------------------------------------------------------#


##'Make Folder Structure
##'-----------------------------------------------------------------------------------------#
mkdir -p ${5}/Alignment/Paired
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node
##'-----------------------------------------------------------------------------------------#
cp ${4}/*.gz ${TMPDIR}
cp ${2}* ${TMPDIR}
REF_IN=$(basename "$2")
##'-----------------------------------------------------------------------------------------#


##'Run BWA MEM With Paired Reads
##'-----------------------------------------------------------------------------------------#
bwa mem \
        -t 5 \
        -M \
        -R ${1} \
        ${TMPDIR}/${REF_IN} \
        ${TMPDIR}/${3}_R1.fastq.gz \
        ${TMPDIR}/${3}_R2.fastq.gz | samtools view -bS - > ${TMPDIR}/${3}'_P_BWA.bam'
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ ! -f ${TMPDIR}/${3}'_P_BWA.bam' ]; then
  echo $(date)" : ${3} Alignment file not created, bad juju." >> ${6}
elif [[ ! $(find ${TMPDIR}/${3}_P_BWA.bam -type f -size +1000000c 2>/dev/null) ]]; then
  echo $(date)" : ${3} Alignment file exists, but not very big... bad juju." >> ${6}
else
  echo $(date)" : ${3} Alignment on scratch looks good." >> ${6}
fi


##'-----------------------------------------------------------------------------------------#


##'Move Files back to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/${3}'_P_BWA.bam' ${5}/Alignment/Paired
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
if [ ! -f ${5}/Alignment/Paired/${3}_P_BWA.bam ]; then
  echo $(date)" : ${3} Alignment file Not found on Cluster Filesystem... bad juju." >> ${6}
elif [[ ! $(find ${5}/Alignment/Paired/${3}_P_BWA.bam -type f -size +1000000c 2>/dev/null) ]]; then
  echo $(date)" : ${3} Alignment file exists on Cluster Filesystem, but not very big... bad juju." >> ${6}
else
  echo $(date)" : ${3} Alignment moved to cluster filesystem." >> ${6}
fi
##'-----------------------------------------------------------------------------------------#
