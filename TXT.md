

The following sections describe how to use **_qpipeline_** with input text (txt) files.  The examples below used data in **_${QPIPELINE_HOME}/test_data/bam_** folder.

---
## Selecting One or More Columns From A Text File
Sometimes it is handy to be able to select or delete one or more columns from a text file regardless of where the columns are in the file.   Using the Unix command:
```
cut -f N,M FILE | less
```
will work, however, if any columns in the input file changed or moved, then _N_ and/or _M_ needs to be updated accordingly.  Inspired by the SQL _select_ statement, **_qpipeline_** can be used to select or delete one or more columns from the input file regardless of where the columns are in the file.  For example, the following command is used select the two columns _input_file_ and _mean_coverage_ from the file _alignment.stats.txt_:
```
qpipeline txt  -m 1010 -i alignment.stats.txt -k input_file,mean_coverage | less
```
which produces the following output:
```
input_file      mean_coverage
10_P.bam        739.544
10_R.bam        718.379
11_P.bam        992.97
11_R.bam        2001.93
12_P.bam        3213.51
...
```

Another example is to select entries in the file _alignment.stats.txt_ where _mean_coveage_ is greater than 200.    This can be done easily as follows:
```
qpipeline txt  -m 1010 -i alignment.stats.txt -k "mean_coverage" -s 100 -A | less
```
where
* -s 100 means print only rows where value of mean_coverage is greater than 100
* -A indicates append all columns in the input file to the right of the selected column "mean_coverage"

---

Run **_qpipeline txt_** by itself to see other available commands and their usage.

