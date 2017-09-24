%valor(forma, [ color=>azul , forma=>esferica , peso=>ligero , material=>plastico] , X).
%dynamic (=>)/2.
%=>(X,Y).
:-op(15,xfx,=>).
valor(Attr,[H|T],X):-
	=>(Attr,X) = H,!;valor(Attr,T,X).