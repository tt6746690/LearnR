# import
library('ggplot2')
library('wesanderson')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
setwd("C:/Users/PeiqiWang/Desktop/LearningR")

# options
options(digits=2)

# const
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N1 SCOMP'

# sinks
pdf("./sink/PITPNC1.pdf")
sink("./sink/PITPNC1.txt")

# file names
f_CONTROL = './data/2016-02-05 CONTROL.txt'
f_DCIS1 = './data/2016-01-12 DCIS1.txt'
f_DCIS2 = './data/2016-01-25 DCIS2.txt'
f_IDC1 = './data/2016-01-15 IDC1.txt'
f_IDC2 = './data/2016-01-26 IDC2.txt'

ct <- process(load(f_CONTROL), refGene, tarGene, CONTROL)
dcis1 <- process(load(f_DCIS1), refGene, tarGene, CONTROL)
dcis2 <- process(load(f_DCIS2), refGene, tarGene, CONTROL)
idc1 <- process(load(f_IDC1), refGene, tarGene, CONTROL)
idc2 <- process(load(f_IDC2), refGene, tarGene, CONTROL)

# check for outliers by inspection
#print(data.frame(ct))
#print(data.frame(dcis1))
#print(data.frame(dcis2))
#print(data.frame(idc1))

# extract useful columns
ct <- ct[,.(Sample.Name, ddCt, fold, category='CONTROL')]
dcis1 <- dcis1[,.(Sample.Name, ddCt, fold, category='DCIS1')]
dcis2 <- dcis2[,.(Sample.Name, ddCt, fold, category='DCIS2')]
idc1 <- idc1[,.(Sample.Name, ddCt, fold, category='IDC1')]
idc2 <- idc2[,.(Sample.Name, ddCt, fold, category='IDC2')]

# rbind concat data table with same colnames but different nrow()
b = rbind(ct, dcis1, dcis2, idc1, idc2)

# plot 4 graphs
#plot4(b)    # dev
plotEach(b) # prod

dev.off()   # redirect reseults console

# significance test
controlv <- b$ddCt[b$category == 'CONTROL']
dcis1v <- b$ddCt[b$category == 'DCIS1']
dcis2v <- b$ddCt[b$category == 'DCIS2']
idc1v <- b$ddCt[b$category == 'IDC1']
idc2v <- b$ddCt[b$category == 'IDC2']


dcis1VScontrol <- t.test(dcis1v, controlv)
dcis2VScontrol <- t.test(dcis2v, controlv)
idc1VScontrol <- t.test(idc1v, controlv)
dcis2VSidc1 <- t.test(dcis2v, idc1v)
dcis2VSidc2 <- t.test(dcis2v, idc2v)
dcis1VSidc1 <- t.test(dcis1v, idc1v)
dcis1VSidc2 <- t.test(dcis1v, idc2v)

print(dcis1VScontrol)
print(dcis2VScontrol)
print(idc1VScontrol)
print(dcis2VSidc1)
print(dcis2VSidc2)
print(dcis1VSidc1)
print(dcis1VSidc2)

sink()      # redirect results to console
