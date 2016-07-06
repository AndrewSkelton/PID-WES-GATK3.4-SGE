#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : R Statistical Programming Language                                         |
#  Study       :                                                       |
#  Data Owner  : Newcastle University -                                    |
#  Description :                              |
#-------------------------------------------------------------------------------------------#



##'Set the Working Directory, load essential packages
##'-----------------------------------------------------------------------------------------#
library(readr)
library(ggplot2)
library(dplyr)

setwd("/Volumes/WORKING_DATA/Exome_Project/")

ped_in       <- read_tsv("Scripts/Ref/SampleMap_.txt", col_names = T) %>% 
                as.data.frame %>% 
                mutate(Gender_Prediction = "")
##'-----------------------------------------------------------------------------------------#



##'Read in Coverage Files
##'-----------------------------------------------------------------------------------------#
coverage      <- c()
cov_files     <- list.files("Preprocessing/", 
                            pattern    = "*.cov",
                            full.names = T,
                            recursive  = T)
cov_names     <- sapply(cov_files, function(x){strsplit(basename(x),"_")[[1]][1]})
for(i in 1:length(cov_files)){
  if(file.size(cov_files[i]) > 0) {
    foo      <- read_tsv(cov_files[i], col_names = F) %>%
                as.data.frame %>%
                mutate(Sample = cov_names[i])
    coverage <- bind_rows(coverage, foo)
  } else {
    message(paste0("Empty File: ", cov_files[i]))
  }
}
##'-----------------------------------------------------------------------------------------#



##'Read in Coverage Files
##'-----------------------------------------------------------------------------------------#
coverage_in <- coverage %>% filter(Sample %in% cov_names[1:5])
ggplot(coverage_in, aes(x = X5, y = X6, group = Sample, colour = Sample)) +
         geom_line(size = 1) +
         theme_bw()
##'-----------------------------------------------------------------------------------------#



##'Check Samples
##'-----------------------------------------------------------------------------------------#
sample_error <- c()
error_out    <- c()
for(i in unique(coverage$Sample)){
  foo <- coverage %>% filter(Sample == i) %>% 
         left_join(ped_in, by = c("Sample" = "Sample_ID"))
  foo_known <- foo[["Gender"]][1]
  foo_Pred  <- ifelse(mean(foo$X6) > 5, "M", "F")
  # message(paste0(foo_known, " ", foo_Pred, " ", mean(foo$X6)))
  # message(i)
  if(foo_known != foo_Pred){
    message(paste0("Potential Sample Mismatch: ", i,
                   "\n  Logged as ", foo_known,
                   ", SRY coverage suggests ",
                   foo_Pred, "\n  Mean Cov: ", mean(foo$X6), "\n"))
    sample_error <- c(sample_error,i)
    error_out    <- bind_rows(error_out,
                              data.frame(SampleID = i,
                                         MeanSRY  = mean(foo$X6) %>% round(2),
                                         Logged_Gender = foo_known,
                                         Predicted_Gender = foo_Pred))
  }
}
##'-----------------------------------------------------------------------------------------#



##'Plot Errors
##'-----------------------------------------------------------------------------------------#
coverage_in <- coverage %>% 
               filter(Sample %in% sample_error) %>% 
               left_join(ped_in, by = c("Sample" = "Sample_ID"))
gg <- ggplot(coverage_in, aes(x = X5, y = X6, group = Sample, colour = Gender)) +
      geom_line(size = 1) +
      facet_grid(Sample ~ .) +
      xlab("Locus") +
      ylab("Depth") +
      theme_bw()
print(gg)
##'-----------------------------------------------------------------------------------------#



##'Compile Results
##'-----------------------------------------------------------------------------------------#
wb          <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Gender_Mismatches")
openxlsx::writeData(wb, "Gender_Mismatches", error_out)
openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/Preprocessing/GenderMismatch.xlsx", 
                       overwrite = T)

png("/Volumes/WORKING_DATA/Exome_Project/Preprocessing/GenderMismatch.png", 
    width=8, height=9, units="in", res=600) 
print(gg)
dev.off()
##'-----------------------------------------------------------------------------------------#






