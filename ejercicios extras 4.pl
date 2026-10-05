/* Definir un predicado recursivo cantidadDigitos(N,C) que, dado un número entero positivo N, determine en C cuántos dígitos tiene el número. */
cantidadDigitos(0,0).
cantidadDigitos(N,C) :- N > 0, N1 is N // 10, cantidadDigitos(N1,C1), C is C1 + 1. 