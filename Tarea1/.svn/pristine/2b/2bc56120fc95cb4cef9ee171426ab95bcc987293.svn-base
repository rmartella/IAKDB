push([],E,E):-!.
push([A|B],E,[A|D]):-
	push(B,E,D).

elimina(X,[],[]):-!.
elimina(X,[X],[]):-!.
elimina(X,[X|B],S):-
	elimina(X,B,S),!.
elimina(X,[A|B],S):-
	elimina(X,B,W),push([A],W,S).