hijo(caro,luis).
hijo(juan,luis).
hijo(laura,luis).
hijo(marcela,jorge).
hijo(laura,caro).
hijo(elsa,laura).
hijo(laura,marcela).

ancestro(X,Y) :- hijo(Y,X).
ancestro(X,Y) :- hijo(Z,X), ancestro(Z,Y).

descendiente(X,Y) :- hijo(X,Y).
descendiente(X,Y) :- hijo(X,Z), descendiente(Z,Y).