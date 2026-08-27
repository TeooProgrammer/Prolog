%transporte(Ciudad_origen, Ciudad_destino, Costo).
%alojamientoXdia(Nombre_ciudad, Costo).
%costo_viaje(Ciudad_origen, Ciudad_destino, Cantidad_dias, Costo_total).

transporte(buenos_aires, cordoba, 50000).
transporte(buenos_aires, mendoza, 70000).
transporte(cordoba, salta, 45000).
transporte(mendoza, salta, 60000).
alojamientoXdia(buenos_aires, 30000).
alojamientoXdia(cordoba, 25000).
alojamientoXdia(mendoza, 35000).
alojamientoXdia(salta, 20000).

%W(ciudad origen), X(ciudad destino), Y(costo transporte), Z(costo alojamiento).

costo_viaje(W,X,Y,Z) :- transporte(W,X,Y), alojamientoXdia(X,Z).

/*  */