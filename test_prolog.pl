random_list(0, []):-!.
random_list(N, [X|L]) :- M is N-1, random_list(M, L), random(X).
