library('ggplot2')
source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67")
# source('init.R')

options(digits=3)

# CONST
path_TMA5 = "C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67/data/2016_03_24 TMA5.txt"

DT <- data.frame(read.table(path_TMA5, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", "")))


print(str(DT))






# sinks
# pdf("./sink/PITPNC1.pdf")
# sink("./sink/PITPNC1.txt")
# sink()      # redirect results to console
