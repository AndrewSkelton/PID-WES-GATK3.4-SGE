foo <- read_tsv("/Volumes/andrew/2016Jun_WES_Karin/Recalibrated_Callset/out.relatedness2") %>% as.data.frame
ped <- read_tsv("/Volumes/andrew/2016Jun_WES_Karin/pedigree/Samples.ped", col_names = F) %>% as.data.frame

Output_Table <- c()
for(i in unique(ped$X1)) {
  FAM_in <- i
  ped_in <- ped %>% filter(X1 == FAM_in)
  foo_in <- foo %>% filter(INDV1 %in% ped_in$X2)
  
  foo_r  <- foo %>% filter(INDV1 %in% ped_in$X2, INDV2 %in% ped_in$X2)
  foo_nr <- foo %>% filter(!(INDV1 %in% ped_in$X2), !(INDV2 %in% ped_in$X2))
  
  out <- c()
  for(j in 1:nrow(ped_in)) {
    sampl <- ped_in[j,2]
    temp1 <- foo_r %>% filter(INDV1 == sampl, INDV2 == sampl)
    self  <- ifelse(temp1$RELATEDNESS_AJK > 0.95,"Sample OK Within Itself","Possible Sample Problem")
    out   <- bind_rows(out,
                       data.frame(FAM_ID = FAM_in, 
                                  Indv1  = temp1$INDV1, Indv2 = temp1$INDV2, 
                                  R_AJK  = temp1$RELATEDNESS_AJK, 
                                  Call   = self,
                                  Relationship = "Self"))
    temp2 <- foo_r %>% filter(INDV1 == sampl, INDV2 != sampl)
    if(nrow(temp2) > 0) {
      for(k in 1:nrow(temp2)) {
        self   <- ifelse(temp2[k,]$RELATEDNESS_AJK > 0.2,"Samples Likely Related","Samples Likely Unrelated")
        subped <- ped %>% filter(X2 == temp2[k,]$INDV1 | X2 == temp2[k,]$INDV2)
       
        if((subped$X3[1] == subped$X3[2]) & subped$X3[1] != 0) {
          rela <- "Siblings"
        }else if((subped$X4[1] == subped$X4[2]) & subped$X4[1] != 0) {
          rela <- "Siblings"
        }else if(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4){
          rela <- "Parent-Parent"
        }else if(subped$X3 %>% table %>% .[["0"]] == 1){
          rela <- "Parent-Child"
        }else if(subped$X4 %>% table %>% .[["0"]] == 1){
          rela <- "Parent-Child"
        }else {
          rela <- "Other"
        }

        # ifelse(subped$X3 %>% table %>% .[["0"]] == 1, "Parent-Child","Other")
        # ifelse(subped$X4 %>% table %>% .[["0"]] == 1, "Parent-Child","Other")
        # ifelse(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4, "Parent-Parent","Other")
        # ifelse(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4, "Parent-Parent","Other")
        out    <- bind_rows(out,
                            data.frame(FAM_ID = FAM_in, 
                                       Indv1  = temp2[k,]$INDV1, Indv2 = temp2[k,]$INDV2, 
                                       R_AJK  = temp2[k,]$RELATEDNESS_AJK, 
                                       Call   = self,
                                       Relationship = rela))
      }
    }
  }
  Output_Table <- bind_rows(Output_Table,out)
  message(i)
}

wb          <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Sample-Sample_Checks")
OT_1 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Self")
openxlsx::writeData(wb, "Sample-Sample_Checks", OT_1)

openxlsx::addWorksheet(wb, "Parent-Parent")
OT_2 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Parent-Parent")
openxlsx::writeData(wb, "Parent-Parent", OT_2)

openxlsx::addWorksheet(wb, "Siblings")
OT_3 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Siblings")
openxlsx::writeData(wb, "Siblings", OT_3)

openxlsx::addWorksheet(wb, "Parent-Child")
OT_4 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Parent-Child")
openxlsx::writeData(wb, "Parent-Child", OT_4)

openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/Preprocessing/Relatedness.xlsx", overwrite = T)








