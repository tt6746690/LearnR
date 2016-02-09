library('ggplot2')

setwd("C:/Users/PeiqiWang/Desktop/LearningR")
source('methods.R')
# options
options(digits=2)

# const
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N1 SCOMP'


# file names
f_IDC = './data/2016-01-15 IDC1.txt'
f_DCIS = './data/2016-01-12 DCIS1.txt'
f_CONTROL = './data/2016-02-05 CONTROL.txt'

DT_idc <- process(load(f_IDC), refGene, tarGene, CONTROL)
DT_dcis <- process(load(f_DCIS), refGene, tarGene, CONTROL)
DT_control <- process(load(f_CONTROL), refGene, tarGene, CONTROL)

# check for outliers by inspection
print(head(DT_idc))
print(head(DT_dcis))
print(head(DT_control))


DT_idc <- DT_idc[,.(Sample.Name, ddCt, fold, category='IDC')]
DT_dcis <- DT_dcis[,.(Sample.Name, ddCt, fold, category='DCIS')]
DT_control <- DT_control[,.(Sample.Name, ddCt, fold, category='CONTROL')]


b = rbind(DT_idc, DT_dcis, DT_control)    # rbind concat data table with same colnames but different nrow()

par(mfrow = c(1,1))
print(ggplot(b, aes(x=category, y=ddCt)) + geom_boxplot(aes(fill = factor(category)) + geom_jitter() + coord_flip())
