
library('data.table')
library('IDPmisc')
library('ggplot2')

load <- function(f_name){
  f <- read.table(f_name, header=TRUE, sep='\t', na.strings=c("NA", "Undetermined", ""))
  DT <- data.table(f)
  return(DT)
}

Test <- function(x, y){
  cat("=============================\n")
  cat(paste("T-test between", x, " and ", y, "\n"))
  cat("=============================\n")
  return(t.test(x,y))
}
plot4 <- function(b){


  df1 <- data.frame(a = c(1, 1:3,3), b = c(15, 15.5, 15.5, 15.5, 15))
  df2 <- data.frame(a = c(1, 1,2, 2), b = c(14, 14.5, 14.5, 14))

  #
  # pp + geom_line(data = df1, aes(x = a, y = b)) + annotate("text", x = 2, y = 42, label = "*", size = 8) +
      #  geom_line(data = df2, aes(x = a, y = b)) + annotate("text", x = 1.5, y = 38, label = "**", size = 8) +
      #  geom_line(data = df3, aes(x = a, y = b)) + annotate("text", x = 2.5, y = 27, label = "n.s.", size = 8)
  #
  p1 <- ggplot(b, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
  geom_line(data = df1, aes(x = a, y = b)) + annotate("text", x = 2, y = 16, label = "0.05", size = 5, family = "Helvetica", color="#666666") +
  geom_line(data = df2, aes(x = a, y = b)) + annotate("text", x = 1.5, y = 15, label = "0.0002", size = 5, family = "Helvetica", color="#666666") +
  scale_colour_gradient(low = "gray", high = "black") + geom_point(aes(color = fold)) +
  theme(plot.title = element_text(size = rel(1.0))) +
  theme(plot.title = element_text(vjust=1)) +
  theme(axis.title.y = element_text(size = 20, angle = 90, family = "Helvetica", color="#666666", hjust=0.5)) +
  theme(axis.text.x = element_text(size = 20, angle = 0, family = "Helvetica", color="#666666", vjust=0.5, hjust=0.5)) +
  theme(axis.title.x = element_blank()) +
  theme(legend.position = "none") +
  theme(plot.margin = unit(c(1,1,1,1), "cm")) +
  scale_x_discrete(labels = c("Normal", "DCIS", "IDC")) +
  scale_y_continuous("Relative Fold Difference\n", breaks = c(0, 1, 2, 4, 8, 16)) +
  labs(x = "\nCategory", y = "Relative Fold Difference\n")

  p2 <- ggplot(b, aes(x=category, y=ddCt)) + geom_boxplot() +  scale_fill_grey() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(-6, 4) +
  ggtitle('qPCR analysis of PITPNC1 in breast cancer patients')

  p3 <- ggplot(data=b, aes(x=ddCt, fill=category)) + geom_histogram(binwidth=0.2, color="grey") +
  xlab("ddCt") +  ylab("counts") + ggtitle("Histogram")

  p4 <- ggplot(data=b, aes(x=ddCt, fill=category)) +
  xlab("ddCt") +  ylab("counts") + ggtitle("Density plot") +
  geom_density(alpha=I(0.3))

  return(multiplot(p1, p2, cols=2))

}


plotEach <- function(b){

  df1 <- data.frame(a = c(1, 1:3,3), b = c(15, 15.5, 15.5, 15.5, 15))
  df2 <- data.frame(a = c(1, 1,2, 2), b = c(14, 14.5, 14.5, 14))

  print(ggplot(b, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
  geom_line(data = df1, aes(x = a, y = b)) + annotate("text", x = 2, y = 16, label = "0.05", size = 5, family = "Helvetica", color="#666666") +
  geom_line(data = df2, aes(x = a, y = b)) + annotate("text", x = 1.5, y = 15, label = "0.0002", size = 5, family = "Helvetica", color="#666666") +
  scale_colour_gradient(low = "gray", high = "black") + geom_point(aes(color = fold)) +
  theme(plot.title = element_text(size = rel(1.0))) +
  theme(plot.title = element_text(vjust=1)) +
  theme(axis.title.y = element_text(size = 20, angle = 90, family = "Helvetica", color="#666666", hjust=0.5)) +
  theme(axis.text.x = element_text(size = 20, angle = 0, family = "Helvetica", color="#666666", vjust=0.5, hjust=0.5)) +
  theme(axis.title.x = element_blank()) +
  theme(legend.position = "none") +
  theme(plot.margin = unit(c(1,1,1,1), "cm")) +
  scale_x_discrete(labels = c("Normal", "DCIS", "IDC")) +
  scale_y_continuous("Relative Fold Difference\n", breaks = c(0, 1, 2, 4, 8, 16)) +
  labs(x = "\nCategory", y = "Relative Fold Difference\n"))



  print(ggplot(b, aes(x=category, y=ddCt)) + geom_boxplot() +  scale_fill_grey() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(-6, 4) +
  ggtitle('qPCR analysis of PITPNC1 in breast cancer patients'))

  print(ggplot(data=b, aes(x=ddCt, fill=category)) + geom_histogram(binwidth=0.2, color="grey") +
  xlab("ddCt") +  ylab("counts") + ggtitle("Histogram"))

  print(ggplot(data=b, aes(x=ddCt, fill=category)) +
  xlab("ddCt") +  ylab("counts") + ggtitle("Density plot") +
  geom_density(alpha=I(0.3)))

}

process <- function(DT, refGene, tarGene, CONTROL){

  DT <- DT[,.(Sample.Name, Detector.Name, Ct)]

  # taking the average of samples for reference and target gene
  refDT <- DT[Detector.Name == refGene, .(refCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]
  tarDT <- DT[Detector.Name == tarGene, .(tarCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]

  # merged DT
  DT <- merge(refDT, tarDT, by='Sample.Name')

  # trim NaN containing rows (including NTC)
  oldrow = nrow(DT)
  DT <- DT[refCt != 'NaN' & tarCt != 'NaN',]
  if(oldrow != nrow(DT)){
    print(paste(oldrow, ' trimmed to ', nrow(DT), ' because they have empty Ct'))
  }

  # get the control Ct value for calculation of ddCt
  DT <- DT[,.(Sample.Name, refCt, tarCt, dCt=(tarCt-refCt))]
  controlCt <- DT[CONTROL,dCt]

  # table containing all revelant info
  DT <- DT[,.(Sample.Name, refCt, tarCt, dCt, ddCt=(dCt-controlCt))][,.(Sample.Name, refCt, tarCt, dCt, ddCt, fold=2^-ddCt)]

  return(DT[Sample.Name != CONTROL])  # remove control from the entry
}
