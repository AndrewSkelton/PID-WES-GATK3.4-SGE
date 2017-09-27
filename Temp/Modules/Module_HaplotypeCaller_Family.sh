#!/bin/bash
#$ -cwd -V
#$ -pe smp 5
#$ -l h_vmem=25G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile
module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Type        : Cluster Script                                                             |
#  Description : Run the Haplotype Caller on samples with pedigree                          |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Family ID                                                                  |
#  Input 3     : Array of Sample root Preprocessing directories                             |
#  Input 4     : Capture Kit                                                                |
#  Input 5     : DBSNP Reference                                                            |
#  Input 6     : Ped File                                                                   |
#  Input 7     : Family Analysis Output Directory                                           |
#  Resources   : Memory     - 25GB                                                          |
#  Resources   : Processors - 5                                                             |
#-------------------------------------------------------------------------------------------#



##'Create Folder Structure and output File
##'-----------------------------------------------------------------------------------------#
mkdir -p ${7}/GATK
##'-----------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
echo "Copying Samples to Scratch"
while read i
do
   echo "Sample: ${i}"
   cp ${i}/Alignment/Clean/* ${TMPDIR}
done < ${3}

cp ${1}/"ucsc.hg19.dict" ${TMPDIR}
cp ${1}/"ucsc.hg19.fasta.fai" ${TMPDIR}
cp ${1}/"ucsc.hg19.fasta" ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${5} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "${4}")
DBSNP=$(basename "${5}")
PED=$(basename "${6}")
BAM_IN=`find ${TMPDIR} -type f -name "*bam" | sed 's/^/-I /' -`
echo ${BAM_IN}
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx18g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T HaplotypeCaller \
        -nct 5 \
        -R ${TMPDIR}/"ucsc.hg19.fasta" \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding 100 \
        --dbsnp ${TMPDIR}/${DBSNP} \
        --max_alternate_alleles 50 \
        --pcr_indel_model CONSERVATIVE \
        -ped ${TMPDIR}/${PED} \
        ${BAM_IN} \
        -A QualByDepth \
        -A Coverage \
        -A VariantType \
        -A ClippingRankSumTest \
        -A DepthPerSampleHC \
        -o ${TMPDIR}/${2}'.vcf'

mv ${TMPDIR}/${2}'.vcf'* ${7}/GATK
##'-----------------------------------------------------------------------------------------#
