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

initialProcessAperio <- function(DT){
  DT[,
    c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus")
        := list(sum(Nucleus.Low), sum(Nucleus.Medium),
                sum(Nucleus.High), sum(All.Nucleus)),
    by=c("case")]

  DT <- unique(DT)[,.(case, All.Nucleus, Nucleus.High, Nucleus.Medium,
                   Nucleus.Low, block)][, case:=as.integer(case)][order(case)]

  DT[, ':=' (         # in percentage chose 0% cutoff as score
      score = 100*(Nucleus.High + Nucleus.Medium + Nucleus.Low)/All.Nucleus)]

  DT[, c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus"):= NULL]

  return(DT)
}



generateStatistics <- function(DT, manual_DT){
  print('1 TMA block analysis output:')

  merged <- merge(DT, manual_DT, by="case")
  cutoff <- 15
  print(merged[score.x < cutoff & score.y > cutoff,])
  plot(merged$score.x, merged$score.y, xlab='machine', ylab='manual')
  abline(a=0, b=1)
  abline(a=cutoff, b=0)
  abline(v=cutoff)


  # To perform SQL type inner joins set ON clause as keys of tables
  setkey(DT, case)
  setkey(manual_DT, case)
  # Perform inner join, eliminating not matched rows from Right
  rDT <- manual_DT[DT, nomatch=0]
  print(rDT)

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


#
#
# get_spaghatti_plot <- function(dt, xlabels){
#   plt <- ggplot(dt, aes(x=category, y=score, group=case)) +
#     geom_line(alpha=0.2) + geom_point() +
#     scale_x_discrete(limits=xlabels) +
#     labs(x="Raters", y="Ki-67 Labeling Index") +
#     theme_bw()
#   print(plt)
#
# }

get_scatter_plot <- function(DT, manual_DT, yaxis, title){
  # To perform SQL type inner joins set ON clause as keys of tables
  setkey(DT, case)
  setkey(manual_DT, case)
  # Perform inner join, eliminating not matched rows from Right
  rDT <- manual_DT[DT, nomatch=0]
  q <- ggplot(rDT, aes(x=score, y=i.score)) +
  geom_point(alpha=0.3) +
  geom_abline(intercept = 0, slope = 1) +
  labs(x="manual scores", y=yaxis, title=title) +
  expand_limits(x=c(0, 100), y=c(0, 100))
  return(q)
}


get_ba_plot <- function(DT, manual_DT, title){
  # To perform SQL type inner joins set ON clause as keys of tables
  setkey(DT, case)
  setkey(manual_DT, case)
  # Perform inner join, eliminating not matched rows from Right
  rDT <- manual_DT[DT, nomatch=0]

  # preliminary BAplot
  ba_stats <- bland.altman.stats(rDT$score, rDT$i.score, two = 1.96, mode = 1, conf.int = 0.95)
  df <- data.table(ba_stats$means, ba_stats$diffs)
  colnames(df) <- c('means', 'diffs')

  p <- ggplot(df, aes(means, diffs)) +
  geom_point(alpha = 0.3) +
  labs(x="Average Ki-67 Labeling index", y="Difference in Ki-67 Labeling index", title=title) +
  expand_limits(y=c(-100, 100)) +
  geom_line(aes(y=ba_stats$lines[1]),linetype="dotted", size = 1) +
  geom_line(aes(y=ba_stats$lines[2]), size = 1) +
  geom_line(aes(y=ba_stats$lines[3]),linetype="dotted", size = 1) +
  geom_ribbon(aes(ymin=ba_stats$CI.lines[1], ymax=ba_stats$CI.lines[2]), alpha=0.1) +
  geom_ribbon(aes(ymin=ba_stats$CI.lines[3], ymax=ba_stats$CI.lines[4]), alpha=0.1) +
  geom_ribbon(aes(ymin=ba_stats$CI.lines[5], ymax=ba_stats$CI.lines[6]), alpha=0.1)

  return(p)
}



get_ba_stat <- function(DT, manual_DT){
  # To perform SQL type inner joins set ON clause as keys of tables
  setkey(DT, case)
  setkey(manual_DT, case)
  # Perform inner join, eliminating not matched rows from Right
  rDT <- manual_DT[DT, nomatch=0]

  # preliminary BAplot
  ba_stats <- bland.altman.stats(rDT$score, rDT$i.score, two = 1.96, mode = 1, conf.int = 0.95)
  return(ba_stats)
}

checkBAOutlier <- function(dt1, dt2, l.lim, u.lim){
  combine <- merge(dt1, dt2, by='case')
  combine <- data.table(combine)[,outlier := (score.x - score.y) > u.lim | (score.x - score.y) < l.lim][outlier == TRUE,]
  return(combine)
}




get_icc <- function(rater1, rater2){
  total_icc <- merge(rater1, rater2, by="case")[,c("case", "category.x", "category.y", "block.x", "block.y"):= NULL]
  total_icc <- total_icc[, .(score.x = log2(score.x + 1), score.y = log2(score.y + 1))]
  colnames(total_icc) <- c('rater1', 'rater2')
  results <- icc(total_icc, model="twoway", type="agreement", unit="average")
  print(results)
}

get_kappa <- function(rater1, rater2, cutoff){
  total_kappa <- merge(rater1, rater2, by="case")[,c("case", "category.x", "category.y", "block.x", "block.y"):= NULL]
  total_kappa <- total_kappa[, .(score.x = log2(score.x + 1), score.y = log2(score.y + 1))]
  colnames(total_kappa) <- c('rater1', 'rater2')
  total_kappa <- total_kappa[, ':=' (rater1 = rater1 > log2(cutoff + 1), rater2 = rater2 >  log2(cutoff + 1))]
  results <- kappam.fleiss(total_kappa, exact = FALSE)
  # print(total_kappa)
  # print(results)
  return(results[5]) # kappa values
}

MapKappa <- function(rater1, rater2, cutoff, category){
  kappaCont <- lapply(cutoff, function(x){
      return(data.frame(x, get_kappa(rater1, rater2, x), category))
    })
  kappaCont <- do.call('rbind', kappaCont)
  # plot(kappaCont)
  # print(kappaCont)
  return(kappaCont)
}
