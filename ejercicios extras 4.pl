/* Definir un predicado recursivo cantidadDigitos(N,C) que, dado un número entero positivo N, determine en C cuántos dígitos tiene el número. */
cantidadDigitos(0,0).
cantidadDigitos(N,C) :- N > 0, N1 is N // 10, cantidadDigitos(N1,C1), C is C1 + 1. 

/* Definir un predicado invertirNumero(N,I) que reciba un número entero positivo N y obtenga en I el número con sus dígitos en orden inverso. */
invertirNumero(N, I) :- invertirAux(N, 0, I).
invertirAux(0, I, I).
invertirAux(N, Acum, I) :- N > 0, D is N mod 10, N1 is N // 10, Acum1 is Acum * 10 + D, invertirAux(N1, Acum1, I).

/* N mod 10  -> obtiene, separa el último dígito del número. Ej: 1234 mod 10 = 4 */

/* N // 10 -> elimina el último dígito del número. Ej: 1234 // 10 = 123 */

/* Definir un predicado mayoresA(L,V,R) que reciba una lista de números L y un valor V,
y genere en R una nueva lista que contenga únicamente los elementos de L que sean mayores que V. */

mayores([], _, []).
mayores([X|Y],V, [X|R]) :- X > V, mayores(Y, V, R).
mayores([X|Y], V, R) :- X =< V, mayores(Y, V, R).

/* Definir un predicado menoresA(L,V,R) que reciba una lista de números L y un valor V,
y genere en R una nueva lista que contenga únicamente los elementos de L que sean menores que V. */

menores([], _, []).
menores([X|Y],V, [X|R]) :- X < V, menores(Y, V, R).
menores([X|Y], V, R) :- X >= V, menores(Y, V, R).