/* 0, si x <= 10.
1, si 10 < x <= 20.
2, si x >20. */
fun(X,Resultado) :- X =< 10, Resultado is 0, !.
fun(X,Resultado):- X > 10, X =< 20, Resultado is 1, !.
fun(X,Resultado):- X > 20, Resul tado is 2, !.
