/* ejercicio de bhaskara */
bhaskara(A, B, C, X1, X2) :- D is B * B - 4 * A * C, X1 is (-B + sqrt(D)) / (2 * A),
X2 is (-B - sqrt(D)) / (2 * A).