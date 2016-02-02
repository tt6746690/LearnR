
# pre config
.First <- function(){
  print("\nWelcome at", date(), "\n")
  options(editor="atom")
}

# store the current directory
initial.dir <- getwd()

#change to new directory
setwd("C:/Users/PeiqiWang/Desktop")

# load libraries

# set output files
sink("output.txt")

# load the data sheet


#par(ask=TRUE)
#print('wtf')
#par(ask=FALSE)
