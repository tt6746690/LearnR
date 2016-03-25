# import
library('ggplot2')
library('wesanderson')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')

# setup working directory
# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/PITPNC1")
# source('cellLine.R')


# options
options(digits=3)

# const
refGene = 'gapdh'
tarGene = 'PITPNC1'
CONTROL = '231 con oe'

# sinks
pdf("./sink/cellLine.pdf")
sink("./sink/cellLine.txt")

# file names
f_pit = './data/2016-02-03 transfection success.txt'

# manipulation
DT <- process(load(f_pit), refGene, tarGene, CONTROL)
DT <- DT[, .(Sample.Name, fold, category='231 cell line', CL='231')]
defaultRow <- list('231 con oe', 1, 'Transfection control', '231')
DT <- rbind(defaultRow, DT)

DT <- DT[, .(Sample.Name, fold, category, CL)]
DT$category2 <- factor(DT$category, levels = c("Transfection control", "231 cell line"))


print(ggplot(DT, aes(x=category2, y=fold, group=CL)) + geom_point(colour = "#4b4b4b") +
scale_colour_gradient(low = "gray", high = "black") + geom_bar(stat="identity", width = 0.4) +
theme(plot.title = element_text(size = rel(1.0))) +
theme(plot.title = element_text(vjust=1)) +
theme(axis.title.y = element_text(size = 20, angle = 90, family = "Helvetica", color="#666666", hjust=0.5)) +
theme(axis.text.x = element_text(size = 18, angle = 0, family = "Helvetica", color="#666666", vjust=0.5, hjust=0.5)) +
theme(axis.title.x = element_blank()) +
theme(legend.position = "none") +
theme(plot.margin = unit(c(1,1,1,1), "cm")) +
scale_x_discrete(labels = c("Control", "Transfection")) +
scale_y_continuous("Relative Fold Difference\n", breaks = c(0, 2, 4, 6, 8), limits = c(0, 8)))

sink()      # redirect results to console
