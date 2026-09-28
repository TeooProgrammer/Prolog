/* Escribir un programa que extraiga los últimos N caracteres de una lista y los coloque en otra lista. */
ultimos(0, _ , []).
ultimos(N,[X|Y], RestoResultado) :- N1 is N-1

cantidad([], 0).
cantidad([X|Y], N) :- cantidad(Y, N1), N is N1 + 1.

/* sin terminar */