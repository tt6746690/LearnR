#### The Root: What's A Data Frame?
R's data frames offer you a great first step by allowing you to store your data in overviewable, rectangular grids. Each row of these grids corresponds to measurements or values of an instance, while each column is a vector containing data for a specific variable. This means that a data frame's __rows__ do not need to contain, but can contain, the same type of values: they can be numeric, character, logical, etc.; As you can see in the data frame below, each instance, listed in the first unnamed column with a number, has certain characteristics that are spread out over the remaining three columns. Each __column__ needs to consist of values of the same type, since they are __data vectors__: as such, the breaks column only contains numerical values, while the wool and tension columns have characters as values that are stored as factors.

```r
head(warpbreaks)
##   breaks wool tension
## 1     26    A       L
## 2     30    A       L
## 3     54    A       L
## 4     25    A       L
## 5     70    A       L
## 6     52    A       L
```


__Create Data Frame__

```r
Died.At <- c(22,40,72,41)
Writer.At <- c(16, 18, 36, 36)
First.Name <- I(c("John", "Edgar", "Walt", "Jane"))     # I() insulate variable, component
                                                        # stored as character rather than factor
Second.Name <- I(c("Doe", "Poe", "Whitman", "Austen"))
Sex <- c("MALE", "MALE", "MALE", "FEMALE")              # factor: since only limited number of possibilities
Date.Of.Death <- as.Date(c("2015-05-10", "1849-10-07", "1892-03-26","1817-07-18"))  # as.Data()

# combine vectors
writers_df <- data.frame(Died.At, Writer.At, First.Name, Second.Name, Sex, Date.Of.Death)
```

```r
str(writers_df)     # summary
## 'data.frame':    4 obs. of  6 variables:
##  $ Died.At      : num  22 40 72 41
##  $ Writer.At    : num  16 18 36 36
##  $ First.Name   : Factor w/ 4 levels "Edgar","Jane",..: 3 1 4 2
##  $ Second.Name  : Factor w/ 4 levels "Austen","Doe",..: 2 3 4 1
##  $ Sex          : Factor w/ 2 levels "FEMALE","MALE": 2 2 2 1
##  $ Date.Of.Death: Factor w/ 4 levels "1817-07-18","1849-10-07",..: 4 2 3 1
```


__Changerow and column names__

Retrieve names with `names()` function

```r
names(writers_df)
## [1] "Died.At"       "Writer.At"     "First.Name"    "Second.Name"
## [5] "Sex"           "Date.Of.Death"
```

To change names, make sure that the number of arguments in the c() function is equal to the number of variables of data frame.

```r
names(writers_df) <- c("Age.At.Death", "Age.As.Writer", "Name", "Surname", "Gender", "Death")
names(writers_df)
## [1] "Age.At.Death"  "Age.As.Writer" "Name"          "Surname"
## [5] "Gender"        "Death"
```

Can also change row names and column names with `colnames` and `rownames`

__Check dimensions__
As you know, the data frame is similar to a matrix, which means that its size is determined by how many rows and columns you have combined into it.

```r
dim(writers_df)
## [1] 4 6

dim(writers_df)[1] #Number of rows
dim(writers_df)[2] #Number of columns

# equivalent to
nrow(writers_df)
ncol(writers_df)

#retrieve number of rows with length
length(writers_df)
```

__Access and change values__

```r
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 1           22            16  John     Doe   MALE 2015-05-10
## 2           40            18 Edgar     Poe   MALE 1849-10-07
## 3           72            36  Walt Whitman   MALE 1892-03-26
## 4           41            36  Jane  Austen FEMALE 1817-07-18
```

_via [,] and $_

```r
writers_df [1:2,3] #Value located on the first and second row, third column
## [1] "John"  "Edgar"

writers_df[, 3] #Values located in the third column
## [1] "John"  "Edgar" "Walt"  "Jane"

writers_df[3,] #Values located in the third row
##   Age.At.Death Age.As.Writer Name Surname Gender      Death
## 3           72            36 Walt Whitman   MALE 1892-03-26
```

```r
writers_df$Age.At.Death
## [1] 22 40 72 41

writers_df$Age.At.Death[3] #Value located on third row of the column `Age.At.Death`
## [1] 72
```

+ change columns/rows

```r
writers_df$Age.At.Death <- writers_df$Age.At.Death-1
writers_df[,1] <- writers_df$Age.At.Death-1
```

