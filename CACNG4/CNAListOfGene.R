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

pdf("./sink/CNAListOfGene.pdf")
sink("./sink/CNAListOfGene.txt")

# Create CGDS object
mycgds = CGDS("http://www.cbioportal.org/")
# test(mycgds)
# Get list of cancer studies at server
getCancerStudies(mycgds)
# Get available case lists (collection of samples) for a given cancer study
mycancerstudy = getCancerStudies(mycgds)[20,1]   # number 20 is brca-tcga

mycaselist = getCaseLists(mycgds,mycancerstudy)[2,1]
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

# Get available genetic profiles
mygeneticprofile <- getGeneticProfiles(mycgds,mycancerstudy)[7,1]
# > getGeneticProfiles(mycgds,mycancerstudy)$genetic_profile_description
#  [1] "Methylation (HM450) beta-values for genes in 885 cases. For genes with multiple methylation probes, the probe most anti-correlated with expression."
#  [2] "Methylation (HM27) beta-values for genes in 343 cases. For genes with multiple methylation probes, the probe most anti-correlated with expression."
#  [3] "Relative linear copy-number values for each gene (from Affymetrix SNP6)."
#  [4] "mRNA z-Scores (RNA Seq V2 RSEM) compared to the expression distribution of each gene tumors that are diploid for this gene."
#  [5] "Expression levels for 20532 genes in 1212 brca cases (RNA Seq V2 RSEM)."
#  [6] "mRNA z-Scores (Agilent microarray) compared to the expression distribution of each gene tumors that are diploid for this gene."
#  [7] "Putative copy-number calls on 1080 cases determined using GISTIC 2.0. Values: -2 = homozygous deletion; -1 = hemizygous deletion; 0 = neutral / no change; 1 = gain; 2 = high level amplification."
#  [8] "Protein expression, measured by reverse-phase protein array, Z-scores"
#  [9] "Protein or phosphoprotein level (Z-scores) measured by reverse phase protein array (RPPA)"
# [10] "Protein expression measured by reverse-phase protein array"
# [11] "Mutation data from whole exome sequencing."
# [12] "Expression levels for 17155 genes in 590 brca cases (Agilent microarray)."


# Get genetic profile
listOfGenes <- c('CACNG4', 'GNA13', 'WIPI1', 'SRSF7', 'CHD1', 'PITPNC1', 'TBX2', 'RAD51C', 'COIL')
cnaData <- getProfileData(mycgds, listOfGenes, mygeneticprofile,mycaselist)

# > lapply(cnaData, function(x) return(summary(factor(x))))
# $CACNG4
#  -1   0   1   2
# 141 510 335  94
#
# $CHD1
#  -2  -1   0   1   2
#   9 270 603 196   2
#
# $GNA13
#  -1   0   1   2
# 153 512 333  82
#
# $RAD51C
#  -2  -1   0   1   2
#   2 177 515 297  89
#
# $SPAG5
#  -2  -1   0   1   2
#   3 268 522 236  51
#
# $SRSF7
#  -2  -1   0   1   2
#   2 173 741 154  10
#
# $TBX2
#  -2  -1   0   1   2
#   1 152 505 316 106
#
# $TP53
#  -2  -1   0   1   2
#  14 643 368  54   1

cnaData_DT <- data.table(cnaData)[, ':='(
    'case' = row.names(cnaData),
    # true -> hypothesized disease associated CNA
    'CACNG4' = (CACNG4 == 2),    # CACNG4 is a potental oncogene
    'GNA13' = (GNA13 == 2),      # GNA13 is a potential ooncogene
    'RAD51C' = (RAD51C == -2 | RAD51C == -1),    # RAD51C mutation related to cancer
    'WIPI1' = (WIPI1 == -2 | WIPI1 == -1),  # WIPI1 is a tumor suppressor
    'COIL' = (COIL == 2),
    'SRSF7' = (SRSF7 == 2 | SRSF7 == 1),# SFRS7 mutation may be related to cancer
    'CHD1' = (CHD1 == -2 | CHD1 == -1),       # CHD1 is a tumor suppressor
    'PITPNC1' = (PITPNC1 == 2),       # PITPNC1 is a potential oncogene
    'TBX2' = (TBX2 == 2)        # TBX2 is a tumor suppressor But many gained.
    )]

