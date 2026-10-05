/* Definir un predicado factorial(N,F) que calcule recursivamente el factorial de un número N. */

factorial(0, 1).
factorial(N, F) :- N > 0, N1 is N - 1, factorial(N1, F1), F is N * F1.