+ change single cell

```r
writers_df[1,3] = "Jane"
writers_df[1,5] = "FEMALE"
```

__Attach data frames__

```r
# R search order
search()
##  [1] ".GlobalEnv"         "package:knitr"      "package:RWordPress"
##  [4] "package:REmails"    "package:RJSONIO"    "package:httr"
##  [7] "writers_df"         "env:itools"         "package:data.table"
## [10] "package:RDatabases" "package:RMySQL"     "package:DBI"
## [13] "package:yaml"       "package:dplyr"      "tools:rstudio"
## [16] "package:stats"      "package:graphics"   "package:grDevices"
## [19] "package:utils"      "package:datasets"   "package:methods"
## [22] "Autoloads"          "package:base"
```

The `attach()` function offers a solution to this: it takes a data frame as an argument and places it in the search path at position 2. So unless there are variables in position 1 that are exactly the same as the ones from the data frame you have inputted, the variables from your data frame are considered as variables that can be immediately called on.

```r
attach(writers_df)
## The following objects are masked _by_ .GlobalEnv:
##
##     Age.As.Writer, Age.At.Death, Death, Gender, Name, Surname

#alternatively use with()
with(writers_df, c("Age.At.Death", "Age.As.Writer", "Name", "Surname", "Gender", "Death"))
## [1] "Age.At.Death"  "Age.As.Writer" "Name"          "Surname"
## [5] "Gender"        "Death"

# Now
Age.At.Death
## [1] 22 40 72 41
Age.At.Death <- Age.At.Death-1
Age.At.Death
```

__note__: If you get an error that tells you that “The following objects are masked by .GlobalEnv:”, this is because you have objects in your global environment that have the same name as your data frame.


__Apply functions__

To get the mean and median, use `apply()` function. The first argument of this function should be your data frame. The second argument designates what data you want to consider for the calculations of the mean or median: columns or rows. In this case, we want to calculate the median and mean of the variables `Age.At.Death` and `Age.As.Writer`, which designate columns in the data frame. The last argument then specifies the exact calculations that you want to do on your data:

```r
# to calculate stuff, might want to put numeric data in a separate data frame
Ages <- writers_df[,1:2]

apply(Ages, 2, median)      # 2 >>> as columns
##  Age.At.Death Age.As.Writer
##          40.5          27.0

apply(Ages,1,median)        # 1 >>> as rows
## [1] 19.0 29.0 54.0 38.5

apply(Ages, 2, mean)
##  Age.At.Death Age.As.Writer

##         43.75         26.50
```

__Create An Empty Data Frame__

```r
ab <- data.frame()
ab
## data frame with 0 columns and 0 rows
```

__Subsetting__
Subsetting or extracting specific rows and columns from a data frame is an important skill in order to surpass the basics that have been introduced in step two, because it allows you to easily manipulate smaller sets of your original data frame.

```r
writer_names_df <- writers_df[1:4, 3:4]
# equivalent to
writer_names_df <- writers_df[1:4, c("Name", "Surname")]

writer_names_df
##    Name Surname
## 1  Jane     Doe
## 2 Edgar     Poe
## 3  Walt Whitman
## 4  Jane  Austen
```

`subset()`  can be used to satisfy a condition or to extract a single value

```r
writer_names_df <- subset(writers_df, Age.At.Death <= 40 & Age.As.Writer >= 18)
writer_names_df
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 2           40            18 Edgar     Poe   MALE 1849-10-07

writer_names_df <- subset(writers_df, Name =="Jane")
writer_names_df
##   Age.At.Death Age.As.Writer Name Surname Gender      Death
## 1           22            16 Jane     Doe FEMALE 2015-05-10
## 4           41            36 Jane  Austen FEMALE 1817-07-18
```

More often, `grep()` will enhance the search!

```r
# find rows in the column Age.At.Death that have values that contain “4”
fourty_writers <- writers_df[grep("4", writers_df$Age.At.Death),]
fourty_writers
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 2           40            18 Edgar     Poe   MALE 1849-10-07
## 4           41            36  Jane  Austen FEMALE 1817-07-18
```

Creation of a subset of only `MALE` does not erase factor `FEMALE` from the vector

