#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : R Statistical Programming Language                                         |
#  Study       : WES PID                                                                    |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Check expected relatedness between samples, against a relatedness          |
#                coefficient. Statistic is ~1 for a sample compared to itself.              |
#-------------------------------------------------------------------------------------------#



##'Set the Working Directory, load essential packages
##'-----------------------------------------------------------------------------------------#
library(dplyr)
library(readr)
library(openxlsx)

foo <- read_tsv("/Volumes/andrew/Temp/Raw_Callset/out.relatedness2") %>% as.data.frame %>% mutate(MAP = paste0(INDV1,"_",INDV2))
ped <- read_tsv("/Volumes/WORKING_DATA/Exome_Project/Scripts/Ref/Samples.ped", col_names = F) %>% as.data.frame

OutTru <- c()
OutErr <- c()
##'-----------------------------------------------------------------------------------------#



##'Search for expected vs unexpected relatedness
##'-----------------------------------------------------------------------------------------#
for(i in unique(ped$X1)) {
  FAM_in <- i
  ped_in <- ped %>% filter(X1 == FAM_in)
  expRel <- c(ped_in$X2,ped_in$X3,ped_in$X4) %>% unique %>% .[. != "0"]
  foo_in <- foo %>% filter(INDV1 %in% expRel | INDV2 %in% expRel)
  actRel <- foo_in %>% 
            filter(RELATEDNESS_PHI > 0.05) %>% 
            filter(INDV1 != INDV2)
  errRel <- actRel %>% 
            filter(!(INDV1 %in% expRel) | !(INDV2 %in% expRel))
  truRel <- actRel %>% 
            filter(INDV1 %in% expRel, INDV2 %in% expRel)
  if(nrow(errRel) > 0) {
    for(j in 1:nrow(errRel)) {
      message(paste0("Unexpected Relatedness: ",
                     errRel[j,1], " to ", errRel[j,2],
                     " - ", FAM_in, " - ", errRel[j,7]))
      tmp    <- data.frame(A = errRel[j,1], B = errRel[j,2], MAP = paste0(errRel[j,1],"_",errRel[j,2]),
                           Coef = errRel[j,7], FamID = i)
      OutErr <- rbind(OutErr, tmp) 
    }
  }
  if(nrow(truRel) > 0) {
    for(j in 1:nrow(truRel)) {
      message(paste0("Expected Relatedness: ",
                     truRel[j,1], " to ", truRel[j,2],
                     " - ", FAM_in, " - ", truRel[j,7]))
      tmp    <- data.frame(A = truRel[j,1], B = truRel[j,2], MAP = paste0(truRel[j,1],"_",truRel[j,2]),
                           Coef = truRel[j,7], FamID = i)
      OutTru <- rbind(OutTru, tmp)
    }
  }
}
# OutTru <- OutTru %>% distinct(MAP, .keep_all = T)
# OutErr <- OutErr %>% distinct(MAP, .keep_all = T)

temp        <- foo
tru.sort    <- t(apply(OutTru[,c(1:2)], 1, sort)) %>% as.data.frame %>% unique %>% rownames
OutTru      <- OutTru[tru.sort,]
err.sort    <- t(apply(OutErr[,c(1:2)], 1, sort)) %>% as.data.frame %>% unique %>% rownames
OutErr      <- OutErr[err.sort,]


message(paste0("Expected Results: ", nrow(OutTru)))
message(paste0("Unexpected Results: ", nrow(OutErr)))

OutErr <- OutErr %>% mutate(PercRel = paste0((Coef * 100 * 2) %>% round(2), "%"))
##'-----------------------------------------------------------------------------------------#


##'Output Results
##'-----------------------------------------------------------------------------------------#
wb          <- openxlsx::createWorkbook()

openxlsx::addWorksheet(wb, "Pedigree_File")
openxlsx::writeData(wb, "Pedigree_File", ped)

openxlsx::addWorksheet(wb, "ExpectedRelatedness")
openxlsx::writeData(wb, "ExpectedRelatedness", OutTru)

openxlsx::addWorksheet(wb, "UnxpectedRelatedness")
openxlsx::writeData(wb, "UnxpectedRelatedness", OutErr)

openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/QC/Relatedness.xlsx", overwrite = T)
##'-----------------------------------------------------------------------------------------#


##'PED Quick Look
##'-----------------------------------------------------------------------------------------#
FAM = "FAM14"
i   = FAM
ped %>% filter(X1 == FAM)
##'-----------------------------------------------------------------------------------------#


##'Jon Query
##'-----------------------------------------------------------------------------------------#
Samples_In  <- c("PID11711", "PID3337", "GNB120815", "D24207", "GNB051015", "NG001", "NG002",
                 "NG003", "NG004")
ped_sub     <- ped %>% filter(X2 %in% Samples_In |
                              X3 %in% Samples_In |
                              X4 %in% Samples_In)
colnames(ped_sub) <- c("FAM_ID", "SAM_ID", "PAT_ID", "MAT_ID", "Sex", "Affected")
expRel      <- c(ped_sub$SAM_ID,ped_sub$PAT_ID,ped_sub$MAT_ID) %>% unique %>% .[. != "0"]
foo_tmp     <- foo %>% filter(INDV1 %in% expRel | INDV2 %in% expRel)
foo_out     <- foo_tmp %>% 
               filter(RELATEDNESS_PHI > 0.05) %>% 
               filter(INDV1 != INDV2)
foo_tmp     <- foo %>% filter(INDV1 %in% expRel, INDV2 %in% expRel)
foo_unr     <- foo_tmp %>% 
               filter(RELATEDNESS_PHI <= 0.05) %>% 
               filter(INDV1 != INDV2)

fos_exp     <- OutTru %>% 
               filter(A %in% expRel | B %in% expRel)
fos_une     <- OutErr %>% 
               filter(A %in% expRel | B %in% expRel)

wb          <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Pedigree_File")
openxlsx::writeData(wb, "Pedigree_File", ped_sub)
openxlsx::addWorksheet(wb, "ExpectedRelatedness")
openxlsx::writeData(wb, "ExpectedRelatedness", fos_exp)
openxlsx::addWorksheet(wb, "UnexpectedRelatedness")
openxlsx::writeData(wb, "UnexpectedRelatedness", fos_une)
openxlsx::addWorksheet(wb, "Relatedness")
openxlsx::writeData(wb, "Relatedness", foo_out)
openxlsx::addWorksheet(wb, "Unrelated")
openxlsx::writeData(wb, "Unrelated", foo_unr)
openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/QC/Jon2.xlsx", overwrite = T)
##'-----------------------------------------------------------------------------------------#


