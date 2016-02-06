
# store the current directory
initial.dir <- getwd()

#change to new directory
setwd("C:/Users/PeiqiWang/Desktop/Learning R/kickstartingR")


# === GETTING DATA IN/OUT ===
y<-c(1,2,3,4,5)   # assign vector of values to y
                  # c is the 'combine' function
print(y)
names<-c("Abe","Bob","Con")     # c also combines character strings into vectors or lists into list of list
print(names)


f <- read.table("foo.txt", head=T, sep=' ')   # use comma as deliminators. "\t" or " " is also available options
#  header header2 header3
# 1 1 2 3
# 2 2 3 4

f2 <- data.frame(scan("foo.txt",list(0,0,0),skip=1))
# scan() reads each line of the file from left to right. the data is read into a matrix
# DEFAULT: the first line of the file is assigned to first column of the matrix
# In this case, scan() reads columns of the file and separate them into separate vectors
# where "" specifies string and 0 specifies integer.  skip=1 skips the first row
names(f2)<-c("header1", "header2", "header3")
# names() is a function used to get or set the names of an object.
      # names(x)          where x is an R object
      # names(x) <- value

# In summary, data frame is used for storing data tables === a list of vectors of equal length
list1 = c(2, 3, 5)
list2 = c("aa", "bb", "cc")
list3 = c(TRUE, FALSE, TRUE)
df = data.frame(list1, list2, list3)       # df is a data frame
print(df)

mtcars      # mtcars is a build in data frame: first line is header, following rows are data row
            # each data member of a row is called a CELL
            # retrieve data with row and column n a square bracket []
print(mtcars[1, 2])
# [1] 6
print(mtcars["Mazda RX4", "cyl"] )    # use row and column names instead of numeric coordinates
# [1] 6
print(nrow(mtcars))       # number of data rows
# [1] 32
print(ncol(mtcars))       # number of data columns
# [1] 11


# === MASSAGING DATA IN R ===
# extraction of a single value from a matrix or array of m dimensions
# append [] to the name of the object with m integers representing coordinates separated by commas
print(f[1,2])
# [1] 2
print(f[2,2])
# [1] 3





# load the data sheet
