/*Escribir un programa que a partir de una lista de hechos los incorpore a la base de conocimiento. */
:- dynamic persona/1.   
persona(juan).
persona(ana).
persona(pedro).
incorporar([]).
incorporar([X|Y]) :- assertz(X), incorporar(Y).
