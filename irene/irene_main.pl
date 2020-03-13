:- set_prolog_flag(verbose, silent).
:- initialization(main).

fatality(A, B, C, B, A, C).
fatality(A, _, C, A, 0, C). 

main :-
        current_prolog_flag(argv, Argv),        
	nth0(0,Argv,X),
        nth0(1,Argv,Y),
        nth0(2,Argv,Z),
	repeat,
	fatality(X,Y,Z,A,B,C),
	print(A),
	print(B),
	print(C),
	nl,
	B == 0,
	halt.

main :-
    halt(1).
