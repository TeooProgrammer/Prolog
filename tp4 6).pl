/* Implementar la relación suma_digitos(N, S), dónde S es la suma de los dígitos del número N. */
suma_digitos(0,0).
suma_digitos(N,S) :- Digito is N mod 10, N1  is N // 10, suma_digitos(N1,N2), S is Digito + N2.