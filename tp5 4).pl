/* Escribir un programa que extraiga los últimos N caracteres de una lista y los coloque en otra lista. */
ultimos(N, L, R) :- cantidad(L, C), S is C - N, saltar(S, L, R).

saltar(0, Lista, Lista).
saltar(N, [_|Y], Resultado) :- N1 is N-1, saltar(N1, Y, Resultado).

cantidad([], 0).
cantidad([_|Y], N) :- cantidad(Y, N1), N is N1 + 1.

/* Escribir un programa que extraiga los primeros N caracteres de una lista y los coloque en otra lista. */
primeros(N, L, R) :- tomar(N, L, R).

tomar(0, _, []).
tomar(N, [X|Y], [X|R]) :- N1 is N - 1, tomar(N1, Y, R).