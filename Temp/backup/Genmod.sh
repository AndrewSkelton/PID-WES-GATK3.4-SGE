#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Trio Analysis                                                              |
#-------------------------------------------------------------------------------------------#

##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/python27/2.7.8
##'-----------------------------------------------------------------------------------------#

##'Transform PED File
##'-----------------------------------------------------------------------------------------#
# mac2unix *.txt
# mv *.txt B4P11.ped
##'-----------------------------------------------------------------------------------------#

##'Make Directory Structure
##'-----------------------------------------------------------------------------------------#
mkdir ./B4P11_Family/genmod
cp ./B4P11_Family/B4P11_Family_Recal_SNPs.vcf ./B4P11_Family/genmod
##'-----------------------------------------------------------------------------------------#

##'Compress and Tabix Index
##'-----------------------------------------------------------------------------------------#
# for i in ./B4P11_Family/genmod/*.vcf
# do
#   bgzip $i
#   tabix -p vcf ${i}.gz
# done
##'-----------------------------------------------------------------------------------------#


##'Merge Files
##'-----------------------------------------------------------------------------------------#
# vcf-merge B4P11_DEC15D217287_SNPs_selected.vcf.gz MB4P11_DEC15D217078_Recal_SNPs.vcf.gz FB4P11_DEC15D217079_Recal_SNPs.vcf.gz > B4P11_Family.vcf
##'-----------------------------------------------------------------------------------------#

##'Annotate and Model
##'-----------------------------------------------------------------------------------------#
~/.local/bin/genmod annotate ./B4P11_Family/genmod/B4P11_Family_Recal_SNPs.vcf --annotate_regions > ./B4P11_Family/genmod/B4P11_Family_Recal_SNPs_genmodAnno.vcf
~/.local/bin/genmod models ./B4P11_Family/genmod/B4P11_Family_Recal_SNPs_genmodAnno.vcf -f ./B4P11_Family/B4P11_2.ped > ./B4P11_Family/genmod/B4P11_Family_Recal_SNPs_genmodAnno_model.vcf
##'-----------------------------------------------------------------------------------------#


##'Extract Proband
##'-----------------------------------------------------------------------------------------#
# cat B4P11_Family_Annotated_Models.vcf | vcf-subset -c DEC15D217287 > B4P11_out.vcf
##'-----------------------------------------------------------------------------------------#
