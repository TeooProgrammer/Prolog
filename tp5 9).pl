/*Escribir un programa para buscar el elemento menor de una lista. */
menor([X], X).
menor([X|Y], M) :- menor(Y,M1), X =< M1, M = X.
menor([X|Y], M) :- menor(Y,M1), X > M1, M = M1.