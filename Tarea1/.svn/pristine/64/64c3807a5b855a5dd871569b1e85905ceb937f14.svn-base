fib(1,1,0):-!.
fib(2,1,0):-!.
fib(N,X,Y):-
	N > 2,
	N1 is N-1,
	fib(N1,X1,Y1),
	X is X1 + Y1,
	Y is X1.
fib(0,0):-!.
fib(N,X):-
	N > 0,
	fib(N,X1,Y),
	X is X1 + Y.