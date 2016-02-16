# import
library('ggplot2')
library('wesanderson')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
# setwd("C:/Users/PeiqiWang/Desktop/LearningR")
# source('controlComparison.R')

# options
options(digits=2)

# const
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N1 SCOMP'

# path
ct1 = './data/2016 02 04 CONTROLS 3 3WGA 3SCOMP.txt'
ct2 = './data/2016-02-05 CONTROL.txt'

# sinks
pdf("./sink/controlComparison.pdf")
sink("./sink/controlComparison.txt")

# load the data sheet
ct1 <- process(load(ct1), refGene, tarGene, CONTROL)
ct2 <- process(load(ct2), refGene, tarGene, CONTROL)

# extract ddCt, which is independent of plate run
ct1 <- ct1[, .(Sample.Name, ddCt, fold)]
ct2 <- ct2[, .(Sample.Name, ddCt, fold)]

# combine data from two sources
DT <- rbind(ct1, ct2)
# assign categories
wga <- DT[grep('WGA', Sample.Name), .(Sample.Name, ddCt, fold, category = 'WGA')]
scomp <- DT[grep('SCOMP', Sample.Name),.(Sample.Name, ddCt, fold, category = 'SCOMP')]
unamp <- DT[grep('WGA|SCOMP|W', Sample.Name, invert = T),.(Sample.Name, ddCt, fold, category = 'UNAMP')]

# combine data again
DT <- rbind(wga, scomp, unamp)

# t test
wgav <- DT$ddCt[DT$category == 'WGA']
scompv <- DT$ddCt[DT$category == 'SCOMP']
unampv <- DT$ddCt[DT$category == 'UNAMP']

print(t.test(unampv, wgav))
print(t.test(unampv, scompv))
print(t.test(wgav, scompv))

# plots
print(ggplot(DT, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(0,10) +
ggtitle('comparison of normal human cells with varying amplification methods'))

print(ggplot(DT, aes(x=category, y=ddCt)) + geom_boxplot() +  scale_fill_grey() +
geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(-6, 4) +
ggtitle('comparison of normal human cells with varying amplification methods'))

dev.off()   # redirect reseults console
sink()
