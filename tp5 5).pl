/* Escribir un programa que substraiga una lista de otra lista */
:- consult('tp5 7).pl'). 
/* abreviado :- ['tp5 7).pl']. */

sustraer(_, [], []).
sustraer(X,[A|B], R) :- pertenece(X,A, _), sustraer(X, B, R).
sustraer(X,[A|B], [A|R]) :- \+ pertenece(X,A, _), sustraer(X, B, R).


/* X es la primer lista */ 