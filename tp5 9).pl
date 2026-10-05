/*Escribir un programa para buscar el elemento menor de una lista. */
menor([X], X).
menor([X|Y], M) :- menor(Y,M1), X =< M1, M = X.
menor([X|Y], M) :- menor(Y,M1), X > M1, M = M1.

/*Escribir un programa para buscar el elemento mayor de una lista. */
mayor([X], X).
mayor([X|Y], M) :- mayor(Y,M1), X >= M1, M = X.
mayor([X|Y], M) :- mayor(Y,M1), X < M1, M = M1.