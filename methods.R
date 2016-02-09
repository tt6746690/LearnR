
library('data.table')
library('IDPmisc')
library('ggplot2')

load <- function(f_name){
  f <- read.table(f_name, header=TRUE, sep='\t', na.strings=c("NA", "Undetermined", ""))
  DT <- data.table(f)
  return(DT)
}


process <- function(DT, refGene, tarGene, CONTROL){

  DT <- DT[,.(Sample.Name, Detector.Name, Ct)]

  # taking the average of samples for reference and target gene
  refDT <- DT[Detector.Name == refGene, .(refCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]
  tarDT <- DT[Detector.Name == tarGene, .(tarCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]

  # merged DT
  DT <- merge(refDT, tarDT, by='Sample.Name')

  # trim NaN containing rows
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

  return(DT)
}
