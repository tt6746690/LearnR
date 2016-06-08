# import
library('ggplot2')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/corWithTMAstaining")
# source('corWithTMAstaining.R')


# options
options(digits=3)

# const
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N1 SCOMP'

# sinks
pdf("./sink/corWithTMAstaining.pdf")
sink("./sink/corWithTMAstaining.txt")

# file names
f_CONTROL = './data/2016-02-05 CONTROL.txt'
f_DCIS1 = './data/2016-01-12 DCIS1.txt'
f_DCIS2 = './data/2016-01-25 DCIS2.txt'
f_IDC1 = './data/2016-01-15 IDC1.txt'
f_IDC2 = './data/2016-01-26 IDC2.txt'
f_staining = "./data/TMAscores.txt"

ct <- process(load(f_CONTROL), refGene, tarGene, CONTROL)
dcis1 <- process(load(f_DCIS1), refGene, tarGene, CONTROL)
dcis2 <- process(load(f_DCIS2), refGene, tarGene, CONTROL)
idc1 <- process(load(f_IDC1), refGene, tarGene, CONTROL)
idc2 <- process(load(f_IDC2), refGene, tarGene, CONTROL)

scores <- data.table(read.table(f_staining, header=TRUE, sep='\t', na.strings=c('NA', "")))
splitstring <- function(s){
  return(strsplit(s, " ")[[1]][2])
}
scores[, cases := lapply(cases, as.character)][, cases := lapply(cases, splitstring)][, cases := unlist(scores$cases)]
scores <- unique(scores)



# extract useful columns
ct <- ct[,.(Sample.Name, ddCt, fold, category='CONTROL')]     # grep("SCOMP", Sample.Name, invert=T)
dcis1 <- dcis1[,.(Sample.Name, ddCt, fold, category='DCIS1')]
dcis2 <- dcis2[,.(Sample.Name, ddCt, fold, category='DCIS2')]
idc1 <- idc1[,.(Sample.Name, ddCt, fold, category='IDC1')]
idc2 <- idc2[,.(Sample.Name, ddCt, fold, category='IDC2')]

# rbind concat data table with same colnames but different nrow()
# b = rbind(ct, dcis1, dcis2, idc1, idc2)
b = rbind(dcis2, idc1)
# print(lapply(b, function(x){print(class(x))}))
b[, cases := lapply(Sample.Name, as.character)][, Sample.Name := NULL]
splitstring2 <- function(x){
  return(strsplit(x, "A")[[1]][1])
}
splitstring3 <- function(x){
  return(strsplit(x, "B")[[1]][1])
}
b[, cases := lapply(cases, splitstring2)][, cases := lapply(cases, splitstring3)][, cases := unlist(b$cases)]

DT <- merge(scores, b, by='cases', all=FALSE)
# get 40 data points with expression + staining result

boxplot(fold~ki67, data=DT, xlab='ki67 status', ylab='PITPNC1 fold change')
boxplot(fold~her2, data=DT, xlab='her2 status', ylab='PITPNC1 fold change')

print(t.test(DT$fold~DT$her2))
print(t.test(DT$fold~DT$ki67))


dev.off()
sink()      # redirect results to console
