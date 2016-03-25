# import
library('ggplot2')
library('wesanderson')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/PITPNC1")
# source('controlComparison.R')

# options
options(digits=2)

# const
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N28'

# path
ct1 = './data/2016 02 04 CONTROLS 3 3WGA 3SCOMP.txt'
ct2 = './data/2016-02-05 CONTROL.txt'

# sinks
pdf("./sink/controlComparison3.pdf")
sink("./sink/controlComparison3.txt")

# load the data sheet
ct1 <- process(load(ct1), refGene, tarGene, CONTROL)
ct2 <- process(load(ct2), refGene, tarGene, CONTROL)

# extract ddCt, which is independent of plate run
ct1 <- ct1[, .(Sample.Name, ddCt, fold)]
ct2 <- ct2[, .(Sample.Name, ddCt, fold)]

# combine data from two sources
DT <- rbind(ct1, ct2)
print(DT)
# assign categories
wga <- DT[grep('WGA', Sample.Name), .(Sample.Name, ddCt, fold, category = 'WGA')]
scomp <- DT[grep('SCOMP', Sample.Name),.(Sample.Name, ddCt, fold, category = 'SCOMP')]
unamp <- DT[grep('WGA|SCOMP|W', Sample.Name, invert = T),.(Sample.Name, ddCt, fold, category = 'UNAMP')]

# combine data again
DT <- rbind(unamp, scomp, wga)

# t test
wgav <- DT$ddCt[DT$category == 'WGA']
scompv <- DT$ddCt[DT$category == 'SCOMP']
unampv <- DT$ddCt[DT$category == 'UNAMP']

print(t.test(unampv, wgav))
print(t.test(unampv, scompv))
print(t.test(wgav, scompv))

# plots
print(ggplot(DT, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
scale_colour_gradient(low = "gray", high = "black") + geom_point(aes(color = fold)) +
theme(plot.title = element_text(size = rel(1.0))) +
theme(plot.title = element_text(vjust=1)) +
theme(axis.title.y = element_text(size = 20, angle = 90, family = "Helvetica", color="#666666", hjust=0.5)) +
theme(axis.text.x = element_text(size = 18, angle = 0, family = "Helvetica", color="#666666", vjust=0.5, hjust=0.5)) +
theme(axis.title.x = element_blank()) +
theme(legend.position = "none") +
theme(plot.margin = unit(c(1,1,1,1), "cm")) +
scale_x_discrete(labels = c("SCOMP", "Unamplified", "WGA")) +
scale_y_continuous("Relative Fold Difference\n", breaks = c(0, 1, 2, 3, 4)))

dev.off()   # redirect reseults console
sink()
