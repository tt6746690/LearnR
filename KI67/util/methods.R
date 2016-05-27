library("ggplot2")

loading <- function(path){
  DT <- data.table(read.table(path, header=TRUE, sep = "\t",
                   na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))

  # sort table according to name ascending order
  setkey(DT, ROI.name)
  count_col = c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus")

  # select only tumor region and discard ROI.name column
  # should be DT[ROI.name == 'Tumor'], the following is only possible after setkey()
  ROI_tumor_DT <- DT["Tumor"][,ROI.name := NULL]

  # the total area table, which includes epithelial + stromal areas
  ROI_total_DT <- DT[, lapply(.SD, sum),by=Slide.name, .SDcols = count_col]

  ROI_total_DT <- initialProcess(ROI_total_DT)
  ROI_tumor_DT <- initialProcess(ROI_tumor_DT)
  # return only tumor area, may export total area for later analysis
  return(ROI_tumor_DT)
}

initialProcess <- function(DT){
    DT[, c("TMA", "case", "replicate", "dbID") := transpose(strsplit(Slide.name, "-"))]
    DT[, c("Slide.name", "replicate", "dbID") := NULL]
    DT[,
       c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus")
           := list(sum(Nucleus.Low), sum(Nucleus.Medium),
                   sum(Nucleus.High), sum(All.Nucleus)),
       by=c("case")]
    DT <- unique(DT)[,.(TMA, case, All.Nucleus, Nucleus.High, Nucleus.Medium,
                     Nucleus.Low)][, case:=as.integer(case)][order(case)]
    DT[, ':=' (         # in percentage chose 0% cutoff as score
         score = 100*(Nucleus.High + Nucleus.Medium + Nucleus.Low)/All.Nucleus,
         pointFourPositive = 100*(Nucleus.High + Nucleus.Medium)/All.Nucleus,
         pointSevenPositive = 100*Nucleus.High/All.Nucleus)]
    DT[, c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus"):= NULL]
    # remove this if want to see other 0.4 and 0.7 cutoffs
    DT[, c("pointSevenPositive", "pointFourPositive", "TMA"):= NULL]
    return(DT)
}

generateStatistics <- function(DT, manual_DT){
  print('1 TMA block analysis output:')

  # To perform SQL type inner joins set ON clause as keys of tables
  setkey(DT, case)
  setkey(manual_DT, case)
  # Perform inner join, eliminating not matched rows from Right
  rDT <- manual_DT[DT, nomatch=0]

  # rDT <- rDT[(score < 21) & (i.score < 21)]

  # pearson correlation + scatter plot as requested
  cat('\nPearson correlation estimates\n')
  print(cor.test(rDT$score, rDT$i.score)$estimate)
  cat('\nPearson correlation p-value\n')
  print(cor.test(rDT$score, rDT$i.score)$p.value)

  print(ggplot(rDT, aes(x=score, y=i.score)) +
      geom_point(shape=1) +  geom_smooth(method = "lm", se = FALSE) +
      xlab('Manual Score') + ylab('Definiens'))

  # limits of agreements
  difference = rDT$score - rDT$i.score
  cat('\nlimits of agreements\n')
  print(mean(difference)-1.96*sd(difference))
  print(mean(difference)+1.96*sd(difference))

  # 95 percent confidence interval sof mean of difference
  cat('\nz test confidence interval (if does not contain 0 -> exists bias):\n')
  print(z.test(difference, sigma.x=sd(difference))$conf.int)
  cat('\n\n\n\n\n')

  # QQplot to see if difference is normally distributed
  qqnorm(difference)
  qqline(difference)

  # preliminary BAplot
  print(bland.altman.plot(rDT$score, rDT$i.score, graph.sys = "ggplot2", conf.int=.95))

}
