%curso(Nombre_profesor,Numero_curso).
%estudiante(Nombre_estudiante,Numero_de_curso).
%alumno_de(Nombre_estudiante, Nombre_profesor).

curso(ana, 1).
curso(carlos, 2).
curso(maria, 3).
estudiante(juan, 1).
estudiante(pedro, 1).
estudiante(laura, 2).
estudiante(sofia, 2).
estudiante(martin, 3).

alumno_de(X,Y) :- estudiante(X,Z), curso(Y,Z).

