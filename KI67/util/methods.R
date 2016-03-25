library("ggplot2")


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
