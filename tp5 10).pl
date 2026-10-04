/*Escribir un programa que dada una lista y dos posiciones, devuelva la sublista correspondiente.*/
sublista(_,_,0,[]).
sublista([X|Y], I, F, R) :- I > 1, I1 is I - 1, F1 is F - 1, sublista(Y, I1, F1, R).
sublista([X|Y], 1, F, [X|R]) :- F1 is F - 1, sublista(Y, 1, F1, R).

/* ¿cuanto me falta? → resto.
¿cuanto recorrí? → sumo. */