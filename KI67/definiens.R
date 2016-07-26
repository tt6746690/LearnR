# rm(list = ls())
# library('ggplot2')
# library('data.table')
# library('MethComp')
# library('BlandAltmanLeh')
# library('BSDA')
# source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67")
# source('init.R')

# sinks
# pdf("./sink/TMA_manualVSdefiniens.pdf")
# sink("./sink/TMA_manualVSdefiniens.txt")

options(digits=3)

# manual scoring block #1-6
Manual_Scoring_path = file.path(getwd(), 'data', 'WILLA MANUAL.txt')
ManScoringDT <- data.table(read.table(Manual_Scoring_path, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))[,category := 'manual']


# D_TMA1_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA1 DEFINIENS.txt')
# D_TMA1_DT = loading(D_TMA1_path)[,category := 'definiens']

D_TMA1b_path = file.path(getwd(), 'data', 'definiens', 'TMA1 DEFINIENS RUN 2.txt')
D_TMA1b_DT = loading(D_TMA1b_path)[,block := 'willa_definiens_1']

D_TMA2_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA2 DEFINIENS.txt')
D_TMA2_DT= loading(D_TMA2_path)[,block := 'willa_definiens_2']

D_TMA3_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA3 DEFINIENS.txt')
D_TMA3_DT= loading(D_TMA3_path)[,block := 'willa_definiens_3']

D_TMA4_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA4 DEFINIENS.txt')
D_TMA4_DT= loading(D_TMA4_path)[,block := 'willa_definiens_4']

D_TMA5_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA5 DEFINIENS.txt')
D_TMA5_DT= loading(D_TMA5_path)[,block := 'willa_definiens_5']


# m1 <- merge(D_TMA1_DT, ManScoringDT, by="case")
# m5 <- merge(D_TMA5_DT, ManScoringDT, by="case")
# m1b <- merge(D_TMA1b_DT, ManScoringDT, by="case")


TMA_list <- list(tma1=D_TMA1b_DT,
                 tma2=D_TMA2_DT,
                 tma3=D_TMA3_DT,
                 tma4=D_TMA4_DT,
                 tma5=D_TMA5_DT)

willa_definiens <- do.call("rbind", TMA_list)

willa_definiens <<- willa_definiens[,category := 'rater3_definiens']#[,log2_score := log2(score + 0.1)]

# lapply(TMA_list, generateStatistics, manual_DT=ManScoringDT)

# dev.off()
