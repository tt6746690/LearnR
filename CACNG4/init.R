library('cgdsr')
library('data.table')
library('abd')

pdf("./sink/CACNG4_metastasis_cor.pdf")
sink("./sink/CACNG4_metastasis_cor.txt")




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
cacng4_cna_data <- getProfileData(mycgds,c('TP53', 'CACNG4'),mygeneticprofile,mycaselist)

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
                                                              'AJCC.nodes.positive'=(substr(AJCC_NODES_PATHOLOGIC_PN, 1,2) != 'N0')
                                                              )]


# inner joining clinical data and cna data
cacng4_DT <- merge(cacng4_clinical_data_DT, cacng4_cna_data_DT, by='case')

# number of metastatic sites determined ---> 16/960
print(cacng4_DT[metastatic.site != '',])

print(cacng4_DT[high.amp == TRUE])  # 83/960 PITPNC1 is highly amplifieds

# chi squared test
tbl = table(cacng4_DT[,high.amp], cacng4_DT[,AJCC.nodes.positive])

rownames(tbl) <- c('cacng4 high amp false', 'cacng4 high amp true')
colnames(tbl) <- c('N0', 'N1, N2, or N3')

chisq.test(tbl)



# odds ratio: test effects of CACNG4 amplification on node metastasis positivity

# copy and paste..
mymatrix <- matrix(c(50, 33, 459, 418),nrow=2,byrow=TRUE)

calcOddsRatio <- function(mymatrix,alpha=0.05,referencerow=2,quiet=FALSE)
{
  numrow <- nrow(mymatrix)
  myrownames <- rownames(mymatrix)

  for (i in 1:numrow)
  {
     rowname <- myrownames[i]
     DiseaseUnexposed <- mymatrix[referencerow,1]
     ControlUnexposed <- mymatrix[referencerow,2]
     if (i != referencerow)
     {
        DiseaseExposed <- mymatrix[i,1]
        ControlExposed <- mymatrix[i,2]

        totExposed <- DiseaseExposed + ControlExposed
        totUnexposed <- DiseaseUnexposed + ControlUnexposed

        probDiseaseGivenExposed <- DiseaseExposed/totExposed
        probDiseaseGivenUnexposed <- DiseaseUnexposed/totUnexposed
        probControlGivenExposed <- ControlExposed/totExposed
        probControlGivenUnexposed <- ControlUnexposed/totUnexposed

        # calculate the odds ratio
        oddsRatio <- (probDiseaseGivenExposed*probControlGivenUnexposed)/
                     (probControlGivenExposed*probDiseaseGivenUnexposed)
        if (quiet == FALSE)
        {
           print(paste("category =", rowname, ", odds ratio = ",oddsRatio))
        }

        # calculate a confidence interval
        confidenceLevel <- (1 - alpha)*100
        sigma <- sqrt((1/DiseaseExposed)+(1/ControlExposed)+
                      (1/DiseaseUnexposed)+(1/ControlUnexposed))
        # sigma is the standard error of our estimate of the log of the odds ratio
        z <- qnorm(1-(alpha/2))
        lowervalue <- oddsRatio * exp(-z * sigma)
        uppervalue <- oddsRatio * exp( z * sigma)
        if (quiet == FALSE)
        {
           print(paste("category =", rowname, ", ", confidenceLevel,
              "% confidence interval = [",lowervalue,",",uppervalue,"]"))
        }
     }
  }
  if (quiet == TRUE && numrow == 2) # If there are just two treatments (exposed/nonexposed)
  {
     return(oddsRatio)
  }
}

# odds ratio =  1.37981118373275   95 % confidence interval = [ 0.871814227595667 , 2.18381260879923 ]
calcOddsRatio(mymatrix, alpha=0.05)




dev.off()
