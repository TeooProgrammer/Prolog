/* Escribir un programa que extraiga los primeros N caracteres de una lista y los coloque en otra lista */
primeros(0, _ , []).
primeros(N, [X|Y], [X|RestoResultado] ) :- N1 is N-1, primeros(N1, Y, RestoResultado).
