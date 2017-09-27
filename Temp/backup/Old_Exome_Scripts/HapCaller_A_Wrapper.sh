#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=42G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - Haplotype Caller in none gVCF mode                 |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD
# $4 - Capture Kit Bed File
# $5 - DB SNP

##'Create Directory
##'-----------------------------------------------------------------------------------------#
# mkdir $5'/Local_Realignment/'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/'GATK_Pipeline/Clean_Alignment'/$2'_post_recal.'* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
cp $4* $TMPDIR
cp $5* $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Basename of files on scratch
##'-----------------------------------------------------------------------------------------#
CAP_KIT=$(basename "$4")
DBSNP=$(basename "$5")
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started: '$(date) >> $3/$2'.log'
echo 'Parameters:' >> $3/$2'.log'
echo 'Known: '$DBSNP >> $3/$2'.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $3/$2'.log'
echo 'Capture Kit bed: '$CAP_KIT >> $3/$2'.log'
echo 'Alignment: '$2'_post_recal.bam' >> $3/$2'.log'
echo 'Running Haplotype Caller (none gCVF)' >> $3/$2'.log'

echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller
##'-----------------------------------------------------------------------------------------#
java -Xmx35g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
        -T HaplotypeCaller \
        -nct 1 \
        -R $TMPDIR/"ucsc.hg19.fasta" \
        -I $TMPDIR/$2'_post_recal.bam' \
        -L $TMPDIR/$CAP_KIT \
        --interval_padding 100 \
        --dbsnp $TMPDIR/$DBSNP \
        --max_alternate_alleles 50 \
        --pcr_indel_model CONSERVATIVE \
        -o $TMPDIR/$2'.vcf'

#--genotyping_mode DISCOVERY \
mv $TMPDIR/$2'.vcf'* $3/'GATK_Pipeline'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'VCF Written to WORKING_DATA' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#
