populate_grid(_, [1.0], _, T, T):-!.

populate_grid(I, [X|L], J, M, T) :-
        X is I + J,
        N is I + J,
	W is M + 1,
        populate_grid(N, L, J, W, T).

generate_grid(N,[X|L]) :-
        J is 1 / (N-1),
        populate_grid(0, L, J, 2, N),
        X is 0.

reverse([],[]):-!.  
reverse([X],[X]):-!. 
reverse( [X|Xs] , R ):- 
  reverse(Xs,T),       
  append( T , [X] , R ).
  

%CDFs.

%Gamma function. Necessary for beta.
factorial(1, 1) :-
	!.

factorial(N, Y) :-
	M is N-1,
	factorial(M, Y1),
	Y is Y1*N.

gamma(N, Y) :-
	M is N-1,
	factorial(M, Y).

%Beta.
dbeta(X, A, B, Y) :-
	gamma(A, GA),
	gamma(B, GB),
	C is A + B,
	gamma(C, GC),
	Y is (X ^ (A-1) * (1.0-X) ^ (B-1)) / ( (GA * GB) / (GC) ).

%Exponential.
dexp(X, _, 0) :-
	X < 0,
	!.

dexp(X, L, Y) :-
	X >= 0,
	Y is L * e ^ (- L * X).	

%Gaussian.
dnorm(X, M, S, Y) :-
	Y is (1.0 / sqrt(2.0 * pi * S ^ 2)) * e ^ (-((X - M)^2 / (2.0 * S ^ 2))).


%Grids.
draw_gaussian_grid([], [], _, _) :-
	!.

draw_gaussian_grid([G|J], [Y|L], M, S) :-
	dnorm(G, M, S, Y),
	draw_gaussian_grid(J, L, M, S).

draw_gaussian_pdf(N, L, M, S) :-
	generate_grid(N, G),
	draw_gaussian_grid(G, L, M, S).

draw_exp_grid([], [], _) :-
        !.

draw_exp_grid([G|J], [Y|L], M) :-
        dexp(G, M, Y),
        draw_exp_grid(J, L, M).

draw_exp_pdf(N, L, M) :-
        generate_grid(N, G),
        draw_exp_grid(G, L, M).

draw_beta_grid([], [], _, _) :-
        !.

draw_beta_grid([G|J], [Y|L], M, S) :-
        dbeta(G, M, S, Y),
        draw_beta_grid(J, L, M, S).

draw_beta_pdf(N, L, M, S) :-
        generate_grid(N, G),
        draw_beta_grid(G, L, M, S).

reverted_beta_pdf(N, L, M, S) :-
	draw_beta_pdf(N, K, M, S),
	reverse(K,L).

reverted_exp_pdf(N, L, M) :-
        draw_exp_pdf(N, K, M),
        reverse(K,L).

multiply_grids([],[],[]).

multiply_grids([X1|X],[Y1|Y],[Z1|Z]) :-
	Z1 is X1*Y1,
	multiply_grids(X,Y,Z).

multiply_grids([],[],[]).

multiply_number_to_grid([],_,[]).

multiply_number_to_grid([X1|X],Y,[Z1|Z]) :-
	multiply_number_to_grid(X, Y, Z),
	Z1 is X1 * Y.

sum_grid([],0).

sum_grid([L1|L],Y) :-
	sum_grid(L,M),
	Y is L1+M.

divide_grid([],[],_).

divide_grid([L1|L],[Y1|Y],N) :-
        divide_grid(L,Y,N),
        Y1 is L1/N.
