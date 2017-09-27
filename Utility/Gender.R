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

setwd("~/Temp/Gender_Bam/")
##'-----------------------------------------------------------------------------------------#



##'Set the Working Directory, load essential packages
##'-----------------------------------------------------------------------------------------#
files_x  <- list.files("./Out/", 
                       pattern    = "*ChrX.h.cov", 
                       full.names = T)
names_x  <- sapply(files_x, function(x){strsplit(basename(x),"_")[[1]][1]})
files_y  <- list.files("./Out/", 
                       pattern    = "*ChrY.h.cov", 
                       full.names = T)
names_y  <- sapply(files_y, function(x){strsplit(basename(x),"_")[[1]][1]})

coverage <- c()
for(i in 1:length(files_x)){
  foo      <- read_tsv(files_x[i], col_names = F) %>% 
              as.data.frame %>% 
              mutate(X9 = 1:nrow(.), Sample = names_x[i])
  coverage <- rbind(coverage, foo %>% na.omit)
}
for(i in 1:length(files_y)){
  foo      <- read_tsv(files_y[i], col_names = F) %>% 
              as.data.frame %>% 
              mutate(X9 = 1:nrow(.), Sample = names_y[i])
  coverage <- rbind(coverage, foo %>% na.omit)
}
coverage <- coverage %>% dplyr::filter(X1 == "chrX" | X1 == "chrY")
##'-----------------------------------------------------------------------------------------#



##'Plot Coverage
##'-----------------------------------------------------------------------------------------#
ggplot(coverage, aes(x = X9,
                     y = X5)) + 
  geom_line() +
  theme_bw() + 
  facet_grid(Sample~X1, scales = "free_x") + 
  ylab("Depth of Coverage") +
  xlab("Index")
##'-----------------------------------------------------------------------------------------#

# 1) depth
# 2) # bases at depth
# 3) size of A
# 4) % of A at depth
















