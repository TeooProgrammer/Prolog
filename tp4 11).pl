/* mplementar la siguiente función recursiva para calcular el módulo:
m mod n m, si m < n
(m-n) mod n, si m >= n */

mod(M,N, R) :- M<N, R is M.
mod(M,N,R) :- M >= N, M1 is M - N, mod(M1,N,R).