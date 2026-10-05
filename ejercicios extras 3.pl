venta(cliente(ramon, producto(silla,6), 12,8,2016)).
venta(cliente(ana, producto(mesa,3), 12,8,2016)).
venta(cliente(ramon, producto(mesa,2), 15,8,2016)).
venta(cliente(luis, producto(silla,4), 12,8,2016)).

/* Definir un predicado vendioProducto(Cliente, Producto, Cantidad) que permita consultar qué productos compró un cliente y qué cantidad compró. */
vendioProducto(Cliente, P, C) :- venta(cliente(Cliente, producto(P, C), _, _, _)).