```r
male_writers <- writers_df[Gender =="MALE",]
str(male_writers)
## 'data.frame':    0 obs. of  6 variables:
##  $ Age.At.Death : num
##  $ Age.As.Writer: num
##  $ Name         :Class 'AsIs'  chr(0)
##  $ Surname      :Class 'AsIs'  chr(0)
##  $ Gender       : Factor w/ 2 levels "FEMALE","MALE":
##  $ Death        :Class 'Date'  num(0)
```

__Remove Columns And Rows__
To remove values or columns, simply assign `NULL`

```r
writers_df[1,3] <- NULL
Age.At.Death <- NULL
```

To remove rows, define a new vector in which you list for every row whether to have it included or not. Then, you apply this vector to your data frame

```r
rows_to_keep <- c(TRUE, FALSE, TRUE, FALSE)
limited_writers_df <- writers_df[rows_to_keep,]
limited_writers_df
##   Age.At.Death Age.As.Writer Name Surname Gender      Death
## 1           22            16 Jane     Doe FEMALE 2015-05-10
## 3           72            36 Walt Whitman   MALE 1892-03-26

# OR A SIMPLER METHOD (use negation)
less_writers_df <- writers_df[!rows_to_keep,]
less_writers_df
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 2           40            18 Edgar     Poe   MALE 1849-10-07
## 4           41            36  Jane  Austen FEMALE 1817-07-18

# Assign threshold to evaluate and include rows accordingly
fourty_sth_writers <- writers_df[writers_df$Age.At.Death > 40,]
fourty_sth_writers
##   Age.At.Death Age.As.Writer Name Surname Gender      Death
## 3           72            36 Walt Whitman   MALE 1892-03-26
## 4           41            36 Jane  Austen FEMALE 1817-07-18
```


__Adding rows and columns__

_add columns_ using `$` or `[]` notation

```r
# Location is a NEW column
writers_df$Location <- c("Belgium", "United Kingdom", "United States", "United Kingdom")
```

_add rows_ using `rbind`

```
new_row <- c(50, 22, "Roberto", "Bolano", "MALE", "2003-07-15")
writers_df_large <- rbind(writers_df, new_row)
```

__Reshaping between wide and long format__

When you have multiple values, spread out over multiple columns, for the same instance, your data is in the __wide__ format. On the other hand, when your data is in the __long__ format if there is one observation row per variable. You therefore have __multiple rows per instance__. Since different functions may require you to input your data either in “long” or “wide” format, you might need to reshape your data set.


```r
Subject <- c(1,2,1,2,2,1)
Gender <- c("M", "F", "M", "F", "F","M")
Test <- c("Read", "Write", "Write", "Listen", "Read", "Listen")
Result <- c(10, 4, 8, 6, 7, 7)
observations_long <- data.frame(Subject, Gender, Test, Result)
observations_long
##   Subject Gender   Test Result
## 1       1      M   Read     10
## 2       2      F  Write      4
## 3       1      M  Write      8
## 4       2      F Listen      6
## 5       2      F   Read      7
## 6       1      M Listen      7

Subject <- c(1,2)
Gender <- c("M", "F")
Read <- c(10, 7)
Write <-c(8, 4)
Listen <- c(7, 6)
observations_wide <- data.frame(Subject, Gender, Read, Write, Listen)
observations_wide
##   Subject Gender Read Write Listen
## 1       1      M   10     8      7
## 2       2      F    7     4      6
```

__Using `Stack()` to restructure simple data frames__
`stack()` basically concatenates or combines multiple vectors into a single vector, along with a factor that indicates where each observation originates from. To go from wide to long format, you will have to stack your observations, since you want one observation row per variable, with multiple rows per variable. To go from long to wide format, you will need to unstack your data, which makes sense because you want to have one row per instance with each value present as a different variable.

```r
# WIDE >>> LONG
long_format <- stack(observations_wide,
                     select=c(Read,
                              Write,
                              Listen))
long_format
##   values    ind
## 1     10   Read
## 2      7   Read
## 3      8  Write
## 4      4  Write
## 5      7 Listen
## 6      6 Listen


# LONG >>> WIDE
wide_format <- unstack(observations_long,
                       Result ~ Test)
wide_format
##   Listen Read Write
## 1      6   10     4
## 2      7    7     8
```

__Reshaping Data Frames With `tidyr`__
This package allows you to “easily tidy data with the `spread()` and `gather()` functions” and that's exactly what you're going to do if you use this package to reshape your data!

