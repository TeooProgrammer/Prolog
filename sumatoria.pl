/* Suma recursivamente los números desde 1 hasta N. */

sumatoria(0, 0).
sumatoria(N, S) :- N > 0, N1 is N - 1, sumatoria(N1, S1), S is S1 + N.