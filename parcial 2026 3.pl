 /* Describir que hace la siguiente función recursiva. (Comentar línea por línea) */

/* caso base, termina cuando los casos recursivos son 1, R=1*/
adivina(X,Y):-adivina2(X,Y,1).
/* caso base, al estar Y en 0 e X junto a R con otro valor, escribe en R*/
adivina2(X,0,R):-write(R).
/* caso recursivo, crea R1 para asignarle la multplicacion de R con X, avanza en la lista cuando le asigna Y - 1 a  Y1, luego hace la llamada recursiva*/
adivina2(X,Y,R):- R1 is R * X, Y1 is Y - 1, adivina2(X,Y1,R1).
/* lo que hace el programa es multiplicar su primer variable (la X) con el R, la cual es ingresada por el usuario, para de esta forma dar un resultado */

