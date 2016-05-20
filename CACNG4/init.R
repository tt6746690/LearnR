library('cgdsr')
library('data.table')
library('abd')
library('epitools')

# pdf("./sink/CACNG4_metastasis_cor.pdf")
# sink("./sink/CACNG4_metastasis_cor.txt")

# Create CGDS object
mycgds = CGDS("http://www.cbioportal.org/")
# Test the CGDS endpoint URL using a few simple API tests
# test(mycgds)
# Get list of cancer studies at server
getCancerStudies(mycgds)
# Get available case lists (collection of samples) for a given cancer study
mycancerstudy = getCancerStudies(mycgds)[20,1]   # number 20 is brca-tcga
print('a list of cancer stufies')
print(getCancerStudies(mycgds))
mycaselist = getCaseLists(mycgds,mycancerstudy)[1,1]


# Get available genetic profiles
mygeneticprofile = getGeneticProfiles(mycgds,mycancerstudy)[7,1]
print('a list of genetic profiles for the TCGA dataset')
print(getGeneticProfiles(mycgds,mycancerstudy))
# this gets the rna_seq_v2_mrna_median_Zscores
# change to [3, 1] to get brca_tcga_linear_CNA for copy number variation
# or to [7, 1] to get brca_tcga_gistic -> Putative copy-number alterations from GISTIC
	# Values: -2 = homozygous deletion;
	# -1 = hemizygous deletion;
	# 0 = neutral / no change;
	# 1 = gain;
	# 2 = high level amplification




# Get data slices for a specified list of genes, genetic profile and case list
cacng4_cna_data <- getProfileData(mycgds,c('TP53', 'CACNG4', 'PIK3CA'),mygeneticprofile,mycaselist)

# extract data frame row names and turn data frame to data table
cacng4_cna_data_DT <- data.table(cacng4_cna_data)[, ':='(
                                                    'case' = row.names(cacng4_cna_data),
                                                    'high.amp'=(CACNG4 == 2),
                                                    'gain'= (CACNG4 == 1 | CACNG4 == 2))]

# Get clinical data for the case list
cacng4_clinical_data <- getClinicalData(mycgds,mycaselist)
print('a list of clinical data fields available for TCGA dataset')
print(colnames(cacng4_clinical_data))


# extract useful clinical data fields
cacng4_clinical_data_DT <- data.table(cacng4_clinical_data)[, .(
                                                              'case' = row.names(cacng4_clinical_data),
                                                              'metastatic.site'=METASTATIC_SITE,
                                                              'mets.indicator'=METASTATIC_TUMOR_INDICATOR,
                                                              'AJCC.tumor.stage'=AJCC_PATHOLOGIC_TUMOR_STAGE,
                                                              'AJCC.metastasis'=AJCC_METASTASIS_PATHOLOGIC_PM,
                                                              'AJCC.nodes'=substr(AJCC_NODES_PATHOLOGIC_PN, 1,2),
                                                              'AJCC.nodes.positive'=(substr(AJCC_NODES_PATHOLOGIC_PN, 1,2) != 'N0'),
                                                              'days.to.death'= DAYS_TO_DEATH,
                                                              'her2.fish.status'=HER2_FISH_STATUS,
                                                              'tumor.status'=TUMOR_STATUS
                                                              )]


# inner joining clinical data and cna data
cacng4_DT <- merge(cacng4_clinical_data_DT, cacng4_cna_data_DT, by='case')


# ==== general stats ====
# number of metastatic sites determined ---> 16/960
print(cacng4_DT[metastatic.site != '',])
# number of highly amplified CACNG4 cases ---> 83/960
print(cacng4_DT[high.amp == TRUE])

# === exploratory tests =====
# on cacng4 high amp VS node metastasis
# chi squared test -->  X-squared = 1.5974, df = 1, p-value = 0.2063
node_met_tbl <- table(cacng4_DT[,high.amp], cacng4_DT[,AJCC.nodes.positive])
rownames(node_met_tbl) <- c('cacng4 high amp false', 'cacng4 high amp true')
colnames(node_met_tbl) <- c('N0', 'N1, N2, or N3')
chisq.test(node_met_tbl)
# odds ratio: test effects of CACNG4 amplification on node metastasis positivity.
mymatrix <- matrix(c(50, 33, 459, 418),nrow=2,byrow=TRUE)
# odds ratio =  1.37981118373275   95 % confidence interval = [ 0.871814227595667 , 2.18381260879923 ]
calcOddsRatio(mymatrix, alpha=0.05)

