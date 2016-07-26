

# # sinks
# pdf("./sink/TMA_manualVSAperio.pdf")
# sink("./sink/TMA_manualVSAperio.txt")

options(digits=3)

# manual scoring block #1-6
Manual_Scoring_path = file.path(getwd(), 'data', 'WILLA MANUAL.txt')
ManScoringDT <- data.table(read.table(Manual_Scoring_path, header=TRUE, sep = "\t",
                 na.strings=c("NA", "Undetermined", ""), stringsAsFactors=FALSE))

# aperio blocks # 2-6 tian
A_TMA2_TIAN_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA2 APERIO.txt')
A_TMA3_TIAN_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA3 APERIO.txt')
A_TMA4_TIAN_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA4 APERIO.txt')
A_TMA5_TIAN_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA5 APERIO.txt')
A_TMA6_TIAN_path = file.path(getwd(), 'data', 'aperio', 'TIAN TMA6 APERIO.txt')


A_TMA2_TIAN_DT <- data.table(read.table(A_TMA2_TIAN_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'tian_aperio_2']
A_TMA3_TIAN_DT <- data.table(read.table(A_TMA3_TIAN_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'tian_aperio_3']
A_TMA4_TIAN_DT <- data.table(read.table(A_TMA4_TIAN_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'tian_aperio_4']
A_TMA5_TIAN_DT <- data.table(read.table(A_TMA5_TIAN_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'tian_aperio_5']
A_TMA6_TIAN_DT <- data.table(read.table(A_TMA6_TIAN_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'tian_aperio_6']

# aperio block # 1-5 willa
A_TMA1_WILLA_path = file.path(getwd(), 'data', 'aperio', 'WILLA TMA1 APERIO.txt')
A_TMA1_WILLA_DT= data.table(read.table(A_TMA1_WILLA_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'willa_aperio_1']
A_TMA2_WILLA_path = file.path(getwd(), 'data', 'aperio', 'WILLA TMA2 APERIO.txt')
A_TMA2_WILLA_DT= data.table(read.table(A_TMA2_WILLA_path, header=TRUE, sep = "\t",
                na.strings=c(""), stringsAsFactors=FALSE))[,block := 'willa_aperio_2']
A_TMA3_WILLA_path = file.path(getwd(), 'data', 'aperio', 'WILLA TMA3 APERIO.txt')
A_TMA3_WILLA_DT= data.table(read.table(A_TMA3_WILLA_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'willa_aperio_3']
A_TMA4_WILLA_path = file.path(getwd(), 'data', 'aperio', 'WILLA TMA4 APERIO.txt')
A_TMA4_WILLA_DT= data.table(read.table(A_TMA4_WILLA_path, header=TRUE, sep = "\t",
                na.strings=c(""), stringsAsFactors=FALSE))[,block := 'willa_aperio_4']
A_TMA5_WILLA_path = file.path(getwd(), 'data', 'aperio', 'WILLA TMA5 APERIO.txt')
A_TMA5_WILLA_DT= data.table(read.table(A_TMA5_WILLA_path, header=TRUE, sep = "\t",
                 na.strings=c(""), stringsAsFactors=FALSE))[,block := 'willa_aperio_5']


##### processing

# BOTH list container data table having 'case' and score as column names
tian_v1 = list(tian_tma1 = A_TMA6_TIAN_DT,
                tian_tma2 = A_TMA2_TIAN_DT,
                tian_tma3 = A_TMA3_TIAN_DT,
                tian_tma4 = A_TMA4_TIAN_DT,
                tian_tma5 = A_TMA5_TIAN_DT)
A_TMA_WILLA_LIST = list(willa_tma1 = A_TMA1_WILLA_DT,
                        willa_tma2 = A_TMA2_WILLA_DT,
                        willa_tma3 = A_TMA3_WILLA_DT,
                        willa_tma4 = A_TMA4_WILLA_DT,
                        willa_tma5 = A_TMA5_WILLA_DT)
willa_v1 <- lapply(A_TMA_WILLA_LIST, initialProcessAperio)


tian_aperio <- do.call("rbind", tian_v1)
tian_aperio <<- tian_aperio[,category := 'rater2_aperio']#[,log2_score := log2(score + 0.1)]

willa_aperio <- do.call("rbind", willa_v1)
willa_aperio <<- willa_aperio[,category := 'rater1_aperio']#[,log2_score := log2(score + 0.1)]

willa_manual <<- ManScoringDT[,category := 'rater1_manual'][,block := 'willa_manual_1']#[,log2_score := log2(score + 0.1)]


# print(tian_aperio)
# print(tian_v1)

# print(willa_v1)

# lapply(willa_v1, generateStatistics, manual_DT=ManScoringDT)






#
# A_TMA_list <- list(willa_tma5 = A_TMA5_WILLA_DT,
#                    tian_tma2=A_TMA2_TIAN_DT,
#                    tian_tma3=A_TMA3_TIAN_DT,
#                    tian_tma4=A_TMA4_TIAN_DT,
#                    tian_tma5=A_TMA5_TIAN_DT,
#                    tian_tma6=A_TMA6_TIAN_DT)
#
#
#
# print(A_TMA5_WILLA_DT)
#
#
# lapply(A_TMA_list, generateStatistics, manual_DT=ManScoringDT)
# # dev.off()
