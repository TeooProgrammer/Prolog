/*Definir el predicado fue_presidente(X,Y) que es cierto si la persona X era presidente en el año Y.
Para esto utilizar los hechos presidencia(nombre_presidente,año_inicio,año_fin). */

presidencia(juan, 2000, 2004).
presidencia(ana, 2004, 2008).
presidencia(carlos, 2008, 2012).
presidencia(maria, 2012, 2016).

fue_presidente(X,Y) :- presidencia(X, Inicio, Fin), Y >= Inicio, Y =<Fin.
