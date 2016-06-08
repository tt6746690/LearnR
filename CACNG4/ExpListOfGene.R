rm(list = ls())
library('cgdsr')  # https://cran.r-project.org/web/packages/cgdsr/cgdsr.pdf
library('ggplot2')
library('data.table')
library('survival')
library('GGally')
library('abd')
library('epitools')
source('util/methods.R')

options(scipen=4)
options(digits=3)

pdf("./sink/ExpListOfGene.pdf")
sink("./sink/ExpListOfGene.txt")

# Create CGDS object
mycgds = CGDS("http://www.cbioportal.org/")
# test(mycgds)
# Get list of cancer studies at server
getCancerStudies(mycgds)
# Get available case lists (collection of samples) for a given cancer study
mycancerstudy = getCancerStudies(mycgds)[20,1]   # number 20 is brca-tcga

mycaselist = getCaseLists(mycgds,mycancerstudy)[7,1]
# > getCaseLists(mycgds,mycancerstudy)$case_list_description
# [1] "All tumor samples that have mRNA, CNA and sequencing data (960 samples)"
# [2] "All tumor samples (1202 samples)"
# [3] "All (Next-Gen) sequenced samples (982 samples)"
# [4] "All tumors with CNA data (1080 samples)"
# [5] "All samples with methylation (HM27) data (343 samples)"
# [6] "All samples with methylation (HM450) data (885 samples)"
# [7] "All samples with mRNA expression data (1100 samples)"
# [8] "Tumors with reverse phase protein array (RPPA) data for about 200 antibodies (410 samples)"
# [9] "All tumor samples that have CNA and sequencing data (963 samples)"

# Get clinical data for the case list
clinData <- getClinicalData(mycgds,mycaselist)
# extract useful clinical data fields
clinDataRaw_DT <- data.table(clinData)[, .(
    'case' = row.names(clinData),
    AJCC_METASTASIS_PATHOLOGIC_PM, # 889 M0, 22M1, 161MX
    AJCC_NODES_PATHOLOGIC_PN,      # N0, N1, N2, N3, NX
    AJCC_PATHOLOGIC_TUMOR_STAGE,   # StageI to Stage X
    DAYS_TO_DEATH,                 # mean=1636days or 4.5yr  979NA's
    DAYS_TO_LAST_FOLLOWUP,         # mean=725.5days or 2yr   103NA's
    DFS_MONTHS,                    # mean=37.14 or 3.1yr     93NA's
    DFS_STATUS,                    # 877 DiseaseFree, 110 Recurred/Progressed
    OS_MONTHS,                     # mean=41 or 3.4yr       3NA's
    OS_STATUS,                     # 149 DECEASED 929 LIVING
    ER_STATUS_BY_IHC,              # 233 Negative and 795 Positive 48 not evaluated
    HER2_IHC_SCORE,                #      NA   0   1+  2+  3+
                                   #      473  60 265 195  87
    IHC_HER2,                      # 555 Positive 162 Negative
    MICROMET_DETECTION_BY_IHC,     # 456 NO and 256 YES
    PR_STATUS_BY_IHC               # 338 Negative 687 Positive
    )]
# summarizeDT(clinDataRaw_DT)
clinData_DT <- clinDataRaw_DT[, .(
    case,
    'metastasis'= lapply(AJCC_METASTASIS_PATHOLOGIC_PM, testClinAttr, falsePattern='M0'),
    'nodes'= lapply(AJCC_NODES_PATHOLOGIC_PN, testClinAttr, falsePattern='N0'),
    'stage'= AJCC_PATHOLOGIC_TUMOR_STAGE, #lapply(AJCC_PATHOLOGIC_TUMOR_STAGE, testStage),
    'ER'= lapply(ER_STATUS_BY_IHC, testClinAttr, falsePattern='Negative'),
    'HER2'= lapply(IHC_HER2, testClinAttr, falsePattern='Negative'),
    'PR'= lapply(PR_STATUS_BY_IHC, testClinAttr, falsePattern='Negative'),
    'micromets'= lapply(MICROMET_DETECTION_BY_IHC, testClinAttr, falsePattern='NO')
    )]
# clinData_DT <- clinDataRaw_DT[, .(
#     case,
#     'metastasis'= AJCC_METASTASIS_PATHOLOGIC_PM,
#     'nodes'= substr(AJCC_NODES_PATHOLOGIC_PN, 1,2),
#     'stage'= AJCC_PATHOLOGIC_TUMOR_STAGE, #lapply(AJCC_PATHOLOGIC_TUMOR_STAGE, testStage),
#     'ER'= ER_STATUS_BY_IHC,
#     'HER2'= IHC_HER2,
#     'PR'= PR_STATUS_BY_IHC,
#     'micromets'= MICROMET_DETECTION_BY_IHC
#     )]

