/* Escribir un programa que reciba una lista con números positivos y negativos, y coloque los números
positivos en una lista y los negativos en otra. */

separar([], [], []).
separar([X|Y], [X|P], N) :- X >= 0, separar(Y, P, N), X <= 0, separar(Y, P, N).
 

