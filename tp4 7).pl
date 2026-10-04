/* consultar: hacer(4), hacer(9). hacer(X).*/

hacer(3) :- !.
hacer(6).
hacer(X) :- Y is X-1, hacer(Y), write(Y).