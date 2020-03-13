:- set_prolog_flag(verbose, silent).
:- initialization(main).

get_l_dec(I,I,[I]):-!.
get_l_dec(I,S,[S|L]):-
	N is S-1,
	get_l_dec(I,N,L).
	
l_subset([], []).
l_subset([E|Tail], [E|NTail]):-
  l_subset(Tail, NTail).
l_subset([_|Tail], NTail):-
  l_subset(Tail, NTail).

all_subsets(L,B):-
	findall(S,l_subset(L,S),B).

build_tuples([[]],[]):-!.
build_tuples([H|B],[[0,0,H]|C]):-
	length(H,L),
	L > 1,
	build_tuples(B,C).

build_tuples([[H|_]|B],[[0,0,H]|C]):-
        build_tuples(B,C).

build_i_tuples(_,[[]],[]):-!.
build_i_tuples(I,[H|B],[[I,0,H]|C]):-
        length(H,L),
        L > 1,
        build_i_tuples(I,B,C).

build_i_tuples(I,[[H|_]|B],[[I,0,H]|C]):-
        build_i_tuples(I,B,C).

get_rest_tuples(C,L,[]):-
	length(L,E),
	C == E,!.

get_rest_tuples(C,L,[O|X]):-
	D is C+1,
	get_rest_tuples(D,L,X),
	nth0(C,L,E),
	delete(L,E,I),
	all_subsets(I,B),
	build_i_tuples(E,B,O).

write_list([R1|[]],FP):-
	write(FP,R1),!.

write_list([R1|R],FP):-
	write(FP,R1),
	write(FP," "),
	write_list(R,FP).

write_triplet([R1|[]],FP):-
	is_list(R1),
        write_list(R1,FP),!.

write_triplet([R1|R],FP) :-
	is_list(R1),
        write_list(R1,FP),
        write(FP,","),
        write_triplet(R,FP).

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

append_sublists(O1,[],O1).
append_sublists(O1,[O21|O2],R):-
	append_sublists(O1,O2,X),
	append(X,O21,R).

main :-
        current_prolog_flag(argv, Argv),
        nth0(0,Argv,FI),
        nth0(1,Argv,FD),
	open(FI, read, FPI),
	read_line(FPI,Size),
        atom_number(Size, I),
	get_l_dec(1,I,L),
	all_subsets(L,B),
	build_tuples(B,O1),
	get_rest_tuples(0,L,O2),
	append_sublists(O1,O2,C),
	append(C,[[0,0,0]],O),!,
	open(FD,append,FP),
	write_output_file(O,FP),
	close(FP).

main :-
    halt(1).
