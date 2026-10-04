/* Escribir un programa que cuente el número de ocurrencias de un carácter en una lista de caracteres.

Donde N es el número de ocurrencias del carácter C en la lista X.
Explique cómo puede ser usado para determinar si una lista tiene exactamente 3 ocurrencias del carácter
'a' */

ocurrencias([], _, 0).
ocurrencias([X|Y], C, N) :- X = C, ocurrencias(Y, C, N1), N is N1 + 1.
ocurrencias([X|Y], C, N) :- X \= C, ocurrencias(Y, C, N).   