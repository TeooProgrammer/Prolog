
hijo(caro,luis).
hijo(juan,luis).
hijo(laura,luis).
hijo(marcela,jorge).
hijo(laura,caro).
hijo(elsa,laura).
hijo(laura,marcela).
femenino(caro).
femenino(laura).
femenino(marcela).
femenino(elsa).
masculino(luis).
masculino(juan).
masculino(jorge).
hermanos(X,Y) :- hijo(X,Z), hijo(Y,Z), X \= Y.
hermana(X,Y) :- hijo(X,Z), hijo(Y,Z), femenino(X), X \= Y.
hermano(X,Y) :- hijo(X,Z), hijo(Y,Z), masculino(X), X \= Y.
padre(X,Y) :- hijo(Y,X), masculino(X).
madre(X,Y) :- hijo(Y,X), femenino(X).
abuelo(X,Y) :- padre(X,Z), hijo(Y,Z).
abuela(X,Y) :- madre(X,Z), hijo(Y,Z).
bisabuelo(X,Y) :- padre(X,Z), hijo(W,Z), hijo(Y,W).
bisabuela(X,Y) :- madre(X,Z), hijo(W,Z), hijo(Y,W).