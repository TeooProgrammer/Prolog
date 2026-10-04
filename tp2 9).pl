/*Escribir un programa que calcule el precio de venta al por menor, a partir del precio de venta al por
mayor. (precio al por menor = precio al por mayor + ganancia) usando la siguientes convenciones para
calcular la ganancia:
precio ≤ $100 : 20% ganancia
$100 < precio ≤ $1000 : 15% ganancia
precio > $1000 : 10% ganancia */

precio_menor(P,V) :- P =< 100, G is P * 20 / 100, V is P + G.
precio_menor(P, V) :- P > 100, P =< 1000, G is P * 15 / 100, V is P + G.
precio_menor(P, V) :- P > 1000, G is P * 10 / 100, V is P + G.