foo <- read_tsv("/Volumes/andrew/2016Jun_WES_Karin/Recalibrated_Callset/out.relatedness2") %>% as.data.frame
ped <- read_tsv("/Volumes/andrew/2016Jun_WES_Karin/pedigree/Samples.ped", col_names = F) %>% as.data.frame

Output_Table <- c()
for(i in unique(ped$X1)) {
  FAM_in <- i
  ped_in <- ped %>% filter(X1 == FAM_in)
  foo_in <- foo %>% filter(INDV1 %in% ped_in$X2)
  
  foo_r  <- foo %>% filter(INDV1 %in% ped_in$X2, INDV2 %in% ped_in$X2)
  foo_nr <- foo %>% filter(!(INDV1 %in% ped_in$X2), !(INDV2 %in% ped_in$X2))
  
  out <- c()
  for(j in 1:nrow(ped_in)) {
    sampl <- ped_in[j,2]
    temp1 <- foo_r %>% filter(INDV1 == sampl, INDV2 == sampl)
    self  <- ifelse(temp1$RELATEDNESS_PHI > 0.95,"Sample OK Within Itself","Possible Sample Problem")
    out   <- bind_rows(out,
                       data.frame(FAM_ID = FAM_in, 
                                  Indv1  = temp1$INDV1, Indv2 = temp1$INDV2, 
                                  R_AJK  = temp1$RELATEDNESS_PHI, 
                                  Call   = self,
                                  Relationship = "Self"))
    temp2 <- foo_r %>% filter(INDV1 == sampl, INDV2 != sampl)
    if(nrow(temp2) > 0) {
      for(k in 1:nrow(temp2)) {
        self   <- ifelse(temp2[k,]$RELATEDNESS_PHI > 0.2,"Samples Likely Related","Samples Likely Unrelated")
        subped <- ped %>% filter(X2 == temp2[k,]$INDV1 | X2 == temp2[k,]$INDV2)
        
        if((subped$X3[1] == subped$X3[2]) & subped$X3[1] != 0) {
          rela <- "Siblings"
        }else if((subped$X4[1] == subped$X4[2]) & subped$X4[1] != 0) {
          rela <- "Siblings"
        }else if(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4){
          rela <- "Parent-Parent"
        }else if(subped$X3 %>% table %>% .[["0"]] == 1){
          rela <- "Parent-Child"
        }else if(subped$X4 %>% table %>% .[["0"]] == 1){
          rela <- "Parent-Child"
        }else {
          rela <- "Other"
        }
        
        # ifelse(subped$X3 %>% table %>% .[["0"]] == 1, "Parent-Child","Other")
        # ifelse(subped$X4 %>% table %>% .[["0"]] == 1, "Parent-Child","Other")
        # ifelse(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4, "Parent-Parent","Other")
        # ifelse(c(subped$X3,subped$X4) %>% table %>% .[["0"]] == 4, "Parent-Parent","Other")
        out    <- bind_rows(out,
                            data.frame(FAM_ID = FAM_in, 
                                       Indv1  = temp2[k,]$INDV1, Indv2 = temp2[k,]$INDV2, 
                                       R_AJK  = temp2[k,]$RELATEDNESS_PHI, 
                                       Call   = self,
                                       Relationship = rela))
      }
    }
  }
  Output_Table <- bind_rows(Output_Table,out)
  message(i)
}
# wb          <- openxlsx::createWorkbook()
# openxlsx::addWorksheet(wb, "Sample-Sample_Checks")
OT_1 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Self")
# openxlsx::writeData(wb, "Sample-Sample_Checks", OT_1)

# openxlsx::addWorksheet(wb, "Parent-Parent")
OT_2 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Parent-Parent")
# openxlsx::writeData(wb, "Parent-Parent", OT_2)

# openxlsx::addWorksheet(wb, "Siblings")
OT_3 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Siblings")
# openxlsx::writeData(wb, "Siblings", OT_3)

# openxlsx::addWorksheet(wb, "Parent-Child")
OT_4 <- Output_Table %>% as.data.frame %>% filter(Relationship == "Parent-Child")
# openxlsx::writeData(wb, "Parent-Child", OT_4)

# openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/Preprocessing/Relatedness.xlsx", overwrite = T)
