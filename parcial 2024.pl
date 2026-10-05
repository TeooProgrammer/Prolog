%edad(nombre,años).
edad(lourdes,1).
edad(danna, 2).
edad(ana, 5).
edad(isabella, 12).
edad(micaela, 27).
edad(pedro, 18).
edad(ramon, 38).
edad(jorge, 55).
edad(pablo, 71).
edad(julia, 80).

bebe(X) :- edad(X,E), E =< 2.
nino(X) :- edad(X,E), E > 2, E < 13.
adulto(X) :- edad(X,E), E >= 21, E < 70.

puedeConducir(X) :- adulto(X), obtenerLicencia(X).

/* 1. Definir las reglas adolescente (de 14 a 20 años) y adulto mayor (más de 70 años). (1,5 pto.) */
adolescente(X) :- edad(X,E), E >= 14, E =< 20.
adulto_mayor(X) :- edad(X,E), E > 70.

/* 2. Representar como consultas las siguientes preguntas y mostrar cual sería el resultado en pantalla (1,5 pto.)
a. Qué edad tiene isabella?, quién tiene 18 años?, quien es bebé?  */

/* a. 23 ?- edad(isabella, E).
E = 12.
b. ?- edad(X,18).
X = pedro.
c. ?- bebe(X).
X = lourdes ;
X = danna . */

/* 3. Definir la regla obtenerLicencia(X), que indique si X puede obtener la licencia de conducir sabiendo
que la edad mínima es 17 y la máxima 69. Mostrar la salida de la consulta.
Graficar el árbol de búsqueda, indicar las sustituciones y los backtracking. (3 ptos.) */

obtenerLicencia(X) :- edad(X,E), E >= 17, E =< 69.

/* 4. Escribir la función contarValores(L,V), que retorne la cantidad de elementos mayores que V sobre la lista L. (2 ptos.) */

contarValores([], _, 0).
contarValores([X|Y], C, N) :- X > C, contarValores(Y, C, N1), N is N1 + 1.
contarValores([X|Y], C, N) :- X =< C, contarValores(Y,C,N).

/* 5. Describir lo que hace el siguiente predicado. (2 ptos.) */

adivina(X,L1,L2)
adivina(X,[],[]).
adivina(X,[Y|M],[Y|S]):- X =< Y, adivina(Y,M,S).
adivina(X,[Y|M],S):- adivina(X,M,S).

/* adivina es un predicado recursivo que compara X con los elementos de una lista y los guarda en otra cuando X es menor o igual a dichos elementos.