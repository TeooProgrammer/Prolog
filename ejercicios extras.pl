consult :- ('tp5 7).pl').
/*función contarMenores(L,C,N), que retorna la cantidad de elementos menores que C sobre la lista L. */
contarMenores([], _, 0).
contarMenores([X|Y], C, N) :- X < C, contarMenores(Y, C, N1), N is N1 + 1.
contarMenores([X|Y], C, N) :- X >= C, contarMenores(Y,C,N).

/* /*función contarMayores(L,C,N), que retorna la cantidad de elementos mayores que C sobre la lista L. */
contarMayores([], _, 0).
contarMayores([X|Y], C, N) :- X > C, contarMayores(Y, C, N1), N is N1 + 1.
contarMayores([X|Y], C, N) :- X =< C, contarMayores(Y,C,N).

/* recorre una lista y suma los números pares. */
sumarPares([], 0).
sumarPares([X|Y], S) :- X mod 2 =:= 0, sumarPares(Y,S1), S is S1 + X.
sumarPares([X|Y], S) :- X mod 2 =\= 0, sumarPares(Y, S).

/* recorre los digitos de un numero y cuenta los pares */
contarParesNumero(0, 0).
contarParesNumero(N, C) :- N > 0, D is N mod 10, D mod 2 =:= 0, N1 is N // 10, contarParesNumero(N1, C1), C is C1 + 1.
contarParesNumero(N, C) :- N > 0, D is N mod 10, D mod 2 =\= 0, N1 is N // 10, contarParesNumero(N1, C).

/* recorre los digitos de un numero y cuenta los impares */
contarImparesNumero(0, 0).
contarImparesNumero(N, C) :- N > 0, D is N mod 10, D mod 2 =\= 0, N1 is N // 10, contarImparesNumero(N1, C1), C is C1 + 1.
contarImparesNumero(N, C) :- N > 0, D is N mod 10, D mod 2 =:= 0, N1 is N // 10, contarImparesNumero(N1, C).

/* recorre una lista y suma los números impares. */
sumarImpares([], 0).
sumarImpares([X|Y], S) :- X mod 2 =\= 0, sumarImpares(Y,S1), S is S1 + X.
sumarImpares([X|Y], S) :- X mod 2 =:= 0, sumarImpares(Y, S).

/* eliminarNegativos(L1,L2) que reciba una lista de números y genere otra lista eliminando todos los números negativos. */
eliminarNegativos([], []).
eliminarNegativos([X|Y], [X|R]) :- X >= 0, eliminarNegativos(Y, R).
eliminarNegativos([X|Y], R) :-  X < 0, eliminarNegativos(Y, R).

/* eliminarPositivos(L1,L2) que reciba una lista de números y genere otra lista eliminando todos los números negativos. */
eliminarPositivos([], []).
eliminarPositivos([X|Y], [X|R]) :- X =< 0, eliminarPositivos(Y, R).
eliminarPositivos([X|Y], R) :-  X > 0, eliminarPositivos(Y, R).

/* Escribir un predicado sinRepetidos(L1,L2) que reciba una lista L1 y genere en L2 una lista que contenga los mismos elementos, pero sin elementos repetidos. */
sinRepetidos([], []).
sinRepetidos([X|Y], R) :- pertenece(X, Y), sinRepetidos(Y, R).
sinRepetidos([X|Y], [X|R]) :- \+ pertenece (X, Y), sinRepetidos(Y, R).

/* Escribir un predicado conRepetidos(L1,L2) que reciba una lista L1 y genere en L2 una lista que contenga los mismo elementos repetidos. */
conRepetidos([], []).
conRepetidos([X|Y], R) :- \+ pertenece (X, Y), conRepetidos(Y,R).
conRepetidos([X|Y], [X|R]) :- pertenece (X, Y), conRepetidos(Y, R).
