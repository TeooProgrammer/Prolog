%trabaja(Persona, Empresa, Sueldo).

trabaja(ana, empresa1, 800).
trabaja(luis, empresa2, 1200).
trabaja(maria, empresa1, 1500).
trabaja(pedro, empresa3, 900).
trabaja(juan, empresa2, 1800).
trabaja(laura, empresa1, 1100).

/* 1. Definir una regla sueldoAlto(X) que determine qué personas ganan más de 1000. */
sueldoAlto(X) :- trabaja(X,_, S), S > 1000.
/* 2. Definir una regla companeros(X,Y) que determine si dos personas trabajan en la misma empresa. */
companeros(X,Y) :- trabaja(X,E,_), trabaja(Y, E,_), X \= Y.