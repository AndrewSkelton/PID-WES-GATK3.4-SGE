#!/bin/bash

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : Bash                                                                       |
#  Study       : Exome Project                                                              |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : VEP                                                                        |
#-------------------------------------------------------------------------------------------#

##'Add Modules
##'-----------------------------------------------------------------------------------------#
module add apps/perl/5.18.2
module add apps/samtools
module add apps/VEP/v83
##'-----------------------------------------------------------------------------------------#


variant_effect_predictor.pl -i ./Filtered_Callset.vcf \
                            -o ./Filtered_Callset.vep \
                            --sift p \
                            --fork 4 \
                            --cache \
                            --port 3337 \
                            --dir_cache /opt/databases/ensembl-tools/ensembl-tools-83/VEP/ \
                            --dir_plugins /opt/databases/ensembl-tools/ensembl-tools-83/VEP/ \
                            --individual all \
                            --gene_phenotype \
                            --variant_class \
                            --symbol \
                            --appris \
                            --canonical \
                            --biotype \
                            --terms ensembl \
                            --fields Uploaded_variation,Location,SYMBOL,ZYG,VARIANT_CLASS,Allele,FREQS,SIFT,CLIN_SIG,SOMATIC,BIOTYPE,Consequence,Gene,Feature,Feature_type,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation \
                            --force_overwrite

# --pedigree ./B4P10_Family/B4P10.ped \

# variant_effect_predictor.pl -i DEC15746352_Indels_selected.vcf \
#                             -o Indel_Out.vep \
#                             --sift p \
#                             --fork 4 \
#                             --cache \
#                             --port 3337 \
#                             --dir_cache /opt/databases/ensembl-tools/ensembl-tools-83/VEP/ \
#                             --dir_plugins /opt/databases/ensembl-tools/ensembl-tools-83/VEP/ \
#                             --individual all \
#                             --gene_phenotype \
#                             --variant_class \
#                             --symbol \
#                             --appris \
#                             --canonical \
#                             --biotype \
#                             --terms ensembl \
#                             --fields Uploaded_variation,Location,SYMBOL,ZYG,VARIANT_CLASS,Allele,FREQS,SIFT,BIOTYPE,Consequence,Gene,Feature,Feature_type,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation \
#                             --force_overwrite

# SYMBOL,IMPACT,VARIANT_CLASS,SIFT,BIOTYPE,CANONICAL,GENE_PHENO,ZYG,PHENO,Uploaded_variation,Location,Allele,Gene,Feature,Feature_type,Consequence,cDNA_position,CDS_position,Protein_position,Amino_acids,Codons,Existing_variation,Extra



# filter_vep.pl -i SNP_test2.txt -filter "SIFT is deleterious" > SNP_test2_SIFT_Deleterious.txt
