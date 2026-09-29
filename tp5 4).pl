/* Escribir un programa que extraiga los últimos N caracteres de una lista y los coloque en otra lista. */
ultimos(N, L, R) :- cantidad(L, C), S is C - N, saltar(S, L, R).

saltar(0, Lista, Lista).
saltar(N, [_|Y], Resultado) :- N1 is N-1, saltar(N1, Y, Resultado).

cantidad([], 0).
cantidad([X|Y], N) :- cantidad(Y, N1), N is N1 + 1.

/* sin terminar */