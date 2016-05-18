library('ggplot2')
library('data.table')
library('MethComp')
library('BlandAltmanLeh')
library('BSDA')
source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/KI67")
# source('init.R')

# sinks
pdf("./sink/TMA5_manualVSdefiniens.pdf")
sink("./sink/TMA5_manualVSdefiniens.txt")

options(digits=3)

# manual scoring block #1-6
Manual_Scoring_path = file.path(getwd(), 'data', 'WILLA MANUAL.txt')
ManScoringDT <- data.table(read.table(Manual_Scoring_path, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))
# definiens
D_TMA5_path = file.path(getwd(), 'data', 'definiens', 'TIAN TMA5 DEFINIENS.txt')
D_TMA5_DT= loading(D_TMA5_path)


# To perform SQL type inner joins set ON clause as keys of tables
setkey(D_TMA5_DT, case)
setkey(ManScoringDT, case)
# Perform inner join, eliminating not matched rows from Right
rDT <- ManScoringDT[D_TMA5_DT, nomatch=0]

rDT <- rDT[(zeroPositive < 21) & (i.zeroPositive < 21)]

print(rDT)
# QQplot to see if difference is normally distributed
difference = rDT$zeroPositive - rDT$i.zeroPositive
print(qqnorm(difference))
print(qqline(difference))

# limits of agreements
print(mean(difference)-2*sd(difference))
print(mean(difference)+2*sd(difference))


# 95 percent confidence interval of mean of difference
print(z.test(difference, sigma.x = 6.8))

# 99 percent confidence interval of mean of difference
print(z.test(difference, sigma.x = 6.8, conf.level=0.99))


# preliminary BAplot
pl <- bland.altman.plot(rDT$zeroPositive, rDT$i.zeroPositive, graph.sys = "ggplot2", conf.int=.95)
print(pl)

dev.off()
