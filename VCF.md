
The following sections describe how to use **_qpipeline_** with input VCF files:

* [Annotate an input VCF file against a BED database file](ANNOTATE_VCF_WITH_BED.md)
* [Annotate an input VCF file against a VCF database file](ANNOTATE_VCF_WITH_VCF.md)

---
## Other miscellaneous commands ( examples below used data in **_${QPIPELINE_HOME}/test_data/vcf_** folder )

* parse an attribute from the INFO column.  For example, VC (Variant Class)
```
 qpipeline vcf -m 1500 -i common_all_20161122.vcf -k VC= 
```

* parse an attribute from the FORMAT column: 
```
 qpipeline vcf -m 1600 -i 
```

Run **_qpipeline vcf_** by itself to see other available commands and their usage.

---
