
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

  p1 <- ggplot(b, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(0,20) +
  ggtitle('qPCR analysis of PITPNC1 in breast cancer patients')

  p3 <- ggplot(b, aes(x=category, y=ddCt)) + geom_boxplot() +  scale_fill_grey() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(-6, 4) +
  ggtitle('qPCR analysis of PITPNC1 in breast cancer patients')

  p2 <- ggplot(data=b, aes(x=ddCt, fill=category)) + geom_histogram(binwidth=0.2, color="grey") +
  xlab("ddCt") +  ylab("counts") + ggtitle("Histogram")

  p4 <- ggplot(data=b, aes(x=ddCt, fill=category)) +
  xlab("ddCt") +  ylab("counts") + ggtitle("Density plot") +
  geom_density(alpha=I(0.3))

  return(multiplot(p1, p2, p3, p4, cols=2))

}


plotEach <- function(b){

  print(ggplot(b, aes(x=category, y=fold)) + geom_boxplot() +  scale_fill_grey() +
  geom_jitter(shape=16, position=position_jitter(0.2)) + ylim(0,20) +
  ggtitle('qPCR analysis of PITPNC1 in breast cancer patients'))

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
