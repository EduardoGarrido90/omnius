/*
	Inference engine. Go to the main predicate to see a description of the arguments
	and the algorithm.

	Execution example:
		swipl engine.pl 2 1 3 output.txt

	Content of output file:
		[[0,2,3],[2,0,3],[0,0,3],[0,1,3],[1,0,3],[1,2,3],[2,1,3]]

	Execution example:
		swipl engine.pl 2 2 3 output.txt		

	Content of output file:
		[[0,0,3],[0,2,3],[2,0,3],[2,2,3]]
*/

:- set_prolog_flag(verbose, silent).
:- initialization(main).

/* Grafoid rules 
   I think that it is better that they have different predicates.
   Having the same predicate, the Prolog execution code would be more inefficient.
   Moreover, the representation is argumentably worse, since we are representing rules that
   are executed one by one, not all of them at the same time.
   Nevertheless, this is subjective, I prefer it this way, although I am going to repeat
   utils code but I think that it is more clear in the Prolog fashion.
*/
i([A, B, C], [B, A, C]).   /* symmetry */
i2([A, _, C], [A, 0, C]).  /* empty set */

lmember(X,[X|_]):-!.
lmember(X,[_|L]):-lmember(X,L).

/* Utils */
appendCombination1(L,LL,_) :-
	i(L,L1),
	lmember(L1,LL),
	!,fail.

appendCombination1(L,LL,[L1|LL]) :-
	i(L,L1).

appendCombination2(L,LL,_) :-
        i2(L,L1),
        lmember(L1,LL),
	!,fail.

appendCombination2(L,LL,[L1|LL]) :-
	i2(L,L1).

/* Base rule for the recursion.
   It is only important that the second argument, the list of lists, is empty.
   This list are the lists that can still produce combinations.
   Every time that a new combination is found, all the processed lists are copied here again.
   If we have reached this point, is because no more combinations are left.
   The processed lists, third argument, are copied to the four argument, the output, because these are all the combinations.
*/
getCombinations([],P,P):-!.

/* Recursion rule with combination 1 found.
   In each step, we must retrieve one list from the second argument and process its combinations.
   It succeds if we find combinations, calling again getCombinations with the list being found in the first place and all others.
*/
getCombinations([H|_],F,R) :-
	appendCombination1(H,F,E),
	F \== E,
	getCombinations(E,E,R).

/* Recursion rule with combination 2 found.
   In each step, we must retrieve one list from the second argument and process its combinations.
   It succeds if we find combinations, calling again getCombinations with the list being found in the first place and all others.
*/
getCombinations([H|_],F,R) :-
        appendCombination2(H,F,E),
	F \== E,
        getCombinations(E,E,R).

/*
  Recursion rule with no found combination.
  If no new combination is found, then, we must call the method getCombinations without the head of the list of the lists being processed.
*/
getCombinations([_|C],F,R) :-
	getCombinations(C,F,R).

write_triplet([R1|[]],FP):-
	write(FP,R1),!.

write_triplet([R1|R],FP) :-
	write(FP,R1),
	write(FP,","),
	write_triplet(R,FP).

write_output_file([],_):-!.

write_output_file([R1|R], FP) :-
        write_triplet(R1,FP),
        write(FP,"\n"),
        write_output_file(R,FP).

read_line(S, X) :-
   read_line_to_codes(S, L),
   read_line2(L, X).

read_line2(end_of_file, _) :- !, fail.
read_line2(L, X) :-
   atom_codes(X, L).

/* Main predicate.
   [A,B,C], first argument, is the tuple to find the combinations.
   R, second argument, is a list of lists with all the combinations of L.
   FD, third argument, is the name of the output file where the result is printed.
*/
main :-
        current_prolog_flag(argv, Argv),
        nth0(0,Argv,FI),
	nth0(1,Argv,FD),
	open(FI, read, FPI),
        read_line(FPI,Size),
        atom_number(Size, S),
        read_line(FPI,LS),
	string_chars(LS,LL),
        delete(LL,',',L),
        close(FPI),	
	getCombinations([L],[L],R),
	!,
	open(FD,append,FP),
	write_output_file(R,FP),
	close(FP),
	halt.

main :-
    halt(1).
