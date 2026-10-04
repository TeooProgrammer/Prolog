/*Escribir un programa recursivo tabla(N) que cuando es llamado produce la multiplicación de la tabla
para N */
tabla(11,_).
tabla(N) :- tabla(1,N).
tabla(C,N) :- R is C * N, write(C), write('*'), write(N), write('='), writeln(R), C1 is C + 1, tabla(C1,N).