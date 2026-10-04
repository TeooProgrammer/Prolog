desempleado(gomez).
desempleado(ramirez).
desempleado(garcia).
sueldo(morales,4000).
sueldo(aguirre,6000).
impuesto(X,N) :- desempleado(X), !, fail.
impuesto(X,N) :- sueldo(X,S), N is X * 0,10.