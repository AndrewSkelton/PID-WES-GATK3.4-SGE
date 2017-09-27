#!/bin/bash
#$ -cwd -V
#$ -pe smp 1
#$ -l h_vmem=10G
#$ -e ~/log
#$ -o ~/log

source ~/.bash_profile

module add apps/gatk/3.4-protected

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Job Submission Script - SelectVariants for Indels                          |
#-------------------------------------------------------------------------------------------#

# $1 - Bundle Path
# $2 - Sample ID
# $3 - PWD

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'Copying Reference Files to Node Local Scratch Space' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Copy Files to Node's Local Scratch
##'-----------------------------------------------------------------------------------------#
cp $3/'GATK_Pipeline'/$2'_Recal_indels.vcf'* $TMPDIR
cp $1/"ucsc.hg19.dict" $TMPDIR
cp $1/"ucsc.hg19.fasta.fai" $TMPDIR
cp $1/"ucsc.hg19.fasta" $TMPDIR
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo '' >> $3/$2'.log'
echo 'GATK Started - SelectVariants (Indels): '$(date) >> $3/$2'.log'
echo 'Parameters:' >> $3/$2'.log'
echo 'Reference Fa: ucsc.hg19.fasta' >> $3/$2'.log'
echo 'VCF In: '$2'_Recal_indels.vcf' >> $3/$2'.log'
echo 'Running SelectVariants (Indels)' >> $3/$2'.log'

echo 'Files on Scratch:' >> $3/$2'.log'
echo `ls $TMPDIR` >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#

##'Run GATK: Haplotype Caller - SelectVariants Indels
##'-----------------------------------------------------------------------------------------#
java -Xmx4g -jar \
    $GATK_ROOT/GenomeAnalysisTK.jar \
      -T SelectVariants \
      -R $TMPDIR/"ucsc.hg19.fasta" \
      --downsampling_type NONE \
      --variant $TMPDIR/$2'_Recal_indels.vcf' \
      --out $TMPDIR/$2'_Indels_selected.vcf' \
      -selectType INDEL \
      -select "vc.isNotFiltered()"

mv $TMPDIR/$2'_Indels_selected.vcf'* $3/'GATK_Pipeline'
mv $3/'GATK_Pipeline'/$2'_Recal_indels.vcf'* $3/'GATK_Pipeline/VCF_Backups'
##'-----------------------------------------------------------------------------------------#

##'Add to Log
##'-----------------------------------------------------------------------------------------#
echo 'GATK Finished: '$(date) >> $3/$2'.log'
echo 'Files Written to WORKING_DATA' >> $3/$2'.log'
##'-----------------------------------------------------------------------------------------#
