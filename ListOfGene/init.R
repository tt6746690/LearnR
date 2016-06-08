rm(list = ls())
library('ggplot2')
library('data.table')


# sinks
# pdf("./sink/genesTMAanalysis.pdf")
sink("./sink/genesTMAanalysis.txt")

options(digits=3)
# tma score for genes SPAG5, SFRSF, CACNG4, CHD1, GA13
TMAscorePath= file.path(getwd(), 'data', 'TMAtable.txt')
DT <- data.table(read.table(TMAscorePath, header=TRUE, sep = "\t",
       na.strings=c("NA", "N/A", "", "N"), stringsAsFactors=FALSE, strip.white=TRUE))

geneScore_DT <- DT[, .(ID=paste(TMA, Column, Row, sep=''), SPAG5, CACNG4 = CACNG4..NvsC, SFRS7 = SFRS7.percent, CHD1, GNA13 = GA13)]
TumorStat_DT <- DT[, .(ID=paste(TMA, Column, Row, sep=''), GRADE.nor, SIZE.nor, LVI, LN, ER, PR, HER.2, Type)]
DT <- merge(geneScore_DT, TumorStat_DT, by='ID')
DF <- data.frame(DT)


applyChiSquaredTests <- function(x){
  Grade.tbl <-  table(gene=x, Grade=DT$GRADE.nor, useNA='no')
  Grade.pvalue <- summary(Grade.tbl)$p.value

  Size.tbl <- table(gene=x, Size=DT$SIZE.nor, useNA='no')
  Size.pvalue <- summary(Size.tbl)$p.value

  LVI.tbl <- table(gene=x, LVI=DT$LVI, useNA='no')
  LVI.pvalue <- summary(LVI.tbl)$p.value

  LN.tbl <- table(gene=x, LN=DT$LN, useNA='no')
  LN.pvalue <- summary(LN.tbl)$p.value

  ER.tbl <- table(gene=x, ER=DT$ER, useNA='no')
  ER.pvalue <- summary(ER.tbl)$p.value

  PR.tbl <- table(gene=x, PR=DT$PR, useNA='no')
  PR.pvalue <- summary(PR.tbl)$p.value

  HER.2.tbl <- table(gene=x, HER.2=DT$HER.2, useNA='no')
  HER.2.pvalue <- summary(HER.2.tbl)$p.value

  summary <- c(grade = Grade.pvalue,
               Size = Size.pvalue,
               LVI = LVI.pvalue,
               LN = LN.pvalue,
               ER = ER.pvalue,
               PR = PR.pvalue,
               HER.2 = HER.2.pvalue)
  return(summary)
}



applyFisherTests <- function(x){
  Grade.tbl <-  table(gene=x, Grade=DT$GRADE.nor, useNA='no')
  Grade.pvalue <- fisher.test(Grade.tbl)$p.value

  Size.tbl <- table(gene=x, Size=DT$SIZE.nor, useNA='no')
  Size.pvalue <- fisher.test(Size.tbl)$p.value

  LVI.tbl <- table(gene=x, LVI=DT$LVI, useNA='no')
  LVI.pvalue <- fisher.test(LVI.tbl)$p.value

  LN.tbl <- table(gene=x, LN=DT$LN, useNA='no')
  LN.pvalue <- fisher.test(LN.tbl)$p.value

  ER.tbl <- table(gene=x, ER=DT$ER, useNA='no')
  ER.pvalue <- fisher.test(ER.tbl)$p.value

  PR.tbl <- table(gene=x, PR=DT$PR, useNA='no')
  PR.pvalue <- fisher.test(PR.tbl)$p.value

  HER.2.tbl <- table(gene=x, HER.2=DT$HER.2, useNA='no')
  HER.2.pvalue <- fisher.test(HER.2.tbl)$p.value

  `summary` <- c(grade = Grade.pvalue,
               Size = Size.pvalue,
               LVI = LVI.pvalue,
               LN = LN.pvalue,
               ER = ER.pvalue,
               PR = PR.pvalue,
               HER.2 = HER.2.pvalue)
  return(summary)
}



chisq.tbl <- data.frame(lapply(DF[,2:6], applyChiSquaredTests))
fisher.tbl <- data.frame(lapply(DF[,2:6], applyFisherTests))

cat('\n\nchi squared test p-value table\n\n')
print(chisq.tbl)

cat('\n\nfisher test p-value table\n\n')
print(fisher.tbl)

dev.off()
