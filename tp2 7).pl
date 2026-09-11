/* Escribir un predicado diff(X,Y,Z) que es verdadero si X, Y y Z son todas diferentes.*/
diff(X,Y,Z) :- X =\= Y, Y =\= Z, X=\= Z.