# Get available genetic profiles
mygeneticprofile <- getGeneticProfiles(mycgds,mycancerstudy)[4,1]
# > getGeneticProfiles(mycgds,mycancerstudy)$genetic_profile_description
#  [1] "Methylation (HM450) beta-values for genes in 885 cases. For genes with multiple methylation probes, the probe most anti-correlated with expression."
#  [2] "Methylation (HM27) beta-values for genes in 343 cases. For genes with multiple methylation probes, the probe most anti-correlated with expression."
#  [3] "Relative linear copy-number values for each gene (from Affymetrix SNP6)."
#  [4] "mRNA z-Scores (RNA Seq V2 RSEM) compared to the expression distribution of each gene tumors that are diploid for this gene."
#  [5] "Expression levels for 20532 genes in 1212 brca cases (RNA Seq V2 RSEM)."  not normalized
#  [6] "mRNA z-Scores (Agilent microarray) compared to the expression distribution of each gene tumors that are diploid for this gene."
#  [7] "Putative copy-number calls on 1080 cases determined using GISTIC 2.0. Values: -2 = homozygous deletion; -1 = hemizygous deletion; 0 = neutral / no change; 1 = gain; 2 = high level amplification."
#  [8] "Protein expression, measured by reverse-phase protein array, Z-scores"
#  [9] "Protein or phosphoprotein level (Z-scores) measured by reverse phase protein array (RPPA)"
# [10] "Protein expression measured by reverse-phase protein array"
# [11] "Mutation data from whole exome sequencing."
# [12] "Expression levels for 17155 genes in 590 brca cases (Agilent microarray)."


# Get genetic profile
listOfGenes <- c('CACNG4', 'GNA13', 'SPAG5', 'SRSF7', 'CHD1', 'TP53', 'TBX2', 'RAD51C')
expData <- getProfileData(mycgds, listOfGenes, mygeneticprofile,mycaselist)

# > lapply(expData, function(x) return(summary(x)))
# $CACNG4
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -1.04   -0.78   -0.20    0.33    0.80   24.10
#
# $CHD1
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -1.20   -0.58   -0.27   -0.06    0.18   14.40
#
# $COIL
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -3.15   -0.71    0.22    0.87    1.60   29.20
#
# $GNA13
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -2.46   -0.57    0.20    0.57    1.15   18.80
#
# $PITPNC1
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#    -1.6    -0.6    -0.1     0.3     0.7    46.4
#
# $RAD51C
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -2.15   -0.55    0.02    0.49    0.98   22.50
#
# $SRSF7
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -2.29   -0.67   -0.14    0.05    0.59    6.22
#
# $TBX2
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#   -0.80   -0.42   -0.21    0.00    0.17   18.50
#
# $WIPI1
#    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
#    -1.9    -0.7    -0.1     0.2     0.6    42.2

expData_DT <- data.table(expData)[, ':='(
    'case' = row.names(expData)
    )]


# inner joining clinical data and mRNA expression data
DT <- merge(clinData_DT, expData_DT, by='case')
genes <- list(CACNG4 = DT$CACNG4,
              GNA13 = DT$GNA13,
              RAD51C = DT$RAD51C,
              SPAG5 = DT$SPAG5,
              SRSF7 = DT$SRSF7,
              CHD1 = DT$CHD1,
              TP53 = DT$TP53,
              TBX2 = DT$TBX2)
# UNLIST is very important to enable sort.list (when constructing table), have to convert list -> atomic
clinAttr <- list(metastasis = unlist(DT$metastasis),
                 nodes = unlist(DT$nodes),
                 stage = unlist(DT$stage),
                 ER = unlist(DT$ER),
                 HER2 = unlist(DT$HER2),
                 PR = unlist(DT$PR),
                 micromets = unlist(DT$micromets)
                 )


rlist <- lapply(genes, function(gene){
  plots <- lapply(clinAttr, function(clin){
      dtbl <- data.table(
        gene = gene,
        clinVar = clin
      )
      dtbl <- dtbl[!is.na(clinVar) & clinVar != '',][gene<quantile(dtbl$gene, 0.95)]
      # boxplot(gene ~ clinVar , data = dtbl, ylab = "expresion z score") #, outline=FALSE)
      print(summary(lm(gene ~ clinVar, data = dtbl)))
      print(ggplot(dtbl, aes(clinVar, gene)) + geom_point(size = 0.05) + geom_boxplot() + geom_jitter(width=0.25))
    })
  # multiplot(plotlist = plots[1:2], cols = 2)
  # multiplot(plotlist = plots[3:4], cols = 2)
  # multiplot(plotlist = plots[5:6], cols = 2)
  # multiplot(plotlist = plots[7], cols = 2)
})
#
# chisqdf <- data.frame(matrix(unlist(chisqlist), ncol=length(clinAttr), byrow=TRUE))
# colnames(chisqdf) <- names(clinAttr)
# rownames(chisqdf) <- names(genes)
#
# print(chisqdf)


dev.off()
