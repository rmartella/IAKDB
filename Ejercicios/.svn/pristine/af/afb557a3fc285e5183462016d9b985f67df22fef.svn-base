protagonista(shaggy,masculino).
protagonista(fred,masculino).
protagonista(daphne,femenino).
protagonista(velma,femenino).
protagonista('scooby doo',masculino).
protagonista('scrappy doo',masculino).
humano(shaggy).
humano(fred).
humano(daphne).
humano(velma).
perro('scooby doo').
perro('scrappy doo').
heroe(X):-protagonista(X,masculino),
	  humano(X).
heroina(X):- protagonista(X,femenino),
	  humano(X).
	  
super_heroe(X):-heroe(X),heroina(X),write(X),nl,fail.