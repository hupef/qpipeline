

This page describes how to use **_qpipeline_** with **_PolyPhen2_** annotations for **_whole human exome sequence space ( WHESS )_** ( ftp://genetics.bwh.harvard.edu/pph2/whess/ )


Create a directory in *${QPIPELINE_HOME}/external_databases* to store PolyPhen2-WHESS database
```
mkdir cd ${QPIPELINE_HOME}/external_databases/PolyPhen2-WHESS

cd ${QPIPELINE_HOME}/external_databases/PolyPhen2-WHESS
```

Download PolyPhen2-WHESS ( note: this will take a while as PolyPhen2-WHESS is large )
```
wget --no-passive  ftp://genetics.bwh.harvard.edu/pph2/whess/polyphen-2.2.2-whess-2011_12.tab.tar.bz2
```

Uncompress the downloaded file ( note: this will take a while )
```
tar xvfj polyphen-2.2.2-whess-2011_12.tab.tar.bz2
```

There are two files associated with each transcript ( *features.tab and *scores.tab ) and they need to be combined to create the WHESS database.  Go into the extracted directory ( polyphen-2.2.2-whess-2011_12 ) and create a directory called 'database'

```
cd polyphen-2.2.2-whess-2011_12

mkdir database; cd database
```
Combine all the features.tab and scores.tab files in the extracted directory.  There is a total of ~45,000 transcripts so the instructions below need to be paralellized.   
```
# set the WHESS database file name
DB="polyphen-2.2.2-whess-2011_12"

# for each feature.tab file, combine with its score.tab file and save it as feature.tab.combined 
for i in `ls ../*features.tab`; do echo $i; N=`basename $i`; j=`echo $i | sed 's/features/scores/'`; paste  $i $j > ${N}.combined "; done

# for each combined file, convert it to VCF 
for i in `ls ../*combined`; do echo ; N=`basename $i`; perl ${QPIPELINE_HOME}/scripts/polyphen-whess_2_vcf.pl $i > ${N}.vcf ; done
```
Combine all the VCF files to create the PolyPhen2-WHESS database.  The instructions below do not need to be paralellized.
```
# DB is the name of the PolyPhen2-WHESS database to be created
DB="polyphen-2.2.2-whess-2011_11.vcf";

# take VCF header from the first file
i=`ls *.combined.vcf | head -1`;
cat $i | grep ^# > $DB

# combine all VCF files and sort base on chr and pos
cat *combined.vcf | grep -v ^# | sort -k1,1 -k2,2n >> $DB

# compress the newly created database using bgzip
bgzip ${DB}

# index the newly created database using tabix
tabix -p vcf ${DB}.gz
```
More to come shortly!

