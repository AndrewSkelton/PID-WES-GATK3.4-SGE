#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=50G
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
#  Description : Run GATK to genotype all gVCF Files                                        |
#  Version     : 1.0                                                                        |
#  Input 1     : GATK Bundle Path                                                           |
#  Input 2     : Paths In                                                                   |
#  Input 3     : Output Directory                                                           |
#  Input 4     : Ped File                                                                   |
#  Input 5     : log                                                                        |
#  Input 6     : Merged Capture Kit                                                         |
#  Resources   : Memory     - 50GB                                                          |
#  Resources   : Processors - 10                                                            |
#-------------------------------------------------------------------------------------------#



##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${1}/ucsc.hg19.* ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#



##'Get gVCF Files
##'-----------------------------------------------------------------------------------------#
echo "Copying Samples to Scratch" >> ${5}
while read i
do
   echo "   Sample Started: ${i}" >> ${5}
   cp ${i}/GATK/*.g.vcf* ${TMPDIR}
   echo "   Sample Copied: ${i}" >> ${5}
done < ${2}
echo "Copying Complete" >> ${5}
##'-----------------------------------------------------------------------------------------#



##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
PED=$(basename "${4}")
GVCFS=`find ${TMPDIR} -type f -name "*.g.vcf" | sed 's/^/--variant /' -`
CAP_KIT=$(basename "${6}")
##'-----------------------------------------------------------------------------------------#



##'Run GATK: Joint Genotyping of gVCF Files
##'-----------------------------------------------------------------------------------------#
echo "Running GATK: $(date)" >> ${5}
java -Xmx42g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
    -T GenotypeGVCFs \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding 75 \
        -nt 10 \
        -ped ${TMPDIR}/${PED} \
        -R ${TMPDIR}/ucsc.hg19.fasta \
        --max_alternate_alleles 50 \
        ${GVCFS} \
        -o ${TMPDIR}/Raw_Callset.vcf

echo "GATK Complete: $(date)" >> ${5}

mv ${TMPDIR}/Raw_Callset.vcf* ${3}
##'-----------------------------------------------------------------------------------------#
