#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
file = args[1]
file_cause <- strsplit(file,"_")[[1]][1]
file_effect <- strsplit(strsplit(file,"_")[[1]][2],"[.]")[[1]][1]
file_extra <- paste("_extra_", file, sep="")
browser()
posterior_distribution <- as.double(scan(file, what="character", nlines=1, sep=","))
extra_info <- scan(file_extra, what="character", nlines=1, sep=",")
adverb <- extra_info[1]
prior_entropy <- as.double(extra_info[2])
posterior_entropy <- as.double(extra_info[3])
resolution = length(posterior_distribution)
grid <- seq(from=0, to=1, length.out=resolution)
#jpeg(paste(file, ".jpg", sep=""), width=50, height=50)
svg(paste(file, ".svg", sep=""))
plot(grid, posterior_distribution, xlab="Causal frequency", ylab="PDF", main=paste(file_cause," producing ",file_effect, sep =""))
dev.off()
