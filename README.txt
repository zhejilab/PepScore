PepScore Calculation 

Contact: Zhe Ji (zhe.ji@northwestern.edu)

The program is to calculate peptide functional probability based on encoding open reading frame (ORF) features. 

1. Calculate the false discovery rates (FDRs) of ORF lengths considerating their transcript lengths. 

usage: perl CalculateFDR.ORFlength.pl -g SequenceFile -t lengthsOfInterest -o outputDir -s startCodon
	-g SequenceFile: input the random sequence file in the fasta format
	-t translen: transcript lengths of interest with column information. The first column represents the transcript length, and the second presents the ORF length
	-o outputDir: output director
	-r repeat [optional]: 1000
	-s startCodon [optional]: start codon types, default: ATG
	-l orfLengthCutoff [optional]: cutoff of minimum candidate ORF length, default: 6

example command line: perl CalculateFDR.ORFlength.pl -g GRCh38.p13.genome.fa -t transcript.length.txt -o outputDir

2. Calculate the phyloCSF score of an ORF. 

usage: perl CalculatePhylocsf.pl -f orfFile -p phylocsfDir -o outputFile
	-f ORF structure in the genePred format;
	-p the folder link containing phylocsf score files;
	-o output file.

3. Run "PepScore.R" to calculate PepScore. 


