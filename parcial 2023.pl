/* 1. Los hechos, lpso(lenguaje, so) indican para los diversos lenguajes de programación en qué sistema operativo están disponibles. Por ejemplo, lpso(java, linux) significa que el lenguaje java está disponible para el sistema operativo linux. En la base de hechos algunos lenguajes están disponibles en más de un sistemas operativos.
Definir una base que tenga entre 7 y 10 hechos. */
lpso(java, linux).
lpso(java, windows).
lpso(java, ios).
lpso(php, linux).
lpso(php, windows).
lpso(html, ios).
lpso(html, windows).
lpso(python, windows).

/*Escriba una consulta para obtener los lenguajes disponibles para windows. */
mostrar(Y):-lpso(X,Y), write(X).
? - lpso(X,windows).
/*(Lo ejecuto de la forma: “mostrar(windows).”)

/* B) Escriba una regla para obtener los lenguajes que están disponibles en más de un sistema operativo. */
varios_so(X):- lpso(X,Y), lpso(X,Z), Y\=Z.
/* (Lo ejecuto de la forma: “varios_so(‘lenguaje’).”) */
/* correcion de ejecución: "varios_so(X). /*

/* Realizar un predicado que separe una lista en dos listas a partir de un numero Z, donde en una lista están los mayores a a Z y en la otra los menores a Z.
separar(LISTA, Z, LISTAMAYOR, LISTAMENOR). */

separar_z([],_,_,_).
separar_z([X|L],Z,[X|MAY],MEN) :- X >= Z, separar_z(L,Z,MAY,MEN).
separar_z([X|L],Z,MAY,[X|MEN]) :- X < Z, separar_z(L,Z,MAY,MEN).

/* correción 
separar_z([],_,[],[]).
separar_z([X|L],Z,[X|MAY],MEN) :- X > Z, separar_z(L,Z,MAY,MEN).
separar_z([X|L],Z,MAY,[X|MEN]) :- X < Z, separar_z(L,Z,MAY,MEN). */


/*Ejemplo de consulta: separar_z([1,2,3,5,2,4,6,-1,0], 5,MAY,MEN). */

/* 3. Realizar un predicado para eliminar los elementos consecutivos repetidos de una lista.
eliminar(LISTA1, LISTA2).
?- eliminar([1, 2, 2, 5, 5, 5, c, c, c, c, 2, 2], L).
L = [1, 2, 5, c, 2] */

/* caso base extra: eliminar([], []). */
eliminar([X],[X]).
eliminar([X,X|L],Z):- eliminar([X|L],Z).
eliminar([X,Y|L2],[X|Z]):- X\=Y, eliminar([Y|L2],Z).
/* Consulta: eliminar([1, 2, 2, 5, 5, 5, c, c, c, c, 2, 2], L).*/