# on cacng4 high amp VS tumor stage
tumor_stg_tbl <- table(cacng4_clinical_data_DT[AJCC.tumor.stage != '',AJCC.tumor.stage], cacng4_DT[AJCC.tumor.stage != '',high.amp])
colnames(tumor_stg_tbl) <- c('cacng4 high amp false', 'cacng4 high amp true')
# prop.table(tumor_stg_tbl,2)
chisq.test(tumor_stg_tbl) # 0.015
oddsratio(tumor_stg_tbl,method = "fisher",conf.level = 0.95, rev="columns")

# on cacng4 high amp VS tumor stage grouped
mymatrix_cacng4 <- matrix(c(654, 216, 52, 30),ncol=2,byrow=TRUE)
rownames(mymatrix_cacng4) <- c('high amp false', 'high amp true')
colnames(mymatrix_cacng4) <- c('stage.1.2', 'stage.3.4.5')
tumor_stg_tbl_2 <- as.table(mymatrix_cacng4)
prop.table(tumor_stg_tbl_2,2)
chisq.test(tumor_stg_tbl_2)  # 0.03
oddsratio(tumor_stg_tbl_2,method = "fisher",conf.level = 0.95)
#  odds ratio with 95% CI is 1.745612 [1.046512 2.869566]
# means that odds of getting tumor stage 3,4,5 is 1.7X that of getting tumor stage 1,2
# under the condition that cacng4 is amplified


# on cacng4 gain VS tumor stage grouped
tumor_stg_tbl_gain <- table(cacng4_clinical_data_DT[AJCC.tumor.stage != '',AJCC.tumor.stage], cacng4_DT[AJCC.tumor.stage != '',gain])
colnames(tumor_stg_tbl_gain) <- c('cacng4 gain false', 'cacng4 gain true')
prop.table(tumor_stg_tbl_gain,2)
chisq.test(tumor_stg_tbl_gain) # p value = 0.4 not gonna work





################################################################################################
################################################################################################
################################################################################################
################################################################################################


#
#
# # Get data slices for a specified list of genes, genetic profile and case list
# tp53_cna_data <- getProfileData(mycgds,c('TP53', 'CACNG4'),mygeneticprofile,mycaselist)
#
# # extract data frame row names and turn data frame to data table
# tp53_cna_data_DT <- data.table(tp53_cna_data)[, ':='(
#                                                     'case' = row.names(tp53_cna_data),
#                                                     'homo.del'= (TP53 == -2),
#                                                     'del'= (TP53 == -1 | TP53 == -2))]
#
# # Get clinical data for the case list
# tp53_clinical_data <- getClinicalData(mycgds,mycaselist)
# print('a list of clinical data fields available for TCGA dataset')
# print(colnames(tp53_clinical_data))
#
#
# # extract useful clinical data fields
# tp53_clinical_data_DT <- data.table(tp53_clinical_data)[, .(
#                                                               'case' = row.names(tp53_clinical_data),
#                                                               'metastatic.site'=METASTATIC_SITE,
#                                                               'mets.indicator'=METASTATIC_TUMOR_INDICATOR,
#                                                               'AJCC.tumor.stage'=AJCC_PATHOLOGIC_TUMOR_STAGE,
#                                                               'AJCC.metastasis'=AJCC_METASTASIS_PATHOLOGIC_PM,
#                                                               'AJCC.nodes'=substr(AJCC_NODES_PATHOLOGIC_PN, 1,2),
#                                                               'AJCC.nodes.positive'=(substr(AJCC_NODES_PATHOLOGIC_PN, 1,2) != 'N0')
#                                                               )]
#
#
# # inner joining clinical data and cna data
# tp53_DT <- merge(tp53_clinical_data_DT, tp53_cna_data_DT, by='case')
#
#
# # ==== general stats ====
# # number of homozygous deletion tp53 cases ---> 13/960
# print(tp53_DT[homo.del == TRUE])
# # number of deletion tp53 cases ---> 591/960
# print(tp53_DT[del == TRUE])
#
# # === exploratory tests =====
# # chi squared test -->  X-squared = 1.5974, df = 1, p-value = 0.2063
# tp53_tbl = table(tp53_DT[,del], tp53_DT[,AJCC.nodes.positive])
# rownames(tp53_tbl) <- c('tp53 del false', 'tp53 del true')
# colnames(tp53_tbl) <- c('N0', 'N1, N2, or N3')
# chisq.test(tp53_tbl)
#
# # odds ratio: test effects of tp53 amplification on node metastasis positivity.
# mymatrix <- matrix(c(50, 33, 459, 418),nrow=2,byrow=TRUE)
# # odds ratio =  1.37981118373275   95 % confidence interval = [ 0.871814227595667 , 2.18381260879923 ]
# calcOddsRatio(mymatrix, alpha=0.05)
# dev.off()
