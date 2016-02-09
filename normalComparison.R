
library('data.table')
library('IDPmisc')
library('ggplot2')
# https://rpubs.com/davoodastaraky/dataTable



# declare variables
refGene = 'B2m'
tarGene = 'PITPNC1'
CONTROL = 'N1 SCOMP'

# load the data sheet
f <- read.table("2016 02 05 CONTROLS ALL nonamp wga scomp.txt", header=TRUE, sep='\t', na.strings=c("NA", "Undetermined", ""))
DT <- data.table(f)

DT <- DT[,.(Sample.Name, Detector.Name, Ct)]    # DT[row, col]  select/create columns by .()
# If you supply a j expression and a by list of expressions, the j expression is repeated for each by group.

# taking the average of samples for reference and target gene
refDT <- DT[Detector.Name == refGene, .(refCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]
tarDT <- DT[Detector.Name == tarGene, .(tarCt=mean(Ct, na.rm=TRUE)), by=Sample.Name]

# merged DT
DT <- merge(refDT, tarDT, by='Sample.Name')

# trim NaN containing rows
print(paste('verify that number of samples are: ', nrow(DT)))
DT <- DT[refCt != 'NaN' & tarCt != 'NaN',]
print(paste('after omitting NaN containfing rows number of samples remaining: ', nrow(DT)))

# get the control Ct value for calculation of ddCt
DT <- DT[,.(Sample.Name, refCt, tarCt, dCt=(tarCt-refCt))]
controlCt <- DT[CONTROL,dCt]

# table containing all revelant info
DT <- DT[,.(Sample.Name, refCt, tarCt, dCt, ddCt=(dCt-controlCt))][,.(Sample.Name, refCt, tarCt, dCt, ddCt, fold=2^-ddCt)]


DT_NON <- DT[grep('WGA|SCOMP', Sample.Name, invert=TRUE)]
DT_WGA <- DT[grep('WGA', Sample.Name)]
DT_SCOMP <- DT[grep('SCOMP', Sample.Name)]
# compare unamplified, WGA, and SCOMP
if(sum(nrow(DT_NON), nrow(DT_WGA), nrow(DT_SCOMP)) != nrow(DT)){
    print('some exceptions in separating to different categories')
}


par(mfrow = c(1,2))
boxplot(DT_NON$ddCt, DT_WGA$ddCt, DT_SCOMP$ddCt,xlab='Amplification methods', ylab='ddCt',
names = c('Nonamplified', 'WGA', 'SCOMP'), title='normal breast tissue ddCt vs amplification methods boxplot')

boxplot(DT_NON$fold, DT_WGA$fold, DT_SCOMP$fold,xlab='Amplification methods', ylab='fold difference',
names = c('Nonamplified', 'WGA', 'SCOMP'), title='normal breast tissue fold difference vs amplification methods boxplot')

print(DT_NON)
print(DT_WGA)
print(DT_SCOMP)




#refG = subset(f, f$Detector.Name == refGene, select = c(Sample.Name, Ct))
#tarG = subset(f, f$Detector.Name == tarGene, select = c(Sample.Name, Ct))
