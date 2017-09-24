es_elemento(H,[H|T]).
es_elemento(X,[H|T]):-
	es_elemento(X,T).