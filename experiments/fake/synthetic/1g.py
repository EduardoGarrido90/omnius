import numpy as np

lik_1 = "likelihood("
#adverbs = ["always","constantly","usually","normally","frequently","regularly","often","sometimes","occasionally","rarely",\
 #           "infrequently","seldom","hardly ever","never"]
adverbs = ["usually","normally"]
experiments = {"first_experiment": 200, "second_experiment" : 200}
concepts = np.array(["A","B","C"])
for experiment in experiments:
    relations = dict()
    likelihoods_file = open("./" + experiment + "/train.pl","w+")
    num_relations = experiments[experiment]
    causes_indexes = np.random.randint(0, len(concepts), num_relations)
    effects_indexes = np.random.randint(0, len(concepts), num_relations)
    adverbs_indexes = np.random.randint(0, len(adverbs), num_relations)
    for i in range(num_relations):
        cause = concepts[causes_indexes[i]]
        effect = concepts[effects_indexes[i]]
        if cause == "A" and effect == "B" or cause == "B" and effect == "C":
            complete_relation = str(cause)+str(effect)
            if complete_relation not in relations:
                index = 1
            else:
                index = relations[complete_relation]
                index = index+1
            relations[complete_relation] = index
            likelihoods_file.write(lik_1 + "'" + cause + "','" + effect + "','" + adverbs[adverbs_indexes[i]] + "'," + str(index) + ").\n")
    likelihoods_file.close()
