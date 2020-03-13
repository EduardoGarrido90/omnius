get_l_dec(0,[0]):-!.
get_l_dec(N,[N|L]):-
	M is N-1,
	get_l_dec(M,L).

rev_get_l_dec(N,R):-
	get_l_dec(N,L),
	reverse(L,R).

get_ll_dec(0,[[0]]):-!.
get_ll_dec(N,[L1|L]):-
	M is N-1,
	get_ll_dec(M,L),
	get_l_dec(N,L1).

get_ll_dec(I,S,[[0,0,L]]):-
	S is I+1,
	get_l_dec(I,S,L),!.

get_ll_dec(I,S,[[0,0,L1]|L]):-
	N is S-1,
	get_ll_dec(I,N,L),
	get_l_dec(I,S,L1).

get_l_dec(I,I,[I]):-!.
get_l_dec(I,S,[S|L]):-
	N is S-1,
	get_l_dec(I,N,L).
	
get_complementary_members(1,_,[[1,0,2],[2,0,1]]).
get_complementary_members(2,T,[[1,0,T],[T,0,1]]).
get_complementary_members(C,T,[[I,0,T],[T,0,I]|R]) :-
        I is C - 1,
        get_complementary_members(I,T,R).

get_last_unitary_members(0,[[0,0,0]]).

get_last_unitary_members(C,[[0,0,C],[C,0,0],R|L]) :-
        I is C - 1,
        C > 1,
        get_last_unitary_members(I,L),
        get_complementary_members(C,C,R).

get_last_unitary_members(C,[[0,0,C],[C,0,0]|L]) :-
        I is C - 1,
        get_last_unitary_members(I,L).

regroup_elements([A,B,C],[[A,B,C]]).
regroup_elements([A,B,C|I],[[A,B,C]|O]):-
	regroup_elements(I,O).

get_llm_dec(I,S,[]):-
        S is I+1,!.

get_llm_dec(I,S,[[S,0,L1]|L]):-
        N is S-1,
        get_llm_dec(I,N,L),
        get_l_dec(I,N,L1).

get_sets_for_number(2,[]):-!.

get_sets_for_number(N,[R|L]):-
	M is N-1,
	get_sets_for_number(M,L),
	get_llm_dec(1,N,R).

get_elements(I,O):-
	get_last_unitary_members(I,R1),
	flatten(R1,R2),
	regroup_elements(R2,O1),
	get_ll_dec(1,I,O2),
	append(O1,O2,O3),
	get_sets_for_number(I,[O4|_]),
	append(O3,O4,O),
	print(O),!.

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

get_zero_tuples(I,FD):-
	get_l_dec(1,I,L),
	all_subsets(L,B),
	build_tuples(B,O1),
	get_rest_tuples(0,L,O2),
	append_sublists(O1,O2,C),
	append(C,[[0,0,0]],O),!,
	open(FD,append,FP),
	write_output_file(O,FP),
	close(FP).

