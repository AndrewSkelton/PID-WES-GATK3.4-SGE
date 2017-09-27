

#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : R                                                                          |
#  Study       : Exome Project                                                              |
#  Description : Module to validate pedigree File                                           |
#-------------------------------------------------------------------------------------------#


##'Load libraries
##'-----------------------------------------------------------------------------------------#
library(tidyverse)
library(kinship2)
##'-----------------------------------------------------------------------------------------#


##'Get All Pedigree Records
##'-----------------------------------------------------------------------------------------#
out.dir        <- "/home/nas151/WORKING_DATA/DNA_Sequencing/Bridge/Genotyping/Pedigree/"
ped.in         <- read_tsv("/home/nas151/WORKING_DATA/DNA_Sequencing/Scripts/Ref/Pedigrees_in.txt")
gvcf.in        <- list.files("/home/nas151/WORKING_DATA/DNA_Sequencing/Bridge/gVCF/", recursive = T, full.names = T, pattern = ".gz")
names(gvcf.in) <- basename(gvcf.in) %>% gsub(".g.vcf.gz","",.)
##'-----------------------------------------------------------------------------------------#


##'Validate Singletons
##'-----------------------------------------------------------------------------------------#
singlton.subset.out <- ped.in %>%
                       filter(grepl("SGL", Pipeline_ID)) %>%
                       filter(Sample_ID %in% names(gvcf.in))
singlton.subset.err <- ped.in %>%
                       filter(grepl("SGL", Pipeline_ID)) %>%
                       filter(!(Sample_ID %in% names(gvcf.in)))
# singlton.subset.out; singlton.subset.err
##'-----------------------------------------------------------------------------------------#


##'Validate Families
##'-----------------------------------------------------------------------------------------#
family.subset.in    <- ped.in %>%
                       filter(grepl("FAM", Pipeline_ID)) %>%
                       filter(Sample_ID %in% names(gvcf.in))
family.subset.err   <- ped.in %>%
                       filter(grepl("FAM", Pipeline_ID)) %>%
                       filter(!(Sample_ID %in% names(gvcf.in)))

family.subset.out   <- family.subset.in
for(i in 1:nrow(family.subset.out)) {
  if(family.subset.out[i,]$Paternal_ID != 0) {
    if(!family.subset.out[i,]$Paternal_ID %in% family.subset.out$Sample_ID) {
      family.subset.out[i,]$Paternal_ID <- 0
      message(paste0(family.subset.out[i,]$Pipeline_ID, " Missing Paternal Sample, set to 0"))
    }
  }
  if(family.subset.out[i,]$Maternal_ID != 0) {
    if(!family.subset.out[i,]$Maternal_ID %in% family.subset.out$Sample_ID) {
      family.subset.out[i,]$Maternal_ID <- 0
      message(paste0(family.subset.out[i,]$Pipeline_ID, " Missing Maternal Sample, set to 0"))
    }
  }
}

singletons.by.missing <- family.subset.out$Pipeline_ID %>% table %>% .[.==1] %>% names
extra.singletons      <- family.subset.out %>% filter(Pipeline_ID %in% singletons.by.missing)
family.subset.out     <- family.subset.out %>% filter(!(Pipeline_ID %in% singletons.by.missing))
# family.subset.in; family.subset.err; family.subset.out
##'-----------------------------------------------------------------------------------------#


##'Recode Orphans
##'-----------------------------------------------------------------------------------------#
sgl.marker <- singlton.subset.out$Pipeline_ID %>% gsub("^.*?SGL","",.) %>% as.numeric %>% max
for(i in 1:nrow(extra.singletons)) {
  extra.singletons$Pipeline_ID[i] <- paste0("SGLFIX", (sgl.marker + 1))
  sgl.marker <- (sgl.marker + 1)
}
# extra.singletons
##'-----------------------------------------------------------------------------------------#


##'Compile Final Output
##'-----------------------------------------------------------------------------------------#
pedigrees.out <- extra.singletons %>%
                 dplyr::select(1,2,3,4,5,6) %>%
                 bind_rows({
                   singlton.subset.out %>%
                   dplyr::select(1,2,3,4,5,6)
                 }) %>%
                 bind_rows({
                   family.subset.out %>%
                   dplyr::select(1,2,3,4,5,6)
                 }) %>%
                 mutate(Gender = ifelse(Gender == "M", 1, Gender),
                        Gender = ifelse(Gender == "F", 2, Gender))
# pedigrees.out

pedigrees.err <- pedigrees.out %>% filter(!grepl("^1$|^2$", Gender))
if(nrow(pedigrees.err) != 0) {
  message(paste0("WARNING: ", nrow(pedigrees.err)," Unexpected Sex Value(s)"))
  write_tsv(pedigrees.err, path = paste0(out.dir, "gender_code.err"), col_names = F)
}
##'-----------------------------------------------------------------------------------------#


##'Write Output Files
##'-----------------------------------------------------------------------------------------#
write_tsv(pedigrees.out,       path = paste0(out.dir, "master.ped"), col_names = F)
write_tsv(extra.singletons,    path = paste0(out.dir, "recoded.singletons.ped"))
write_tsv(family.subset.out,   path = paste0(out.dir, "family.subset.ped"))
write_tsv(singlton.subset.out, path = paste0(out.dir, "singleton.subset.ped"))
write_tsv(singlton.subset.err, path = paste0(out.dir, "singletons.err.ped"))
write_tsv(family.subset.err,   path = paste0(out.dir, "families.err.ped"))
##'-----------------------------------------------------------------------------------------#
