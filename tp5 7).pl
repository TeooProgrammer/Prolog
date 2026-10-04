/* 7. Escribir el programa "pertenece" que indique si un elemento pertenece a la lista y devuelva la posición ocupada por el elemento. */
pertenece([X|_], X, 1).
pertenece([_|Y], C, N) :- pertenece(Y, C, N1), N is N1 + 1.