/* Definir un predicado potencia(B,E,R) que calcule en R el resultado de elevar una base B a un exponente E, utilizando recursividad. */

potencia(_, 0, 1).
potencia(B, E, R) :- E > 0, E1 is E - 1, potencia(B, E1, R1), R is B * R1.