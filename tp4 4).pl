/* Realizar un programa recursivo que en base a un número imprima por pantalla un triángulo. Por
ejemplo si el número es 3 debería imprimir: */

inicio() :- write('Ingrese un numero: ') , read(N), num(N).
num(0).
num(N) :- N1 is N-1, num(N1), triangulo(N), nl.
triangulo(0).
triangulo(N) :- write('*'), N1 is N-1, triangulo(N1).
