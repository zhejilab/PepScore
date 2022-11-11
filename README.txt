PepScore Calculation 

Contact: Zhe Ji (zhe.ji@northwestern.edu)

The program is to calculate peptide functional probability based on encoding open reading frame (ORF) features. 

Requirements:
Perl program installation;
R program installation.

1. Calculate the false discovery rate (FDR) of ORF lengths considerating transcript lengths. 

usage: perl CalculateFDR.ORFlength.pl -g SequenceFile -t lengthsOfInterest -o outputDir -s startCodon
	-g SequenceFile: input the random sequence file in the fasta format
	-t lengthsOfInterest: Tab delimited text file with two columns. The first column shows the transcript length, and the second shows the ORF length (e.g. 1000	36)
	-o outputDir: output director
	-r repeat [optional]: the number of times generating random transcript sequences, default: 1000
	-s startCodon [optional]: start codon types, default: ATG
	-l orfLengthCutoff [optional]: cutoff of minimum candidate ORF length, default: 6

example command line: perl CalculateFDR.ORFlength.pl -g rand.genome.fa -t transcript.length.txt -o outputDir

2. Calculate the phyloCSF score of an ORF. 

usage: perl CalculatePhylocsf.pl -f orfFile -p phylocsfDir -o outputFile
	-f ORF structure in the genePred format;
	-p the folder link containing phylocsf score files;
	-o output file.

You can download the phyloCSF score files from the following website: https://data.broadinstitute.org/compbio1/PhyloCSFtracks/

3. Run "PepScore.R" to calculate PepScore. 
As shown in the example folder, the input file should contain the following minimum column information for each ORF in a row. 
len.fdr: the ORF length FDR calculated by "CalculateFDR.ORFlength.pl";
pfam: The Pfam prediction result (https://www.ebi.ac.uk/interpro/). 1: with a domain; 0: without a domain;
tmhmm: The TMHMM prediction result (https://services.healthtech.dtu.dk/service.php?TMHMM-2.0). 1: with a domain; 0: without a domain;
phylocsf: the averaged PhyloCSF score across the ORF region, which can be calculated by CalculatePhylocsf.pl;
orf.len: the ORF length. 

