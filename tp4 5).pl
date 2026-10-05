izquierdo(7,4).
derecho(7,8).
izquierdo(4,2).
derecho(4,9).
izquierdo(8,5).
derecho(8,1).
derecho(1,6).

hoja(X) :- \+ izquierdo(X,_), \+ derecho(X,_).
/* caso base, nodo hoja sin hijos*/
preorden(X) :- hoja(X), write(X), write(' ').
/* caso general, nodo con hijo izquierdo y derecho*/
preorden(X) :- izquierdo(X,Y), derecho(X,Z), write(X), write(' '), preorden(Y), preorden(Z).
/* caso con solo hijo izquierdo*/
preorden(X) :- izquierdo(X,Y), \+ derecho(X,_), write(X), write(' '), preorden(Y).
/* caso con solo hijo derecho */
preorden(X) :- \+ izquierdo(X,_), derecho(X,Z), write(X), write(' '), preorden(Z).

/* caso base, nodo hoja sin hijos*/
postorden(X) :- hoja(X), write(X), write(' ').
/* caso general, nodo con hijo izquierdo y derecho*/
postorden(X) :- izquierdo(X,Y), derecho(X,Z), postorden(Y), postorden(Z), write(X), write(' ').
/* caso con solo hijo izquierdo*/
postorden(X) :- izquierdo(X,Y), \+ derecho(X,_), postorden(Y), write(X), write(' '). 
/* caso con solo hijo derecho */
postorden(X) :- \+ izquierdo(X,_), derecho(X,Z), postorden(Z), write(X), write(' ').

/* caso base, nodo hoja sin hijos*/
inorden(X) :- hoja(X), write(X), write(' ').
/* caso general, nodo con hijo izquierdo y derecho*/
inorden(X) :- izquierdo(X,Y),inorden(Y), write(X), write(' '),derecho(X,Z), inorden(Z).
/* caso con solo hijo izquierdo*/
inorden(X) :- izquierdo(X,Y), \+ derecho(X,_), inorden(Y), write(X), write(' '). 
/* caso con solo hijo derecho */
inorden(X) :- \+ izquierdo(X,_), write(X), write(' '), derecho(X,Z), inorden(Z).

/* mayor del arbol */
mayor(X, M) :- hoja(X), M is X.

/* nodo con ambos hijos */
mayor(X,M) :- izquierdo(X,Y), derecho(X,Z), mayor(Y,MI), mayor(Z,MD), M is max(X, max(MI,MD)).
/* nodo con solo hijo izquierdo */
mayor(X,M) :- izquierdo(X,Y), \+ derecho(X,_), mayor(Y,MI), M is max(X,MI).
/* nodo con solo hijo derecho */
mayor(X,M) :- \+ izquierdo(X,_), derecho(X,Z), mayor(Z,MD), M is max(X,MD).






