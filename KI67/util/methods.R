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
    DT[, ':=' (         # in percentage
         zeroPositive = 100*(Nucleus.High + Nucleus.Medium + Nucleus.Low)/All.Nucleus,
         pointFourPositive = 100*(Nucleus.High + Nucleus.Medium)/All.Nucleus,
         pointSevenPositive = 100*Nucleus.High/All.Nucleus)]
    DT[, c("Nucleus.Low", "Nucleus.Medium", "Nucleus.High", "All.Nucleus"):= NULL]
    # remove this if want to see other 0.4 and 0.7 cutoffs
    DT[, c("pointSevenPositive", "pointFourPositive", "TMA"):= NULL]
    return(DT)
}

#
# myBAplot <- function(DT){
#     bland.altman.plot(group1, group2, two = 1.96, mode = 1,
#                     graph.sys = "base", conf.int = 0, silent = TRUE, sunflower = FALSE,
#                     geom_count = FALSE, ...)
#     with(combined_DT, plot((zeroPositive.x + zeroPositive.y)/2, zeroPositive.x - zeroPositive.y, main="Mean-Difference-Plot"))
#     # with(data.frame(combined_DT), BA.plot(zeroPositive.x, zeroPositive.y))
#
#     # BA.est(combined_DT)
#     #
# }
