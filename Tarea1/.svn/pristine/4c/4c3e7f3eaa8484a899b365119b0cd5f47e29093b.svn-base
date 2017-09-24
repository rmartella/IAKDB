hombre(bart).
hombre(homero).
hombre(abraham).
hombre(herb).
hombre(clancy).

mujer(lisa).
mujer(maggie).
mujer(marge).
mujer(selma).
mujer(patty).
mujer(mona).
mujer(jackeline).
mujer(ling).

padre(bart,homero).
padre(lisa,homero).
padre(maggie,homero).
padre(homero,abraham).
padre(herb,abraham).
padre(marge,clancy).
padre(patty,clancy).
padre(selma,clancy).

madre(bart,marge).
madre(lisa,marge).
madre(maggie,marge).
madre(homero,mona).
madre(herb,mona).
madre(marge,jackeline).
madre(patty,jackeline).
madre(selma,jackeline).
madre(ling,selma).

abuelo(X,Y):-
	hombre(Y),(padre(X,P1),padre(P1,Y);madre(X,P1),padre(P1,Y)).
abuela(X,Y):-
	mujer(Y),(padre(X,P1),madre(P1,Y);madre(X,P1),madre(P1,Y)).
nieto(X,Y):-
	hombre(Y),(hombre(X),abuelo(Y,X);mujer(X),abuela(Y,X)).
nieta(X,Y):-
	mujer(Y),(hombre(X),abuelo(Y,X);mujer(X),abuela(Y,X)).	
hermano(X,Y):-
	hombre(Y), X \= Y, padre(X,P),padre(Y,P),madre(X,M),madre(Y,M).
hermana(X,Y):-
	mujer(Y), X \= Y, padre(X,P),padre(Y,P),madre(X,M),madre(Y,M).
tia(X,Y):-
	mujer(Y),(padre(X,P),hermana(P,Y);madre(X,M),hermana(M,Y)).
primo(X,Y):-
	hombre(Y),(
	padre(X,P1),padre(Y,P2),hermano(P1,P2);
	padre(X,P3),madre(Y,M1),hermana(P3,M1);
	madre(X,M2),padre(Y,P4),hermano(M2,P4);
	madre(X,M3),madre(Y,M4),hermana(M3,M4)
	).
sobrino(X,Y):-
	hombre(Y),
	(padre(Y,P),hermano(X,P);madre(Y,M),hermana(X,M)).
pareja(X,Y):-
	(madre(H,Y),padre(H,X);madre(H,X),padre(H,Y)
	),!.