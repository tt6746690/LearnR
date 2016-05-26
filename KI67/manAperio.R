rm(list = ls())
library('ggplot2')
library('data.table')
library('MethComp')
library('BlandAltmanLeh')
library('BSDA')
source('./util/methods.R')

# # sinks
pdf("./sink/TMA_manualVSAperio.pdf")
sink("./sink/TMA_manualVSAperio.txt")

options(digits=3)

# manual scoring block #1-6
Manual_Scoring_path = file.path(getwd(), 'data', 'WILLA MANUAL.txt')
ManScoringDT <- data.table(read.table(Manual_Scoring_path, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))

# aperio blocks # 2-6
A_TMA2_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA2 APERIO.txt')
A_TMA3_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA3 APERIO.txt')
A_TMA4_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA4 APERIO.txt')
A_TMA5_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA5 APERIO.txt')
A_TMA6_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA6 APERIO.txt')


A_TMA2_DT <- data.table(read.table(A_TMA2_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))
A_TMA3_DT <- data.table(read.table(A_TMA3_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))
A_TMA4_DT <- data.table(read.table(A_TMA4_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))
A_TMA5_DT <- data.table(read.table(A_TMA5_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))
A_TMA6_DT <- data.table(read.table(A_TMA6_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))

A_TMA_list <- list(tma2=A_TMA2_DT,
                   tma3=A_TMA3_DT,
                   tma4=A_TMA4_DT,
                   tma5=A_TMA5_DT,
                   tma6=A_TMA6_DT)

lapply(A_TMA_list, generateStatistics, manual_DT=ManScoringDT)
dev.off()