# > summary(cnaData_DT)
#    CACNG4           CHD1           GNA13           RAD51C
#  Mode :logical   Mode :logical   Mode :logical   Mode :logical
#  FALSE:986       FALSE:801       FALSE:998       FALSE:991
#  TRUE :94        TRUE :279       TRUE :82        TRUE :89
#  NA's :0         NA's :0         NA's :0         NA's :0
#    SPAG5           SRSF7            TBX2            TP53
#  Mode :logical   Mode :logical   Mode :logical   Mode :logical
#  FALSE:1029      FALSE:916       FALSE:974       FALSE:423
#  TRUE :51        TRUE :164       TRUE :106       TRUE :657
#  NA's :0         NA's :0         NA's :0         NA's :0

# inner joining clinical data and cna data
DT <- merge(clinData_DT, cnaData_DT, by='case')
# case metastasis nodes     stage ER HER2 PR micromets CACNG4
# 1: TCGA.3C.AAAU.01         NA    NA           NA   NA NA        NA  FALSE
# 2: TCGA.3C.AALI.01          0     1  Stage II  1    1  1        NA   TRUE
# 3: TCGA.3C.AALJ.01          0     1  Stage II  1    1  1        NA   TRUE
# 4: TCGA.3C.AALK.01          0     0   Stage I  1    1  1         1   TRUE
# 5: TCGA.4H.AAAK.01          0     1 Stage III  1    1  1         0  FALSE
# ---
# 1076: TCGA.WT.AB44.01          1     0   Stage I  1    0  1        NA  FALSE
# 1077: TCGA.XX.A899.01          1     1 Stage III  1    0  1         0  FALSE
# 1078: TCGA.XX.A89A.01          1     0  Stage II  1    0  1        NA  FALSE
# 1079: TCGA.Z7.A8R5.01          1     1 Stage III  1    0  1         1  FALSE
# 1080: TCGA.Z7.A8R6.01          0     0   Stage I  1    0  1         1  FALSE
# CHD1 GNA13 RAD51C SPAG5 SRSF7  TBX2  TP53
# 1: FALSE FALSE  FALSE FALSE FALSE FALSE  TRUE
# 2:  TRUE  TRUE   TRUE  TRUE  TRUE FALSE  TRUE
# 3: FALSE FALSE   TRUE  TRUE  TRUE  TRUE  TRUE
# 4: FALSE  TRUE   TRUE FALSE FALSE  TRUE  TRUE
# 5: FALSE FALSE  FALSE FALSE FALSE FALSE  TRUE
# ---
# 1076: FALSE FALSE  FALSE FALSE FALSE FALSE  TRUE
# 1077: FALSE FALSE  FALSE FALSE FALSE FALSE FALSE
# 1078: FALSE FALSE  FALSE FALSE FALSE FALSE  TRUE
# 1079: FALSE FALSE  FALSE FALSE FALSE FALSE FALSE
# 1080: FALSE FALSE  FALSE FALSE FALSE FALSE  TRUE


genes <- list(CACNG4 = DT$CACNG4,
              GNA13 = DT$GNA13,
              RAD51C = DT$RAD51C,
              COIL = DT$COIL,
              WIPI1 = DT$WIPI1,
              SRSF7 = DT$SRSF7,
              CHD1 = DT$CHD1,
              PITPNC1 = DT$PITPNC1,
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

chisqlist <- lapply(genes, function(gene){
  lapply(clinAttr, function(clin){
      dtbl <- data.table(
        gene = gene,
        clinVar = clin
      )[!is.na(clinVar) & clinVar != '',]
      tbl <- table(gene = dtbl$gene, clinVar = dtbl$clinVar)
      print(tbl)
      return(chisq.test(tbl)$p.value)
    })
})

chisqdf <- data.frame(matrix(unlist(chisqlist), ncol=length(clinAttr), byrow=TRUE))
colnames(chisqdf) <- names(clinAttr)
rownames(chisqdf) <- names(genes)

print(chisqdf)


fishlist <- lapply(genes, function(gene){
  lapply(clinAttr, function(clin){
      dtbl <- data.table(
        gene = gene,
        clinVar = clin
      )[!is.na(clinVar) & clinVar != '',]
      tbl <- table(gene = dtbl$gene, clinVar = dtbl$clinVar)
      return(fisher.test(tbl, simulate.p.value=TRUE)$p.value)
    })
})

fishdf <- data.frame(matrix(unlist(fishlist), ncol=length(clinAttr), byrow=TRUE))
colnames(fishdf) <- names(clinAttr)
rownames(fishdf) <- names(genes)


print(fishdf)
dev.off()
