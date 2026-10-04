%edad(nombre,años).
edad(lourdes,1).
edad(danna, 2).
edad(ana, 5).
edad(isabella, 12).
edad(micaela, 27).
edad(pedro, 18).
edad(ramón, 38).
edad(jorge, 55).
edad(pablo, 71).
edad(julia, 80).

bebe(X) :- edad(X,E), E =< 2.
niño(X) :- edad(X,E), E > 2, E < 13.
adulto(X) :- edad(X,E), E >= 21, E < 70.

/* 1. Definir las reglas adolescente (de 14 a 20 años) y adulto mayor (más de 70 años). */
adolescente(X) :- edad(X,E), E >= 14, E =< 20.
adulto_mayor(X) :- edad(X,E), E > 70.

/* 2. Representar como consultas las siguientes preguntas y mostrar cual sería el resultado en pantalla
a. Qué edad tiene isabella?, quién tiene 18 años?, quien es bebé? */

/* a. 23 ?- edad(isabella, E).
E = 12.
b. ?- edad(X,18).
X = pedro.
c. ?- bebe(X).
X = lourdes ;
X = danna . */





