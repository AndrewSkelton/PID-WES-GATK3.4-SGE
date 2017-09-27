#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=25G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Type        : Cluster Submission Script                                                  |
#  Description : Use GATK to generate combined gVCF files by year                           |
#  Input       : Log File                                                                   |
#  Input       : Name of parent Directory                                                   |
#  Input       : Bridge Base Directory                                                      |
#  Input       : Output Directory                                                           |
#  Input       : GATK Bundle Directory                                                      |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 1                                                             |
#-------------------------------------------------------------------------------------------#


##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/gatk/3.4-protected
##'-----------------------------------------------------------------------------------------#


##'Copy Files to Node and decompress gvcfs
##'-----------------------------------------------------------------------------------------#
cp ${5}/human_g1k_v37.* ${TMPDIR}
cp `find ${3}/gVCF/${2}/ -type f -name "*.g.vcf.*"` ${TMPDIR}

for i in ${TMPDIR}/*.g.vcf.gz
do
  pigz -p 10 -d $i
done

REF_FA="human_g1k_v37.fasta"
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${2} gVCF Files Copied to Node Scratch Space and Decompressed" >> ${1}
##'-----------------------------------------------------------------------------------------#


##' CombineGVCFs
##'-----------------------------------------------------------------------------------------#
list=`ls ${TMPDIR}/*.g.vcf | sed 's/^/--variant /'`
java -Xmx18g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
        -T CombineGVCFs \
        -nct 1 \
        -R ${TMPDIR}/${REF_FA} \
        ${list} \
        -o ${TMPDIR}/${2}.g.vcf
ls ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Move to Lustre
##'-----------------------------------------------------------------------------------------#
pigz -p 10 ${TMPDIR}/${2}.g.vcf
mv ${TMPDIR}/${2}.g.vcf* ${4}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : ${2} gVCF Files Merged and Copied to Lustre" >> ${1}
##'-----------------------------------------------------------------------------------------#
