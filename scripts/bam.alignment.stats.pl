#!/usr/bin/perl
use strict;
use warnings;

# sub routine for reading data generated by samtools flag 
sub read_SAMTOOLS_flagstat {
	my $inputFile = shift;
	my $numberOfReads=0;
	my $numberOfReadsAligned=0;
	open(STATS, $inputFile) or die("Could not open  file.");

	my $lineCount = 0; 
	foreach my $line (<STATS>)  {   
		$lineCount++;
		if ($lineCount == 1) {
			my @fields = split (' ', $line);
			$numberOfReads = $fields[0];
		}
		if ($lineCount == 3) {
			my @fields = split (' ', $line);
			$numberOfReadsAligned = $fields[0];
		}
	}
	close(STATS);
	my $p =  $numberOfReadsAligned / $numberOfReads * 100;
	return ($numberOfReads, $numberOfReadsAligned, $p );
}


# we need 3 arguments:  BAM file, BED file, and output file 
if ( @ARGV != 3 ) {
   print "\n";
   print "\nGenerate BAM alignment stats:\n\tnumber of reads\n\tnumber of reads aligned to reference genome\n\tpercent of reads aligned to reference genome\n\tnumber of reads aligned to target (if target file provided )\n\tpercent of reads aligned to target\n\tpercent of bases on target at 1x or higher\n\tpercent of bases on target at 25x or higher\n\tpercent of bases on target at 50x or higher";
   print "\n\nusage: perl " . $0 . " [ BAM_FILE ] [ ZIPPED_BED_FILE ] [ OUTPUT_FILE ]";
   print "\n\n\tBED_FILE\t3 column target file (chr, start, end ).  Use 'NULL' if there are no target file";
   print "\n\n";
   exit (0);
}

my ($BAM_FILE, $TARGET_FILE, $OUTPUT_FILE) = @ARGV;


# we need the following tools to run the this script 
my $tool_names = "samtools,bedtools,qpipeline";  # simple example
my @tools = split /,/, $tool_names;
my $tool_path = '';

# for each tools, check to make sure they are on the path, 
# if not, exit and inform user to install 
foreach my $t (@tools) {
	my $foundTools = 0;
	for my $path ( split /:/, $ENV{PATH} ) {
		 if ( -f "$path/$t" && -x _ ) {
				$foundTools = 1;
			  last;
		}
	}
	# if any one of the above tools is not found, exit and give error
	if ($foundTools == 0) {
		print "\n\n'$t' not found.  Please install and add '$t' your path and try again!\n\n";
		exit (1);
	}
}


my $numberOfReads=0;
my $numberOfReadsAligned=0;
my $percentOfReadsAligned=0;

my $tmp;

my $meanCoverage = 0;
my $targetSize = 0;
my $xCoverage1 = 0;
my $xCoverage25 = 0;
my $xCoverage50 = 0;
print "\ngetting samtools flagstat ... ";
system "samtools flagstat $BAM_FILE  > $OUTPUT_FILE.flagstat";
( $numberOfReads, $numberOfReadsAligned, $percentOfReadsAligned) = read_SAMTOOLS_flagstat("$OUTPUT_FILE.flagstat");


my $numberOfReadsTarget=0;
my $numberOfReadsAlignedTarget=0;
my $percentOfReadsAlignedTarget=0;
if ($TARGET_FILE ne "NULL") {
	print "\ngetting samtools target ... ";
	system "samtools view -L $TARGET_FILE $BAM_FILE -b | samtools flagstat /dev/stdin > $OUTPUT_FILE.flagstat.target" ;
	( $numberOfReadsTarget, $numberOfReadsAlignedTarget, $percentOfReadsAlignedTarget) = read_SAMTOOLS_flagstat("$OUTPUT_FILE.flagstat.target");
	$percentOfReadsAlignedTarget = $numberOfReadsAlignedTarget /  $numberOfReads * 100;


	print "\ngetting bedtools coverage ... ";
	system "bedtools coverage -abam $BAM_FILE -b $TARGET_FILE -hist | grep ^all > $OUTPUT_FILE.coverage" ;
	
	# mean coverage 
	$meanCoverage = `cat $OUTPUT_FILE.coverage | awk '{ t += \$2*\$3 } END { print t/\$4 }'`;
	chomp($meanCoverage);

	print "\nfilling out gaps in coverage ... ";
	system "qpipeline bedtools -m 1001 -i $OUTPUT_FILE.coverage > $OUTPUT_FILE.coverage.qpipeline" ;

	# get xcoverage for 1x 
	$tmp = `cat $OUTPUT_FILE.coverage.qpipeline | awk '\$2==1'`;
	chomp($tmp);
	my @fields = split ('\t', $tmp);
	$targetSize = $fields[3];
	$xCoverage1 = ($fields[5]);
	
	# get xcoverage for 25x 
	$tmp = `cat $OUTPUT_FILE.coverage.qpipeline | awk '\$2==25'`;
	chomp($tmp);
	@fields = split ('\t', $tmp);
	$xCoverage25 = ($fields[5]);

	# get xcoverage for 50x
	$tmp = `cat $OUTPUT_FILE.coverage.qpipeline | awk '\$2==50'`;
	chomp($tmp);
	@fields = split ('\t', $tmp);
	$xCoverage50 = ($fields[5]);
	
}

open(my $fh, '>', $OUTPUT_FILE) or die "Could not open file '$OUTPUT_FILE' $!";

print $fh "input_file";
print $fh "\ttotal_number_of_reads";
print $fh "\tnumber_of_reads_aligned_to_hg19";
print $fh "\tpercent_of_reads_aligned_to_hg19";
print $fh "\tnumber_of_reads_aligned_to_target";
print $fh "\tpercent_of_reads_aligned_to_target";
print $fh "\ttarget_size";
print $fh "\tmean_coverage";
print $fh "\t1x_or_higher";
print $fh "\t25x_or_higher";
print $fh "\t50x_or_higher";
print $fh "\n$BAM_FILE";
print $fh "\t$numberOfReads\t$numberOfReadsAligned";
printf $fh "\t%.2f", $percentOfReadsAligned;
print $fh "\t$numberOfReadsAlignedTarget";
printf $fh "\t%.2f", $percentOfReadsAlignedTarget;
print $fh "\t$targetSize";
print $fh "\t$meanCoverage";
printf $fh "\t%.2f", $xCoverage1;
printf $fh "\t%.2f",$xCoverage25;
printf $fh "\t%.2f",$xCoverage50;
printf $fh "\n";
close $fh;

# cleaning up temporary and intermediate files 
system "rm $OUTPUT_FILE.* ";
print "\n";

exit (0);
