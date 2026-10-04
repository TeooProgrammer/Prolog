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
preorden(X) :- write(X), write(' '), izquierdo(X,Y), derecho(X,Z), preorden(Y), preorden(Z).
/* caso con solo hijo izquierdo*/
preorden(X) :- write(X), write(' '), izquierdo(X,Y), \+ derecho(X,_), preorden(Y).
/* caso con solo hijo derecho */
preorden(X) :- write(X), write(' '), \+ izquierdo(X,_), derecho(X,Z), preorden(Z).

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

/*sin terminaaaaaaaaaaaaaaaaaaaaar*/






