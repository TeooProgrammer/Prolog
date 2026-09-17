/* Escribir un programa recursivo que imprima por pantalla 10 números aleatorios. */
imprimir_aleatorios(0).
imprimir_aleatorios(N) :- N > 0, random_between(1,100, NUM), writeln(NUM),
N1 is N - 1, imprimir_aleatorios(N1).


