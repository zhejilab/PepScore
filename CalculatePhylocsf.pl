if ($#ARGV < 2) {
	print "perl CalculatePhylocsf.pl -f orfFile -p phylocsfDir -o outputFile"."\n";
	print "-f ORF structure in the genePred format;"."\n";
	print "-p the folder link containing phylocsf score files;"."\n";
	print "-o output file."."\n";
	exit;
}

use Getopt::Std;
use strict;
use warnings;
use List::Util qw(shuffle);

### get arguments ###
my %args; 
getopt("fpo",\%args);
my $orf=$args{f}; 
if (! $orf) {
	print "No ORF genepred file"."\n";
    exit;
}
my $scoredir=$args{p}; 
if (! $scoredir) {
	print "No phylocsf file directory"."\n";
    exit;
}

my $outfile=$args{o}; 
if (! $outfile) {
	print "No output file"."\n";
    exit;
}

open (IN, "$orf");
my %sel;
while (<IN>) {
	chomp;
	my @s1=split /\t/, $_;
	my @s2=split /,/, $s1[8];
	my @s3=split /,/, $s1[9];
	for (my $i=0; $i<=$#s2; $i++) {
		for (my $j=$s2[$i]; $j<$s3[$i]; $j++) {
			if ($j >=$s1[5] && $j < $s1[6]) {
				my $k=$s1[1].":".$s1[2].":".$j;
				$sel{$k}=1;
			}
		}
	}
}
close IN;

my @temp;
push @temp, glob "$scoredir/PhyloCSF+1.bedGraph";
push @temp, glob "$scoredir/PhyloCSF+2.bedGraph";
push @temp, glob "$scoredir/PhyloCSF+3.bedGraph";
push @temp, glob "$scoredir/PhyloCSF-1.bedGraph";
push @temp, glob "$scoredir/PhyloCSF-2.bedGraph";
push @temp, glob "$scoredir/PhyloCSF-3.bedGraph";
my %val;
foreach my $file (sort @temp) {
	open (IN, "$file");
	my @f=split /PhyloCSF/, $file;
	my $str=substr ($f[$#f], 0, 1);
	while (<IN>) {
		chomp;
		my @s=split /\t/, $_;
		my $k;
		if ($str eq '+') {
			$k=$s[0].":".$str.":".$s[1];
		} else {
			$k=$s[0].":".$str.":".($s[2]-1);
		}
		if (exists ($sel{$k})) {
			$val{$k}=$s[3];
		}
	}
	close IN;
}

open (IN, "$orf");
open (OUT, ">$outfile");
while (<IN>) {
	chomp;
	my @s1=split /\t/, $_;
	my @s2=split /,/, $s1[8];
	my @s3=split /,/, $s1[9];
	my @post;
	my @ind;
	for (my $i=0; $i<=$#s2; $i++) {
		for (my $j=$s2[$i]; $j<$s3[$i]; $j++) {
			if ($j >=$s1[5] && $j < $s1[6]) {
				push @post, $j;
				if ($s1[2] eq '+') {
					if ($j<($s3[$i]-2)) {
						push @ind, "1";
					} else {
						push @ind, "0";
					}
				} else {
					if ($j>($s2[$i]+1)) {
						push @ind, "1";
					} else {
						push @ind, "0";
					}
				}
			}
		}
	}
	if ($s1[2] eq '-') {
		@post=reverse(@post);
		@ind=reverse(@ind);
	}
	my $tot=0;
	my $num=0;
	for (my $i=0; $i<=$#post; $i+=3) {
		if ($ind[$i]==1) {
			my $k=$s1[1].":".$s1[2].":".$post[$i];
			$num++;
			$tot+=$val{$k};
		}
	}
	if ($num > 0) {
		print OUT $s1[0]."\t".($#post+1)."\t".$num."\t".sprintf("%.4f", $tot/$num)."\n";
	} else {
		print OUT $s1[0]."\t".($#post+1)."\t".$num."\t"."NA"."\n";
	}
}
close IN;
close OUT;
