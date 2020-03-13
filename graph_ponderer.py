import os
import sys
import numpy as np 

exp_dir = sys.argv[1]
causes_file = [line.rstrip('\n') for line in open(exp_dir + "causes.txt","r")]
effects_file = [line.rstrip('\n') for line in open(exp_dir + "effects.txt","r")]
print "Executing Bayesian Inference over the graph"
print "Number of executed ponderations"
processedRelations = []
for i in range(len(causes_file)):
    cause = causes_file[i]
    effect = effects_file[i]
    if cause+effect not in processedRelations:
        processedRelations.append(cause+effect)
        log_file = cause.replace(" ","") + "_" + effect.replace(" ","") + ".txt"
        prolog_command = "swipl main.pl \"" + cause + "\" \"" + effect + "\" 50 trash.txt " + log_file
        os.system(prolog_command)
        print "\n" + prolog_command
        R_command = "Rscript causal_plotter.R " + log_file
        os.system(R_command)
        print "\n" + R_command
    print i
print "Job complete"
print "Creating routine to paint the graph"
gv_file = open("./graph.py","w+")
gv_file.write("from graphviz import Digraph\n")
gv_file.write("G = Digraph(comment='Causal Graph')\n")
concepts = list(set(causes_file+effects_file))
concepts_dict = {}
node_causals = {}
effect_causals = {}
for i in range(len(concepts)):
    concepts_dict[concepts[i]] = i
edge_dict = {}
for i in range(len(causes_file)):
    cause_id = str(concepts_dict[causes_file[i]])
    effect_id = str(concepts_dict[effects_file[i]])
    cause = causes_file[i]
    effect = effects_file[i]
    edge_id = cause_id + effect_id
    if edge_id not in edge_dict:
        edge_dict[edge_id] = 1
    else:
        edge_dict[edge_id] = edge_dict[edge_id] + 1
    if cause_id not in node_causals:
        node_causals[cause_id] = {effect_id : 1}
    else:
        if effect_id not in node_causals[cause_id]:
            node_causals[cause_id][effect_id] = 1
        else:
            node_causals[cause_id][effect_id] = node_causals[cause_id][effect_id] + 1
    if effect_id not in effect_causals:
        effect_causals[effect_id] = {cause_id : 1}
    else:
        if cause_id not in effect_causals[effect_id]:
            effect_causals[effect_id][cause_id] = 1
        else:
            effect_causals[effect_id][cause_id] = effect_causals[effect_id][cause_id] + 1
max_values = max(edge_dict.values())
for i in range(len(concepts)):
    #If it is an effect, as in the case, is the most relevant cause.
    more_studied_concept = ""
    cause = True
    if str(concepts_dict[concepts[i]]) not in node_causals:
        more_studied_concept = effect_causals[str(concepts_dict[concepts[i]])].keys()[np.argmax(effect_causals[str(concepts_dict[concepts[i]])].values())]     
        cause = False
    else:
        more_studied_concept = node_causals[str(concepts_dict[concepts[i]])].keys()[np.argmax(node_causals[str(concepts_dict[concepts[i]])].values())]
    more_studied_concept = concepts_dict.keys()[concepts_dict.values().index(int(more_studied_concept))]
    if cause:
        gv_file.write("G.node('"+str(i)+"','"+concepts[i]+"', image='"+concepts[i].replace(" ","")+"_"+more_studied_concept.replace(" ","")+".txt.jpg', imagepos='ml', width='4', labelloc='b', shape='circle')\n")
    else:
        gv_file.write("G.node('"+str(i)+"','"+concepts[i]+"', image='"+more_studied_concept.replace(" ","")+"_"+concepts[i].replace(" ","")+".txt.jpg', imagepos='ml', width='4', labelloc='b', shape='circle')\n")
for ei in edge_dict:
    edge_dict[ei] = edge_dict[ei]/(float(max_values)/(max_values/10.0)) + 1.0
second_edge_dict = []
for i in range(len(causes_file)):
    cause_id = str(concepts_dict[causes_file[i]])
    effect_id = str(concepts_dict[effects_file[i]])
    cause = causes_file[i]
    effect = effects_file[i]
    edge_id = cause_id + effect_id
    if edge_id not in second_edge_dict:
        extra_log_file = "_extra_" + cause.replace(" ","") + "_" + effect.replace(" ","") + ".txt"
        image_file = cause.replace(" ","") + effect.replace(" ","") + ".txt.pdf"
        edge_adverb = [line.rstrip('\n') for line in open(extra_log_file,"r")][0].split(",")[0]
        gv_file.write("G.edge('"+cause_id+"','"+effect_id+"', label='"+edge_adverb+"', **{'penwidth':'"+str(edge_dict[edge_id])+"'})\n")
        second_edge_dict.append(edge_id)
causal_graph_file = "causal_graph"
gv_file.write("G.render('"+causal_graph_file+"')\n")
gv_file.close()
print "Job complete"
python_command = "python graph.py"
os.system(python_command)
evince_command = "evince " + causal_graph_file + ".pdf"
os.system(evince_command)
