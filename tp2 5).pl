/* Escribir un procedimiento diferencia(X,Y,Z), que ligue en Z la suma de X e Y sí X es mayor a X , o
que ligue en Z la sustracción de X e Y sí X es menor. Caso contrario Z es ligado al valor de X. */

diferencia(X,Y,Z) :- X > Y, Z is X + Y.
diferencia(X,Y,Z) :- X < Y, Z is X - Y.
diferencia(X,Y,Z) :- X =:= Y, Z is X.