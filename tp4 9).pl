sumatoria(1,1) :- !.
sumatoria(N,S) :- N1 is N-1, sumatoria(N1,S1), S is N+S1.
/* sin el cut prolog seguiría probando la recursividad, lo que daria un bucle infinito */