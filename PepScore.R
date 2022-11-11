##################### PepScore prediction
install.packages("caret")
library("caret")
load("my_model.rda")
summary (m1)
A1 <- read.table ("./example/summerize.human.ORFs.txt", sep="\t", header=T)
fdr1 <- A1$len.fdr
fdr1 <- replace (fdr1, (fdr1 < 0.0001), 0.0001)
fdr1 <- -log10(fdr1)
cons1 <- (A1$phylocsf*(A1$orf.len/3))
cons1 <- log10(abs(cons1)+1)*sign(cons1)
dom1 <- A1$tmhmm+A1$pfam
dom1 <- replace (dom1, (dom1 >= 1), 1)
B1 <- data.frame(fdr=fdr1, cons=cons1, domain=dom1)
p1 <- predict(m1, B1, type="prob")
out <- data.frame(A1, B1, PepScore=p1[,2])
write.table (out, "./example/score.summerize.human.ORFs.txt", sep="\t", row.names=F, quote=F)
