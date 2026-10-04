/* Concatenar X e Y en Z, pero si tienen elementos en común, deben aparecer una sola vez. */
:- consult('tp5 7).pl').

concatenar([], Y, Y).
concatenar([A|B], Y, R) :- pertenece(Y, A, _), concatenar(B,Y,R).
concatenar([A|B], Y, [A|R]) :- \+ pertenece(Y,A, _), concatenar(B,Y,R).