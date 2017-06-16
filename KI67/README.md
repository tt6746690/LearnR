



## For Carrie 



+ __overview__
    + `./data/aperio`: contains data for rater 1 and 2 on aperio analysis
    + `./data/defiens`: contains data for reater 3 on defiens analysis
    + `./data/WILLA MANUAL.txt`; contains all data for rater 1 manual count
    + `./aperio.R` imports `.txt` data into R `data.table`, and do some initial cleaning
    + `./definiens.R` imports `.txt` data into R `data.table`, and do some initial cleaning
    + `./init.R`: contains call different methods to generate figures
    + `./sink`: contains output file


steps to analysis
1. install R and Rstudio on your computer
2. install libraries required (google `how to install library in Rstudio`) in `init.R`
3. copy-paste relevant data in similar format to `./data/definiens/TIAN TMA1 DEFINIENS.txt` and rename to new file
4. comment out the part in `init.R` with `shift-slash` if doesnt work google it
5. then in Rstudio, run `init.R` 
6. check the result in `./sink`
7. if error or doesnt work do a R tutorial and hack the code



[__Joining Data Tables__](https://rstudio-pubs-static.s3.amazonaws.com/52230_5ae0d25125b544caab32f75f0360e775.html)  

[__strsplit__](http://rfunction.com/archives/1499)
Split a character string or vector of character strings using a regular expression or a literal (fixed) string. The strsplit function outputs a list, where each list item corresponds to an element of x that has been split. In the simplest case, x is a single character string, and strsplit outputs a one-item list.

`strsplit(x, split, fixed=FALSE)`


[__trimws__](http://stat.ethz.ch/R-manual/R-patched/library/base/html/trimws.html)  
Remove leading and/or trailing whitespace from character strings.

`trimws(x, which = c("both", "left", "right"))`
