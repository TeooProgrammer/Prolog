conoce(caro,luis).
conoce(caro,juan).
conoce(laura,pedro).
conoce(laura,pedro).
conoce(marcela,jorge).
amigo(laura,caro).
amigo(elsa,laura).
amigo(laura,marcela).

conoce_amigo(C,A) :- amigo(X,A), conoce(X,C).