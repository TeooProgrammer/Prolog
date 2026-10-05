gusta(juan, pizza).
gusta(maria, sushi).
gusta(pedro, pizza).
gusta(ana, ensalada).
gusta(juan,sushi).
gusta(juan,ensalada).
comida(pizza).
comida(sushi).
comida(ensalada).

/* -> a X e Y les gusta la misma comida */
gusto_comun(X, Y) :- gusta(X, C), gusta(Y, C), X \= Y.

/* -> le gusta pizza, sushi y ensalada. */
come_de_todo(X) :- gusta(X, pizza), gusta(X, sushi), gusta(X, ensalada).

/*?- come_de_todo(X). */
/* 18 ?- gusto_comun(X,Y).
X = juan,
Y = pedro ;
X = maria,
Y = juan ;
X = pedro,
Y = juan ;
X = ana,
Y = juan ;
X = juan,
Y = maria ;
X = juan,
Y = ana ;
false. */

/*20 ?- gusta(X,sushi).
X = maria ;
X = juan. */

/* 20 ?- come_de_todo(X).
X = juan . */

/* 21 ?- comida(X).
X = pizza ;
X = sushi ;
X = ensalada. */

/* recorre una lista y suma los numeros pares. */
contarPares([], 0).
contarPares([X|Y], S) :- X mod 2 =:= 0, contarPares(Y,S1), S is S1 + 1.
contarPares([X|Y], S) :- X mod 2 =\= 0, contarPares(Y, S).

/* 32 ?- contarPares([2,2,2,4,4,4,8,8,3], S).
S = 8 . */
/* 33 ?- contarPares([5,5,64,4,1,2,3], S).
S = 3 . */







