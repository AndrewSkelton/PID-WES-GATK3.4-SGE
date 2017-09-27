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
#  Input 2     : Output Directory                                                           |
#  Input 3     : gVCF Directory                                                             |
#  Input 4     : Pedigree File                                                              |
#  Input 5     : Log File                                                                   |
#  Input 6     : Capture Kit                                                                |
#  Input 7     : Padding                                                                    |
#  Resources   : Memory     - 50GB                                                          |
#  Resources   : Processors - 10                                                            |
#-------------------------------------------------------------------------------------------#


##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp ${1}/human_g1k_v37.* ${TMPDIR}
cp `find ${3} -type f -name "*.g.vcf.*"` ${TMPDIR}
cp ${4} ${TMPDIR}
cp ${6} ${TMPDIR}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Reference Files and gVCF files copied to scratch" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Decompress gVCF Files
##'-----------------------------------------------------------------------------------------#
for i in ${TMPDIR}/*.g.vcf.gz
do
  pigz -p 10 -d $i
done
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : gVCF Files decompressed" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
REF_FA="human_g1k_v37.fasta"
PED=$(basename "${4}")
GVCFS=`find ${TMPDIR} -type f -name "*.g.vcf" | sed 's/^/--variant /' -`
CAP_KIT=$(basename "${6}")
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Running Genotyping" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Run GATK: Joint Genotyping of gVCF Files
##'-----------------------------------------------------------------------------------------#
java -Xmx40g -jar \
    ${GATK_ROOT}/GenomeAnalysisTK.jar \
    -T GenotypeGVCFs \
        -L ${TMPDIR}/${CAP_KIT} \
        --interval_padding ${7} \
        -nt 10 \
        -ped ${TMPDIR}/${PED} \
        -R ${TMPDIR}/${REF_FA} \
        --max_alternate_alleles 50 \
        ${GVCFS} \
        -o ${TMPDIR}/Raw_Callset.vcf

# mv ${TMPDIR}/Raw_Callset.vcf* ${2}
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Genotyping Complete" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Compress Raw Call Set
##'-----------------------------------------------------------------------------------------#
pigz -p 10 ${TMPDIR}/Raw_Callset.vcf
##'-----------------------------------------------------------------------------------------#


##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo $(date)" : Callset compressed" >> ${5}
##'-----------------------------------------------------------------------------------------#


##'Move to Lustre
##'-----------------------------------------------------------------------------------------#
mv ${TMPDIR}/Raw_Callset.vcf* ${2}
##'-----------------------------------------------------------------------------------------#
