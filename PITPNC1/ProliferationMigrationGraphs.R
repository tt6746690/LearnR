# import
library('ggplot2')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/PITPNC1")
# source('ProliferationMigrationGraphs.R')


# options
options(digits=4)

# const


# sinks
pdf("./sink/ProliferationMigrationGraphs.pdf")
sink("./sink/ProliferationMigrationGraphs.txt")

# const
refGene = 'GAPD'
tarGene = c('PITPNC', 'Cyclin D1', 'cmyc', 'SNAIL2')
CONTROL = 'mcf10A con'

# file names
f_path = './data/2016-02-29 MCF10A PITPNC1.txt'
f = load(f_path)

pitpnc <- process(f, refGene, tarGene[1], CONTROL)
cyclind1 <- process(f, refGene, tarGene[2], CONTROL)
cmyc <- process(f, refGene, tarGene[3], CONTROL)
snail2 <- process(f, refGene,tarGene[4], CONTROL)
print(pitpnc)
print(cyclind1)
print(cmyc)
print(snail2)


control3 = c(400, 400, 600, 400)
pitpnc13 = c(960, 800, 760)

df <- data.frame(
  date = factor(c('day0', 'day0', 'day3', 'day3')),
  counts = c(250, 250, mean(control3), mean(pitpnc13)),
  group = factor(c('Control', 'PITPNC1', 'Control', 'PITPNC1')),
  upper = c(250, 250, 450, 880),
  lower = c(250, 250, 400, 780)
)

# Define the top and bottom of the boxplots
limits <- aes(ymax = upper, ymin = lower)
cpalette <- c('#666666', '#666666','#4b4b4b', '#4b4b4b')
linepalette <- c('#4b4b4b', '#4b4b4b', '#4b4b4b', '#4b4b4b')

print(ggplot(df, aes(y=counts, x=date)) +
geom_point(colour=cpalette) + geom_errorbar(limits, width=0.15, size=0.9, colour=cpalette) +
geom_line(aes(group=group), colour=linepalette, size=1.1) +
scale_x_discrete(labels = c("Day 0", "Day 3")) +
scale_y_continuous("Cell Counts\n", breaks = c(0, 150, 300, 450, 600, 750, 900), limits = c(0, 900)) +
geom_text(aes(label = group), hjust = -0.5, vjust = 0.5, size = 5, family = "Helvetica",  color="#666666") +
theme(plot.title = element_text(size = rel(1.0))) +
theme(plot.title = element_text(vjust=1)) +
theme(axis.title.y = element_text(size = 20, angle = 90, family = "Helvetica", color="#666666", hjust=0.5)) +
theme(axis.text.x = element_text(size = 20, angle = 0, family = "Helvetica", color="#666666", vjust=0.5, hjust=0.5)) +
theme(axis.title.x = element_blank()) +
theme(legend.position = "bottom") +
theme(plot.margin = unit(c(1,1,1,1), "cm")) )




# end exports
dev.off()   # redirect reseults console
sink()      # redirect results to console
