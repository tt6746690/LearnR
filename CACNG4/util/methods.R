

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

summarizeDT <- function(DT){
  lapply(DT, function(x) {
      if (is.numeric(x)) return(summary(x))
      if (is.character(x)) return(table(x))
      if (is.logical(x)) return(table(x))
  })
}




testClinAttr <- function(x, falsePattern) {
  if(grepl(falsePattern, x)) {
    return(FALSE)}
  else if (x == ''|| is.na(x)) {
    return(NA)}
  else {
    return(TRUE)}
}


testStage <- function(x){
  if(grepl('II|X|IV', x)){
    return(TRUE)
  }
  else if (x == ''|| is.na(x)){
    return(NA)
  }
  else{
    return(FALSE)
  }
}


# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}
