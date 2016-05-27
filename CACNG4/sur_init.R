library('ggplot2')
library('data.table')
library('survival')
library('GGally')

# source('./util/methods.R')

# setwd("C:/Users/PeiqiWang/Documents/GitHub/LearningR/CACNG4")
# source('init.R')

# sinks
pdf("./sink/TCGA_CACNG4_KPplot.pdf")
sink("./sink/TCGA_CACNG4_KPpplot.txt")

# for total TCGA BRCA clinical dataset, not useful in this one gene but..
#wget https://tcga-data.nci.nih.gov/tcgafiles/ftp_auth/distro_ftpusers/anonymous/tumor/brca/bcr/biotab/clin/nationwidechildrens.org_clinical_patient_brca.txt


BRCA_CACNG4_path = file.path(getwd(), 'data', 'CACNG4_TCGA_Survival.txt')
BRCA_CACNG4_woalt_path = file.path(getwd(), 'data', 'CACNG4_TCGA_withoutalteration.txt')
CACNG4_altered_DT <- data.table(read.table(BRCA_CACNG4_path, as.is = TRUE, sep = "\t", header = TRUE))[, CACNG4 := 'altered']
CACNG4_woalteration_DT <- data.table(read.table(BRCA_CACNG4_woalt_path, as.is = TRUE, sep = "\t", header = TRUE))[, CACNG4 := 'unaltered']

CACNG4_surv_DT = rbind(CACNG4_altered_DT, CACNG4_woalteration_DT)

tem <- CACNG4_surv_DT$Status == "deceased"
CACNG4_surv_DT[, Status := tem]


sf.cacng4 <- survival::survfit(Surv(Time, Status) ~ CACNG4, data = CACNG4_surv_DT)
pl.cacng4 <- ggsurv(sf.cacng4, surv.col = c('#ff7171', '#949494'), cens.col='#c7c7c7', cens.shape=3, back.white=FALSE, xlab='Time (Month)', ylab='Survival') + theme(legend.position="none")
print(pl.cacng4)

dev.off()
