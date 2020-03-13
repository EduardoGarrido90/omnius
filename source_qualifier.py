import numpy as np
import sys

prob_file_route = sys.argv[1]
threshold = float(sys.argv[2])
prob_counter = 0.0
probs = 0
with open(prob_file_route,"r") as f_prob:
    for l in f_prob:
        causal_prob = float(l.replace("\n",""))
        prob_counter += causal_prob 
        probs += 1
prob_source = prob_counter / float(probs)
print "The probability of the source being non trust worthy is : " + str(prob_source*100.0) + " %"
worthy = prob_source < threshold
if worthy:
    print "According to the given threshold, it is a trust worthy source"
else:
    print "According to the given threshold, we must not learn causal relations from this source"
confidence_degree = np.abs(prob_source - threshold) / np.maximum(1.0-prob_source,prob_source)
print "The confidence degree of the decision based in the threshold and the probability of the source is " + str(confidence_degree*100.0) + " %"
