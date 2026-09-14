promedio() :- write('Ingrese'), read(X), sumar(X,1).
sumar(T,N) :- write('Ingrese'), read(X), sumatoria(T,N,X).
sumatoria(T,N,0) :- M is T/N, write(M).
sumatoria(T,N,X) :- X =\= 0, T1 is X+T, N1 is N +1, sumar(T1, N1).