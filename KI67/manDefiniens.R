rm(list = ls())
library('ggplot2')
library('data.table')
library('MethComp')
library('BlandAltmanLeh')
library('BSDA')
source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67")
# source('init.R')

# sinks
pdf("./sink/TMA_manualVSdefiniens.pdf")
sink("./sink/TMA_manualVSdefiniens.txt")

options(digits=3)

# manual scoring block #1-6
Manual_Scoring_path = file.path(getwd(), 'data', 'WILLA MANUAL.txt')
ManScoringDT <- data.table(read.table(Manual_Scoring_path, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))
# definiens block #5
D_TMA5_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA5 DEFINIENS.txt')
D_TMA5_DT= loading(D_TMA5_path)

TMA_list <- list(tma5=D_TMA5_DT)




lapply(TMA_list, generateStatistics, manual_DT=ManScoringDT)



dev.off()
