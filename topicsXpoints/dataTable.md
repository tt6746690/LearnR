
Data Table
=========

An much more efficient alternative to data frame for large data sets.

`DT[i,j,by]` command has three parts: `i`, `j` and `by`. We talk about the command by saying “Take DT, subset the rows using ‘`i`’, then calculate ‘`j`’ grouped by ‘`by`’”.

![cheat sheet](https://raw.githubusercontent.com/tt6746690/LearnR/master/IMG/file-page1.jpg)


_example_
We subsetted the data table to keep only the rows of the 10th Month of the year, calculated the average AirTime of the planes that actually flew (that’s why na.omit() is used, cancelled flights don't have a value for their AirTime) and then grouped the results by their Carrier.

```r
library(hflights)
library(data.table)
DT &lt;- as.data.table(hflights)
DT[Month==10,mean(na.omit(AirTime)), by=UniqueCarrier]
UniqueCarrier V1
AA            68.76471
AS            255.29032
B6            176.93548
CO            141.52861
...


DT[2:5]
#selects the second to the fifth row of DT
Year Month DayofMonth DayOfWeek DepTime ArrTime UniqueCarrier FlightNum TailNum ActualElapsedTime AirTime
2011 1     2          7         1401    1501    AA            428       N557AA  60                45
2011 1     3          1         1352    1502    AA            428       N541AA  70                48
2011 1     4          2         1403    1513    AA            428       N403AA  70                39
2011 1     5          3         1405    1507    AA            428       N492AA  62                44
ArrDelay DepDelay Origin Dest Distance TaxiIn TaxiOut Cancelled CancellationCode Diverted
-9       1        IAH    DFW  224      6      9       0                          0
-8      -8        IAH    DFW  224      5      17      0                          0
 3       3        IAH    DFW  224      9      22      0                          0
-3       5        IAH    DFW  224      9      9       0                          0
```


Notice that you don’t have to use a comma for subsetting rows in a data table. In a data.frame doing this `DF[2:5]` would give all the rows of the 2nd to 5th __column__. Instead (as everyone reading this obviously knows), we have to specify `DF[2:5,]`. Also notice that `DT[,2:5]` does not mean anything for data tables. Quirky and useful: when subsetting rows you can also use the symbol `.N` in the `DT[…]` command, which is the __number of rows__ or the __last row__. You can use it for selecting the last row or an offset from it.


```r
DT[.N-1]
#Returns the penultimate row of DT
Year Month DayofMonth DayOfWeek DepTime ArrTime UniqueCarrier FlightNum TailNum ActualElapsedTime AirTime
2011 12    6          2         656     812     WN            621       N727SW  76                64
ArrDelay DepDelay Origin Dest Distance TaxiIn TaxiOut Cancelled CancellationCode Diverted
-13      -4       HOU    TUL  453      3      9       0                          0
```
