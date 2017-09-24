cuenta(A,[],0):-!.
cuenta(A,[A|T],X):-
	cuenta(A,T,X1),!,X is X1 + 1.	
cuenta(A,[H|T],X):-
	A\=H,
	cuenta(A,T,X),!.
