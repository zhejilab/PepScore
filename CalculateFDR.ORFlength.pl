if ($#ARGV < 2) {
	print "usage: perl CalculateFDR.ORFlength.pl -g SequenceFile -t lengthsOfInterest -o outputDir -s startCodon "."\n";
	print "-g SequenceFile: input the random sequence file in the fasta format;"."\n";
	print "-t translen: tab delimited text file with two columns. The first column shows the transcript length, and the second shows the ORF length (e.g. 1000	36)"."\n";
	print "-o outputDir: output director;"."\n";
	print "-r repeat [optional]: 1000"."\n";
	print "-s startCodon [optional]: start codon types, default: ATG"."\n";
	print "-l orfLengthCutoff [optional]: cutoff of minimum candidate ORF length, default: 6."."\n";
	exit;
}

use Getopt::Std;
use strict;
use warnings;
use List::Util qw(shuffle);

### get arguments ###
my %args; 
getopt("gtorsl",\%args);
my $ranseq=$args{g}; 
if (! $ranseq) {
	print "No random sequence file"."\n";
    exit;
}
my $translen=$args{t}; 
if (! $translen) {
	print "No transcript length file"."\n";
    exit;
}
my $outdir=$args{o}; 
if (! $outdir) {
	print "No output dir"."\n";
    exit;
}
my $scodon=$args{s}; 
my $lenoff=$args{l};
my $rtime=$args{r};

($scodon="ATG") if (!$scodon); # or ATG/CTG/GTG/TTG/ACG
($lenoff=6) if (! $lenoff);
($rtime=1000) if (! $rtime);

my @s=split /\//, $scodon;
my %sc;
for (my $i=0; $i<=$#s; $i++) {
	$sc{$s[$i]}=1;
}

### random sequence file
my $seq;
open (SE, "$ranseq");
while (<SE>) {
	chomp;
	if ($_ !~ /^>/) {
		my $a1=uc($_);
		$a1 =~ s/N//g;
		$seq.=$a1;
	}
}
close SE;

sub shuffle_str {
    my @ch = split //, shift;
    join '', shuffle(@ch[0 .. $#ch]);
}

my $seq2;
for (my $n=0; $n < 10; $n++) {
	$seq2.=shuffle_str ($seq);
}

### output candidate ORF
open (IN, "$translen");
#open (OUT1, ">$outdir/rand.len.txt");
open (OUT2, ">$outdir/rand.sta.txt");
my $line;
while (<IN>) {
	chomp;
	my @s=split /\t/, $_;
	my $len=$s[0];
 	if ($len < 200) {
  		$len=200;
	}
	my $pl=$s[1];
	my $n1=0;
	my $n2=0;
	for (my $n=0; $n<$rtime; $n++) {
		my $loc1 = int(rand(length($seq2)-$len-1));
		my $out.=substr($seq2, $loc1, $len);
		my $ra=0;
		my $ind=0;
		for (my $i=0; $i<=($len-2); $i++) {
			my $b=substr ($out, $i, 3);
			if (exists ($sc{$b})) {
				my $ind=0; 
				for (my $j=($i+3); $j<=$len && $ind==0; $j+=3) {
					my $d1=substr ($out, $j, 3);
					if ($d1 eq 'TAG' || $d1 eq 'TAA' || $d1 eq 'TGA') {
						my $sub = $j-$i+3;
						$ra++;
						$ind=1;
						#print OUT1 $len."\t".$ra."\t".$sub."\n";		
						if ($sub >= $pl) {
							$n1++;
						} else {
							$n2++;
						}
					}
				}
			}
		}
		if ($ind==0) {
			#print OUT1 $len."\t".$ra."\t"."0"."\n";		
			$n2++;
		}
	}
	print OUT2 $_."\t".$n1."\t".($n1+$n2)."\t".sprintf("%.5f", $n1/($n1+$n2))."\n";
}
close IN;
#close OUT1;
close OUT2;
