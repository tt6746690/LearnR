rm(list = ls())
library('ggplot2')
library('data.table')
library('MethComp')
library('BlandAltmanLeh')
library('BSDA')
library('Hmisc')
library('MASS')
library('ICC')
library('irr')
library('scales')
# for plotting multiple ggplot2 plots in one window
library('grid')
library('gridExtra')
source('./util/methods.R')
source('./util/multiplot.R')
source('aperio.R')
source('definiens.R')

options(digits=3)



## boxplot
##########################################################################################
# pdf("./sink/boxplot.pdf")
# total_r <- do.call('rbind', list(willa_manual, willa_aperio, tian_aperio, willa_definiens))
# p <- ggplot(total_r, aes(factor(category), score)) +
# geom_boxplot(alpha=0.2) +
# geom_jitter(shape=16, alpha=0.2, position=position_jitter(0.2)) +
# scale_x_discrete(limits=c("rater1_manual", "rater1_aperio", "rater2_aperio", "rater3_definiens")) +
# labs(x="Raters", y="Ki-67 Labeling Index")
# print(p)
# summary statistics
# pdf("./sink/boxStat.pdf", height=2.5, width=6)
# s <- t(do.call('cbind', tapply(total_r$score, total_r$category, summary)))
# new_mx <- do.call('rbind', list(s[2,], s[1,], s[3,], s[4,]))
# rownames(new_mx) <- c("Rater 1 Manual", "Rater 1 Aperio", "Rater 2 Aperio", "Rater 3 Definiens")
# latex(new_mx)
# grid.table(new_mx)
# dev.off()
##########################################################################################



## Scatterplot
##########################################################################################
# pdf('./sink/scatterplot.pdf', height=6, width=18)
# scatterplot <- list()
# scatterplot[[1]] <- get_scatter_plot(willa_aperio, willa_manual, "Rater 1 Aperio", "Rater 1 Manual vs Rater 1 Aperio")
# scatterplot[[2]] <- get_scatter_plot(tian_aperio, willa_manual,  "Rater 2 Aperio", "Rater 1 Manual vs Rater 2 Aperio")
# scatterplot[[3]] <- get_scatter_plot(willa_definiens, willa_manual, "Rater 3 Definiens", "Rater 1 Manual vs Rater 3 Definiens")
# multiplot(plotlist=scatterplot, cols=3, layout=matrix(c(1, 2, 3), nrow = 1, byrow = TRUE))
# dev.off()
##########################################################################################




## BA plot
#########################################################################################
# pdf("./sink/baplot.pdf", height=6, width=18)
# baplots <- list()
# baplots[[1]] <- get_ba_plot(willa_aperio, willa_manual, 'Rater 1 Manual vs Rater 1 Aperio')
# baplots[[2]] <- get_ba_plot(tian_aperio, willa_manual, 'Rater 1 Manual vs Rater 2 Aperio')
# # baplots[[4]] <- get_ba_plot(tian_aperio, willa_aperio, 'Rater 1 Aperio vs Rater 2 Aperio')
# baplots[[3]] <- get_ba_plot(willa_definiens, willa_manual, 'Rater 1 Manual vs Rater 3 Definiens')
# multiplot(plotlist=baplots, cols=3, layout=matrix(c(1, 2, 3), nrow = 1, byrow = TRUE))
# dev.off()

# pdf("./sink/baStat.pdf", height=1.5, width=11)
# ba_stats <- list()
# ba_stats[[1]] <- get_ba_stat(willa_aperio, willa_manual)
# ba_stats[[2]] <- get_ba_stat(tian_aperio, willa_manual)
# ba_stats[[3]] <- get_ba_stat(willa_definiens, willa_manual)
#
# lines <- lapply(ba_stats, function(x){
#     return(round(x$lines, 3))
#   })
# CI.lines <- lapply(ba_stats, function(x){
#     return(round(x$CI.lines[1:6],3))
#   })
# lines <- do.call('rbind', lines)
# CI.lines <- do.call('rbind', CI.lines)
# combined <- cbind(lines, CI.lines)
#
# combined <- data.table(combined)[, ':=' (
#   'Lower Limit (95% CI)' = paste(lower.limit, '(', lower.limit.ci.lower, '~', lower.limit.ci.upper, ')'),
#   'Mean Difference (95% CI)' = paste(mean.diffs, '(', mean.diff.ci.lower, '~', mean.diff.ci.upper, ')'),
#   'Upper Limit (95% CI)' = paste(upper.limit, '(', upper.limit.ci.lower, '~', upper.limit.ci.upper, ')')
#   )
# ][,.(`Lower Limit (95% CI)`, `Mean Difference (95% CI)`, `Upper Limit (95% CI)`)]
# print(combined)
#
# rownames(combined) <- c('Rater 1 Manual vs. Rater 1 Aperio', 'Rater 1 Manual vs. Rater 2 Aperio', 'Rater 1 Manual vs. Rater 3 Definiens')
# latex(combined)
# grid.table(combined)
# dev.off()
#########################################################################################



## icc
##########################################################################################
# sink('./sink/icc.txt')
# get_icc(willa_manual, willa_aperio)
# get_icc(willa_manual, tian_aperio)
# get_icc(willa_aperio, tian_aperio)
# get_icc(willa_manual, willa_definiens)
# get_icc(willa_aperio, willa_definiens)
# get_icc(tian_aperio, willa_definiens)
#
# dev.off()
# ##########################################################################################





### kappa
##########################################################################################
# pdf('./sink/kappaStat.pdf', height=2.5, width=8)
#
# cutoff <- c(5, 10, 14, 20, 25, 30)
# kappa_total <- list()
# kappa_total[[1]] <- MapKappa(willa_manual, willa_aperio, cutoff, "Rater 1 Manual vs. Rater 1 Aperio")
# kappa_total[[2]] <- MapKappa(willa_manual, tian_aperio, cutoff, "Rater 1 Manual vs. Rater 2 Aperio")
# kappa_total[[3]] <- MapKappa(tian_aperio, willa_aperio, cutoff, "Rater 1 Aperio vs. Rater 2 Aperio")
# kappa_total[[4]] <- MapKappa(willa_manual, willa_definiens, cutoff, "Rater 1 Manual vs. Rater 3 Definiens")
# kappa_total[[5]] <- MapKappa(tian_aperio, willa_definiens, cutoff, "Rater 1 Aperio vs. Rater 3 Definiens")
# kappa_total[[6]] <- MapKappa(willa_aperio, willa_definiens, cutoff, "Rater 2 Aperio vs. Rater 3 Definiens")
#
#
# kappa_table <- data.frame(do.call('rbind', lapply(kappa_total, function(x){
#     return(round(x$value, 3))
#   })))
#
# rowName <- lapply(kappa_total, function(x){
#     return(x$category[1])
#   })
# rownames(kappa_table) <- unlist(rowName)
# colnames(kappa_table) <- kappa_total[[1]]$x
# grid.table(kappa_table)
# dev.off()
#
# p <- ggplot(kappa_total, aes(x=x, y=value, group=category)) + geom_line(aes(color=category)) + geom_point() + expand_limits(y=c(-0.3, 0.8))
# print(p)
##########################################################################################
