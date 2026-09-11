/*  predicado densidad(p, d) que calcule la densidad d que tiene la provincia p.
 (densidad=poblacion/superficie). */
poblacion(provincia, poblacion).
superficie(provincia, superficie).

poblacion(provincia_a, 100000).
poblacion(provincia_b, 250000).
poblacion(provincia_c, 500000).
superficie(provincia_a, 10000).
superficie(provincia_b, 20000).
superficie(provincia_c, 25000).

densidad(P,D) :- poblacion(P, POB), superficie(P, SUB), D is POB / SUB.