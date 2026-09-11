/*horoscopo(signo, diaInicio, mesInicio, diaFin, mesFin). */

horoscopo(aries,21,3,20,4).
horoscopo(tauro,21,4,20,5).
horoscopo(geminis,21,5,20,6).
horoscopo(cancer,21,6,22,7).
horoscopo(leo,23,7,22,8).
horoscopo(virgo,23,8,22,9).
horoscopo(libra,23,9,22,10).
horoscopo(escorpio,23,10,21,11).
horoscopo(sagitario,22,11,21,12).
horoscopo(capricornio,22,12,19,1).
horoscopo(acuario,20,1,18,2).
horoscopo(piscis,19,2,20,3).

signo(D,M,S) :- horoscopo (S,DiaInicio,MesInicio, DiaFin, MesFin),
(M =:= MesInicio, D >= DiaInicio ; M =:= MesFin, D =< DiaFin).

