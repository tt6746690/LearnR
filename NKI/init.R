rm(list=ls())
library('ggplot2')
library('data.table')
library('breastCancerNKI')


# sinks
# pdf("./sink/genesTMAanalysis.pdf")
# sink("./sink/NKIanalysis.txt", split=TRUE)

options(digits=3)

# nki_chang_Path= file.path(getwd(), 'data', 'NKI_complete_concatenated.txt')
# DT <- data.table(read.table(nki_chang_Path, header=TRUE, sep = "\t",
#        na.strings=c("NA", "N/A", "", "N"), stringsAsFactors=FALSE, strip.white=TRUE))





head(DT)



# dev.off()
