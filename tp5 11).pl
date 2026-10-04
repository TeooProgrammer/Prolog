/* Escribir un programa que dada una lista y una posición en la lista devuelva el elemento que se encuentra en esa posición. */
elemento([X|_], 1, X).
elemento([_|Y], N, X) :- N1 is N -1, elemento(Y, N1, X).