`gather()` - from wide to long  
1. Your data set is the first argument to the `gather()` function   
2. Then, you specify the __name__ of the _column_ in which you will combine the the values of Read, Write and Listen. In this case, you want to call it something like Test or Test.Type.   
3. You enter the name of the column in which all the __values__ of the Read, Write and Listen columns are listed.   
4. You indicate which columns are supposed to be combined into one. In this case, that will be the columns from Read, to Listen.

```r
library(tidyr)
long_tidyr <- gather(observations_wide,
                     Test,
                     Result,
                     Read:Listen)
#equivalent to
long_tidyr <- gather(observations_wide,
                     Test,
                     Result,
                     Read,
                     Write,
                     Listen)

long_tidyr
##     Subject Gender   Test Result
## 1       1      M   Read     10
## 2       2      F   Read      7
## 3       1      M  Write      8
## 4       2      F  Write      4
## 5       1      M Listen      7
## 6       2      F Listen      6
```

`spread()` long >> wide  

```r
library(tidyr)
wide_tidyr <- spread(observations_long,
                     Test,
                     Result)
wide_tidyr
##    Subject Gender Listen Read Write
## 1       1      M      7   10     8
## 2       2      F      6    7     4
```

__Sorting__

_R built-in `Order()`_

```r
# order the rows of the data frame according to Age.As.Writer
writers_df[order(writers_df$Age.As.Writer),]
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 1           22            16  Jane     Doe FEMALE 2015-05-10
## 2           40            18 Edgar     Poe   MALE 1849-10-07
## 3           72            36  Walt Whitman   MALE 1892-03-26
## 4           41            36  Jane  Austen FEMALE 1817-07-18
```

If want to sort the values starting from high to low, just add the extra argument `decreasing`, which can only take logical values. Another way is to add the function `rev()` so that it includes the `order()` function. You can also add a `-` in front of the numeric variable that you have given to order on.

```r
writers_df[order(writers_df$Age.As.Writer, decreasing=TRUE),]
writers_df[rev(order(writers_df$Age.As.Writer)),]
writers_df[order(-writers_df$Age.As.Writer),]
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death
## 3           72            36  Walt Whitman   MALE 1892-03-26
## 4           41            36  Jane  Austen FEMALE 1817-07-18
## 2           40            18 Edgar     Poe   MALE 1849-10-07
## 1           22            16  Jane     Doe FEMALE 2015-05-10
```

__Merging Data Frames On Column Names__
You can use the `merge()` function to join two, but only two, data frames.

Let's say we have a data frame data2, which has the __same values__ stored in a variable Age.At.Death, which we __also find in__ writers_df, with exactly the same values. You thus want to merge the two data frames _on the basis of_ this variable:

```r
data2 <- data.frame(Age.At.Death=c(22,40,72,41), Location=5:8)
new_writers_df <- merge(writers_df, data2)
new_writers_df
##   Age.At.Death Age.As.Writer  Name Surname Gender      Death Location
## 1           22            16  Jane     Doe FEMALE 2015-05-10        5
## 2           40            18 Edgar     Poe   MALE 1849-10-07        6
## 3           41            36  Jane  Austen FEMALE 1817-07-18        8
## 4           72            36  Walt Whitman   MALE 1892-03-26        7
```

In many cases, some of the columns names or variable values will differ, which makes it hard to follow the easy, standard procedure that was described just now.

__What If… (Some Of) The Data Frame's Column Values Are Different?__

You see that the values for the attribute `Age.At.Death` in `data2` do not fit with the ones that were defined for the `writers_df` data frame. `merge()` function provides extra arguments to solve this problem. The argument `all.x` allows you to specify to add the extra rows of the `Location` variable to the resulting data frame, _even though this column is not present in `writers_df`_. In this case, the values of the `Location` variable will be added to the `writers_df` data frame __IFF__ rows of which the values of the `Age.At.Death` attribute correspond. All rows where the `Age.At.Death` of the two data frames don't correspond, will be filled up with `NA` values

```r
data2 <- data.frame(x.Age.At.Death=c(21,39,71,40), Location=5:8)
merge(writers_df, data2, all.x=FALSE)

# if you want to add extra rows for each row that data2 has no matching row in writers_df
merge(writers_df, data2, all.y=TRUE)
```
