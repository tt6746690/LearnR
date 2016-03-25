library('ggplot2')
library('data.table')
library('MethComp')
library('BlandAltmanLeh')
source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67")
# source('init.R')

options(digits=3)


path_TMA5 = "C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67/data/2016_03_24 TMA5.txt"
DT <- data.table(read.table(path_TMA5, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))


setkey(DT, ROI.name)
count_col = c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus")

ROI_tumor_DT <- DT["Tumor"][,ROI.name := NULL]
ROI_total_DT <- DT[, lapply(.SD, sum),by=Slide.name, .SDcols = count_col]

ROI_total_DT <- initialProcess(ROI_total_DT)
ROI_tumor_DT <- initialProcess(ROI_tumor_DT)


combined_DT <- merge(ROI_total_DT, ROI_tumor_DT, by = "case")

p <- with(combined_DT, bland.altman.plot(zeroPositive.x, zeroPositive.y, graph.sys = "ggplot2", conf.int=.95))
print(p)



# sinks
# pdf("./sink/PITPNC1.pdf")
# sink("./sink/PITPNC1.txt")
# sink()      # redirect results to console
