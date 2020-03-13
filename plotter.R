#Regularly visualization
grid <- seq(from=0, to=1, length.out=10000)
prior <- dnorm(grid, 0.8, 0.1)
plot(grid, prior, xlab="Frequency of the causal", ylab="Probability density function", main="Regularly adverb representation")

prior <- dnorm(grid, 0.2, 0.1)
plot(grid, prior, xlab="Frequency of the causal", ylab="Probability density function", main="Seldom adverb representation")

#Always visualization.
prior <- rev(dexp(grid, rate=40))
plot(grid, prior, xlab="Uncertainty over the certainty factor", ylab="How probable is each value of the certainty factor", main="Always adverb representation")

#Never visualization.
prior <- dexp(grid, rate=40)
plot(grid, prior, xlab="Frequency of the causal", ylab="Probability density function", main="Never adverb representation")

#Constantly visualization.
prior <- dbeta(grid, 10, 2)
plot(grid, prior, xlab="Frequency of the causal", ylab="Probability density function", main="Constantly adverb representation")

#Hardly ever visualization.
prior <- rev(dbeta(grid, 10, 2))
plot(grid, prior, xlab="Uncertainty over the certainty factor", ylab="How probable is each value of the certainty factor", main="Hardly ever adverb representation")

#Sometimes visualization.
jpeg("contradictory.jpg", width=500, height=500)
prior <- dnorm(grid, 0.4, 0.6)
plot(grid, prior, xlab="Uncertainty over the certainty factor", ylab="How probable is each value of the certainty factor", main="Contradictory Information")
dev.off()

jpeg("certain.jpg", width=500, height=500)
prior <- dnorm(grid, 0.8, 0.05)
plot(grid, prior, xlab="Uncertainty over the certainty factor", ylab="How probable is each value of the certainty factor", main="Useful Information")
dev.off()

#Occasionally visualization.
prior <- dnorm(grid, 0.3, 0.1)
plot(grid, prior, xlab="Uncertainty over the certainty factor", ylab="How probable is each value of the certainty factor", main="Infrequently adverb representation")

