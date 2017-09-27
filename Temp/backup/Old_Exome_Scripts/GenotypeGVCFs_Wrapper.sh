#!/bin/bash
#$ -cwd -V
#$ -pe smp 10
#$ -l h_vmem=92G
#$ -e ~/log
#$ -o ~/log
source ~/.bash_profile

module add apps/gatk/3.4-protected
# GATK_ROOT='/opt/software/bsu/bin/GenomeAnalysisTK-3.4-46.jar'

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Runner Script for GenotypeGVCFs on FMS Cluster                             |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - PWD

##'Copy Files to Scratch
##'-----------------------------------------------------------------------------------------#
cp `find $2 -type f -name "*.g.vcf"` $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Get Sample Name
##'-----------------------------------------------------------------------------------------#
GVCFS=`find $TMPDIR -type f -name "*.g.vcf" | sed 's/^/--variant /' -`
##'-----------------------------------------------------------------------------------------#

##'Create Log
##'-----------------------------------------------------------------------------------------#
echo 'GVCF Files: ' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo $GVCFS >> $2/'GATK_GVCF/GATK_GVCF.log'
echo '' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'GATK Started: '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Running GenotypeGVCFs' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo 'Files on Scratch:' >> $2/'GATK_GVCF/GATK_GVCF.log'
echo `ls $TMPDIR` >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK to Genotype all gVCF Files
##'-----------------------------------------------------------------------------------------#
java -Xmx80g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T GenotypeGVCFs \
        -nt 10 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        --max_alternate_alleles 50 \
        --disable_auto_index_creation_and_locking_when_reading_rods \
        $GVCFS \
        -o $TMPDIR/'GVCF_Genotyped.vcf'

mv $TMPDIR/'GVCF_Genotyped.vcf'* $2/'GATK_GVCF'


# $GATK_ROOT \
#--disable_auto_index_creation_and_locking_when_reading_rods \
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $2/'GATK_GVCF/GATK_GVCF.log'
##'-----------------------------------------------------------------------------------------#
