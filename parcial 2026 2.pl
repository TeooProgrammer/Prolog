alumno(juan, 20, sistemas).
alumno(maria, 22, sistemas).
alumno(pedro, 19, matematica).
alumno(marcela,21,matematica).
materia(prolog, 3).
materia(java, 1).
materia(seminario_moviles,4).
materia(analisis_uno,1).
materia(analisis_dos,2).
cursa(juan, prolog).
cursa(maria, java).
cursa(maria,seminario_moviles).
cursa(luis,analisis_dos).
cursa(pedro, prolog).


/* companeros(X,Y), dos alumnos que cursan la misma materia */
companeros(X,Y) :- cursa(X,M), cursa(Y,M), X \= Y.

/* alumno(avanzado(X), alumno que cursa una materia de año >= 2 */
alumno_avanzado(X) :- alumno(X,_,_), cursa(X, M), materia(M, A), A >= 2.

/* 18 ?- companeros(X,Y).
X = juan,
Y = pedro . */

/* 20 ?- alumno_avanzado(X).
X = juan ;
X = maria ;
X = pedro ;
false. */

promedio(X, Y, Z, R) :- R is (X + Y +Z) / 3, R >= 6, write('Aprobado').
promedio(X, Y, Z, R) :- R is (X +Y + Z) / 3, R < 6, write('Desaprobado').

/* alumno_avanzado(X) :- materia(_,), X >= 2. */
