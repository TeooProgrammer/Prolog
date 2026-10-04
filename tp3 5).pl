/* ejercicio de bhaskara */
iniciar() :-
    write("Ingresar coeficientes de la ecuacion de segundo grado: "),
    write("\na: "), read(A),
    write("\nb: "), read(B),
    write("\nc: "), read(C), calcular(A,B,C).

calcular(A,B,C) :-
    write(A), write("x^2 + "),
    write(B), write("x + "),
    write(C), write(" = 0"), nl,
    ((B*B < 4*A*C, write("No existe solucion en los reales."));
    (B*B =:= 4*A*C,Resultado is -B/(2*A), write(Resultado));
    (Resultado1 is (-B + sqrt(B*B - 4*A*C))/(2*A),
    Resultado2 is (-B - sqrt(B*B - 4*A*C))/(2*A),
    write(Resultado1), write(" y "), write(Resultado2))).