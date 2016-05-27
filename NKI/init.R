rm(list=ls())
library('ggplot2')
library('data.table')
library('Biobase')
library('breastCancerNKI')


# sinks
# pdf("./sink/genesTMAanalysis.pdf")
# sink("./sink/NKIanalysis.txt", split=TRUE)

options(digits=3)

# nki_chang_Path= file.path(getwd(), 'data', 'NKI_complete_concatenated.txt')
# DT <- data.table(read.table(nki_chang_Path, header=TRUE, sep = "\t",
#        na.strings=c("NA", "N/A", "", "N"), stringsAsFactors=FALSE, strip.white=TRUE))
data(nki)
dim(exprs(nki))  # 24481 features and 337 samples


dim(pData(nki))  # 337 samples  21 clinVars
# > names(pData(nki))
#  [1] "samplename"    "dataset"       "series"        "id"
#  [5] "filename"      "size"          "age"           "er"
#  [9] "grade"         "pgr"           "her2"          "brca.mutation"
# [13] "e.dmfs"        "t.dmfs"        "node"          "t.rfs"
# [17] "e.rfs"         "treatment"     "tissue"        "t.os"
# [21] "e.os"
all(rownames(pData(nki))==colnames(exprs(nki)))

metadata <- data.frame(labelDescription=
  c("sample name",
    "NKI",
    "NKI",
    "ID in sample name",
    "file name mostly NA",
    "size of tumour in mm",
    "age of biopsy",
    "ER score",
    "tumor grade",
    "progesterone score",
    "her2 score",
    "presence of brca mutation",
    "same as e.rfs",
    "same as t.rfs",
    "node metastasis",  # 144 samples with node metastasis as 1
    "relapse free survival time",
    "dunno what e.rfs means",
    "number of treatment received",
    "all of the samples are derived from tissue so = 1",
    "overall survival time",
    "dunno what e.os mean"),
  row.names=c("samplename", "dataset", "series", 'id', 'filename', 'size', 'age', 'er', 'grade', 'pgr', 'her2', 'brca.mutation', 'e.dmfs', 't.dmfs', 'node', 't.rfs', 'e.rfs', 'treatment', 'tissue', 't.os', 'e.os'))

phenoData <- new("AnnotatedDataFrame", data=pData(nki), varMetadata=metadata)
annotation <- new("AnnotatedDataFrame", data=fData(nki))

Set <- ExpressionSet(assayData=exprs(nki), phenoData=phenoData, annotation=annotation)
# dev.off()
