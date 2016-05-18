


f_name <- "BIOGRID-ALL-3.4.136.mitab.txt"
f <- read.table(f_name, header=TRUE, sep='\t', na.strings=c("NA", "Undetermined", ""))
print(f)
