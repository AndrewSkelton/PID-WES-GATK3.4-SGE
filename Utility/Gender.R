#-------------------------------------------------------------------------------------------#
#  Author      : Andrew J Skelton                                                           |
#  Language    : R Statistical Programming Language                                         |
#  Study       : WES PID                                                                    |
#  Data Owner  : Newcastle University - Prof. Sophie Hambleton                              |
#  Description : Validate Gender of samples, by assessing the coverage of the SRY Gene.     |
#                Using the Pedigree file, we can determine expected gender against known    |
#                gender to identify potential errors                                        |
#-------------------------------------------------------------------------------------------#



##'Set the Working Directory, load essential packages
##'-----------------------------------------------------------------------------------------#
library(readr)
library(ggplot2)
library(dplyr)

setwd("/Volumes/WORKING_DATA/Exome_Project/../David/Raw_Data/")

ped_in       <- read_tsv("Scripts/Ref/Samples.ped", col_names = F) %>% 
                as.data.frame %>% na.omit
low_lim = 2655000
hi_lim  = 2656000
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
# coverage_in <- coverage %>% filter(Sample %in% cov_names[1:5])
# ggplot(coverage_in, aes(x = X5, y = X6, group = Sample, colour = Sample)) +
#          geom_line(size = 1) +
#          theme_bw()
##'-----------------------------------------------------------------------------------------#



##'Check Samples
##'-----------------------------------------------------------------------------------------#
sample_error <- c()
error_out    <- c()
targets      <- unique(coverage$Sample) %>% .[. %in% ped_in$X2]
for(i in targets){
  foo <- coverage %>% filter(Sample == i, X5 > 1001, X5 < 2000) %>% 
         left_join(ped_in, by = c("Sample" = "X2"))
  foo_known <- ifelse(foo$X5.y[1] == "1" ,"M","F")
  foo_Pred  <- ifelse(mean(foo$X6.x) > 5, "M", "F")
  # message(paste0("Sample: ", i, " - ", foo_known, " ", foo_Pred, " ", mean(foo$X6.x)))

  if(foo_known != foo_Pred){
    message(paste0("Potential Sample Mismatch: ", i,
                   "\n  Logged as ", foo_known,
                   ", SRY coverage suggests ",
                   foo_Pred, "\n  Mean Cov: ", mean(foo$X6.x), "\n"))
    sample_error <- c(sample_error,i)
    error_out    <- bind_rows(error_out,
                              data.frame(SampleID = i,
                                         MeanSRY  = mean(foo$X6.x) %>% round(2),
                                         Logged_Gender = foo_known,
                                         Predicted_Gender = foo_Pred))
  }
}
##'-----------------------------------------------------------------------------------------#



##'Plot Errors
##'-----------------------------------------------------------------------------------------#
coverage_in <- coverage %>% 
               filter(Sample %in% sample_error) %>% 
               left_join(ped_in, by = c("Sample" = "X2")) %>% 
               mutate(Gender = ifelse(X5.y == "1" ,"M","F"))
gg <- ggplot(coverage_in, aes(x = X5.x, y = X6.x, group = Sample, colour = Gender)) +
      geom_line(size = 1) +
      facet_grid(Sample ~ .) +
      xlab("Locus") +
      ylab("Depth") +
      theme_bw() + 
      guides(colour = guide_legend(title = "Known Gender")) +
      ggtitle("Gender Mismatches")
print(gg)
##'-----------------------------------------------------------------------------------------#



##'Compile Results
##'-----------------------------------------------------------------------------------------#
wb          <- openxlsx::createWorkbook()
openxlsx::addWorksheet(wb, "Gender_Mismatches")
openxlsx::writeData(wb, "Gender_Mismatches", error_out)
openxlsx::saveWorkbook(wb, "/Volumes/WORKING_DATA/Exome_Project/QC/GenderMismatch.xlsx", 
                       overwrite = T)

png("/Volumes/WORKING_DATA/Exome_Project/QC/GenderMismatch.png", 
    width=8, height=9, units="in", res=600) 
print(gg)
dev.off()
##'-----------------------------------------------------------------------------------------#



A   <- 1
B   <- 8
mA  <- mean(A)
mB  <- mean(B)
lA  <- log2(A)
lB  <- log2(B)
mlA <- mean(lA)
mlB <- mean(lB)

# Should be the same
mB / mA
(mlB - mlA) %>% 2^.

# Should be the same
(mA / mB) %>% log2
mlA - mlB




