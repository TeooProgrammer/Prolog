:- multifile user:prolog_trace_interception/4.

:- dynamic evento_guardado/3.
:- dynamic objetivo_simbolico/3.
:- dynamic evento_frame/6.
:- dynamic frame_simbolico/3.
:- dynamic invocacion_logica/7.
:- dynamic regla_por_frame/4.
:- dynamic objetivo_por_frame/4.
:- dynamic invocacion_activa/2.
:- dynamic contador_invocacion/1.
:- dynamic evento_invocacion/4.


% =========================================================
% INTERCEPTOR DEL TRACER DE SWI
% =========================================================

user:prolog_trace_interception(Port, Frame, Choice, continue) :-
    nb_current(visualizando, true),
    prolog_frame_attribute(Frame, goal, Goal),
    evento_interesante(Goal),
    !,

    registrar_evento_frame(
        Port,
        Frame,
        Choice,
        Goal
    ),

    procesar_evento(
        Port,
        Frame,
        Goal
    ).

user:prolog_trace_interception(_, _, _, continue).


% =========================================================
% REGISTRAR INFORMACION ESTRUCTURAL DEL FRAME
% =========================================================

registrar_evento_frame(Port, Frame, Choice, Goal) :-
    obtener_parent(Frame, Parent),
    obtener_level(Frame, Level),

    copy_term(Goal, GoalCopia),

    assertz(
        evento_frame(
            Frame,
            Parent,
            Level,
            Port,
            GoalCopia,
            Choice
        )
    ).


obtener_parent(Frame, Parent) :-
    (
        prolog_frame_attribute(Frame, parent, Parent0)
    ->
        Parent = Parent0
    ;
        Parent = ninguno
    ).


obtener_level(Frame, Level) :-
    (
        prolog_frame_attribute(Frame, level, Level0)
    ->
        Level = Level0
    ;
        Level = desconocido
    ).


% =========================================================
% PROCESAMIENTO DE EVENTOS
% =========================================================

procesar_evento(call, Frame, Goal) :-
    !,

    copy_term(Goal, Copia),
    assertz(evento_guardado(call, Copia, sin_clausula)),

    % Cada CALL representa una nueva invocacion logica, aunque SWI
    % reutilice el mismo numero de Frame para otro objetivo despues.
    registrar_invocacion_call(Frame, Goal, IdInvocacion),
    assertz(evento_invocacion(IdInvocacion, call, Frame, Copia)),

    % Se conserva la asociacion antigua solo por compatibilidad con
    % la salida ya probada. simbolico_del_frame/3 prioriza la nueva capa.
    asociar_frame_simbolico(Frame, Goal),

    mostrar_call_didactico(Frame, Goal).


procesar_evento(unify, Frame, Goal) :-
    !,

    obtener_info_clausula(
        Frame,
        ClausulaCompilada,
        Archivo,
        Linea
    ),

    copy_term(Goal, CopiaGoal),

    assertz(
        evento_guardado(
            unify,
            CopiaGoal,
            ClausulaCompilada
        )
    ),

    registrar_evento_invocacion_activa(Frame, unify, CopiaGoal),

    procesar_unificacion(
        Frame,
        Goal,
        Archivo,
        Linea
    ).


procesar_evento(exit, Frame, Goal) :-
    !,

    copy_term(Goal, Copia),

    assertz(
        evento_guardado(
            exit,
            Copia,
            sin_clausula
        )
    ),

    registrar_evento_invocacion_activa(Frame, exit, Copia),
    mostrar_exito(Goal).


procesar_evento(fail, Frame, Goal) :-
    !,

    copy_term(Goal, Copia),

    assertz(
        evento_guardado(
            fail,
            Copia,
            sin_clausula
        )
    ),

    registrar_evento_invocacion_activa(Frame, fail, Copia),
    mostrar_fallo(Goal).


procesar_evento(redo(_), Frame, Goal) :-
    !,

    copy_term(Goal, Copia),

    assertz(
        evento_guardado(
            redo,
            Copia,
            sin_clausula
        )
    ),

    registrar_evento_invocacion_activa(Frame, redo, Copia),

    mostrar_backtracking(
        Frame,
        Goal
    ).


procesar_evento(_, _, _).


registrar_evento_invocacion_activa(Frame, Puerto, Goal) :-
    invocacion_activa(Frame, IdInvocacion),
    !,
    copy_term(Goal, GoalCopia),
    assertz(
        evento_invocacion(
            IdInvocacion,
            Puerto,
            Frame,
            GoalCopia
        )
    ).

registrar_evento_invocacion_activa(_, _, _).


% =========================================================
% ASOCIAR FRAME REAL CON OBJETIVO SIMBOLICO
%
% Por ahora usamos los objetivos fuente disponibles,
% pero la asociación queda almacenada POR FRAME.
% =========================================================

asociar_frame_simbolico(Frame, _Goal) :-
    frame_simbolico(Frame, _, _),
    !.

asociar_frame_simbolico(Frame, Goal) :-
    objetivo_simbolico_para(
        Goal,
        Simbolico,
        Variables
    ),
    !,

    copy_term(
        Simbolico-Variables,
        SimbolicoCopia-VariablesCopia
    ),

    assertz(
        frame_simbolico(
            Frame,
            SimbolicoCopia,
            VariablesCopia
        )
    ).

asociar_frame_simbolico(_, _).


% =========================================================
% OBTENER OBJETIVO SIMBOLICO DEL FRAME
% =========================================================

simbolico_del_frame(
    Frame,
    Simbolico,
    Variables
) :-
    % La invocacion activa tiene prioridad. Esto evita que un Frame
    % reutilizado por SWI conserve el objetivo simbolico anterior.
    invocacion_activa(Frame, IdInvocacion),
    invocacion_logica(
        IdInvocacion,
        Frame,
        _Parent,
        _Level,
        _GoalReal,
        Simbolico,
        Variables
    ),
    !.

simbolico_del_frame(
    Frame,
    Simbolico,
    Variables
) :-
    % Fallback de compatibilidad con la version anterior.
    frame_simbolico(
        Frame,
        Simbolico,
        Variables
    ),
    !.


% =========================================================
% INVOCACIONES LOGICAS
%
% SWI puede reutilizar un mismo Frame para objetivos distintos.
% Por eso cada puerto CALL recibe un ID propio. REDO, UNIFY, EXIT y
% FAIL se pueden relacionar con la invocacion activa de ese Frame.
% =========================================================

registrar_invocacion_call(Frame, Goal, Id) :-
    siguiente_id_invocacion(Id),
    obtener_parent(Frame, Parent),
    obtener_level(Frame, Level),

    objetivo_simbolico_de_call(
        Frame,
        Goal,
        Simbolico,
        Variables
    ),

    copy_term(
        Goal-Simbolico-Variables,
        GoalCopia-SimbolicoCopia-VariablesCopia
    ),

    assertz(
        invocacion_logica(
            Id,
            Frame,
            Parent,
            Level,
            GoalCopia,
            SimbolicoCopia,
            VariablesCopia
        )
    ),

    % Un nuevo CALL sobre el mismo Frame reemplaza solamente la
    % invocacion activa; el historial anterior queda guardado.
    retractall(invocacion_activa(Frame, _)),
    assertz(invocacion_activa(Frame, Id)).


siguiente_id_invocacion(Id) :-
    (
        retract(contador_invocacion(Anterior))
    ->
        true
    ;
        Anterior = 0
    ),

    Id is Anterior + 1,
    assertz(contador_invocacion(Id)).


objetivo_simbolico_de_call(Frame, Goal, Simbolico, Variables) :-
    obtener_parent(Frame, Parent),
    objetivo_por_frame(Parent, _N, Simbolico0, Variables0),
    mismo_predicado(Goal, Simbolico0),
    !,
    copy_term(Simbolico0-Variables0, Simbolico-Variables).

objetivo_simbolico_de_call(_Frame, Goal, Simbolico, Variables) :-
    objetivo_simbolico_para(Goal, Simbolico0, Variables0),
    !,
    copy_term(Simbolico0-Variables0, Simbolico-Variables).

objetivo_simbolico_de_call(_Frame, Goal, Simbolico, []) :-
    copy_term(Goal, Simbolico).


mostrar_invocaciones :-
    format('~n========================================~n'),
    format(' INVOCACIONES LOGICAS CAPTURADAS~n'),
    format('========================================~n'),

    forall(
        invocacion_logica(
            Id,
            Frame,
            Parent,
            Level,
            GoalReal,
            Simbolico,
            Variables
        ),
        (
            format(
                'ID: ~w | Frame: ~w | Parent: ~w | Nivel: ~w~n',
                [Id, Frame, Parent, Level]
            ),
            format('  REAL:      ~q~n', [GoalReal]),
            format('  SIMBOLICO: '),
            escribir_con_nombres(Simbolico, Variables),
            nl
        )
    ).


% =========================================================
% CALL DIDACTICO
% =========================================================

mostrar_call_didactico(Frame, Goal) :-
    (
        simbolico_del_frame(
            Frame,
            Simbolico,
            Variables
        )
    ->
        format('~nOBJETIVO      '),

        escribir_con_nombres(
            Simbolico,
            Variables
        ),

        nl
    ;
        format(
            '~nOBJETIVO      ~q~n',
            [Goal]
        )
    ).


% =========================================================
% PROCESAR UNIFICACION
% =========================================================

procesar_unificacion(
    Frame,
    Goal,
    Archivo,
    Linea
) :-
    (
        leer_clausula_fuente(
            Archivo,
            Linea,
            TerminoFuente,
            VariablesFuente
        )
    ->
        true
    ;
        TerminoFuente = no_disponible,
        VariablesFuente = []
    ),

    registrar_regla_si_corresponde(
        Frame,
        TerminoFuente,
        VariablesFuente
    ),

    mostrar_unificacion_didactica(
        Frame,
        Goal,
        TerminoFuente
    ).


% =========================================================
% REGISTRAR REGLA Y SUS OBJETIVOS SIMBOLICOS
% =========================================================

registrar_regla_si_corresponde(
    Frame,
    (Cabeza :- Cuerpo),
    Variables
) :-
    !,

    % Contexto simbolico propio de ESTA invocacion/regla.
    retractall(regla_por_frame(Frame, _, _, _)),
    copy_term(Cabeza-Cuerpo-Variables, CabezaPF-CuerpoPF-VariablesPF),
    assertz(regla_por_frame(Frame, CabezaPF, CuerpoPF, VariablesPF)),

    retractall(objetivo_por_frame(Frame, _, _, _)),
    cuerpo_a_lista(Cuerpo, ObjetivosPF),
    registrar_objetivos_frame(Frame, ObjetivosPF, Variables, 1),

    % Asociamos también el frame de la regla con
    % su cabeza fuente.
    (
        frame_simbolico(Frame, _, _)
    ->
        true
    ;
        copy_term(
            Cabeza-Variables,
            CabezaCopia-VariablesCabeza
        ),

        assertz(
            frame_simbolico(
                Frame,
                CabezaCopia,
                VariablesCabeza
            )
        )
    ),

    retractall(
        objetivo_simbolico(_, _, _)
    ),

    cuerpo_a_lista(
        Cuerpo,
        Objetivos
    ),

    registrar_objetivos(
        Objetivos,
        Variables,
        1
    ),

    format('~nREGLA USADA~n'),
    format('  '),

    escribir_con_nombres(
        (Cabeza :- Cuerpo),
        Variables
    ),

    nl,

    format('~nOBJETIVOS DE LA REGLA~n'),

    mostrar_objetivos_regla(
        Objetivos,
        Variables,
        1
    ).

registrar_regla_si_corresponde(
    _,
    _,
    _
).


% =========================================================
% CUERPO -> LISTA DE OBJETIVOS
% =========================================================

cuerpo_a_lista((A, B), Lista) :-
    !,

    cuerpo_a_lista(A, LA),
    cuerpo_a_lista(B, LB),

    append(LA, LB, Lista).

cuerpo_a_lista(A, [A]).


% =========================================================
% REGISTRAR OBJETIVOS SIMBOLICOS
% =========================================================

registrar_objetivos_frame(_, [], _, _).
registrar_objetivos_frame(Frame, [Objetivo|Resto], Variables, N) :-
    copy_term(Objetivo-Variables, OC-VC),
    assertz(objetivo_por_frame(Frame, N, OC, VC)),
    N2 is N + 1,
    registrar_objetivos_frame(Frame, Resto, Variables, N2).

registrar_objetivos([], _, _).

registrar_objetivos(
    [Objetivo | Resto],
    Variables,
    N
) :-
    copy_term(
        Objetivo-Variables,
        ObjetivoCopia-VariablesCopia
    ),

    assertz(
        objetivo_simbolico(
            N,
            ObjetivoCopia,
            VariablesCopia
        )
    ),

    N2 is N + 1,

    registrar_objetivos(
        Resto,
        Variables,
        N2
    ).


mostrar_objetivos_regla([], _, _).

mostrar_objetivos_regla(
    [Objetivo | Resto],
    Variables,
    N
) :-
    format('  ~w. ', [N]),

    escribir_con_nombres(
        Objetivo,
        Variables
    ),

    nl,

    N2 is N + 1,

    mostrar_objetivos_regla(
        Resto,
        Variables,
        N2
    ).


% =========================================================
% BUSCAR OBJETIVO SIMBOLICO
%
% Esto sigue sirviendo como puente para crear la asociación
% inicial. Después queda almacenada en frame_simbolico/3.
% =========================================================

objetivo_simbolico_para(
    Goal,
    Simbolico,
    Variables
) :-
    functor(
        Goal,
        Nombre,
        Aridad
    ),

    objetivo_simbolico(
        _,
        Simbolico,
        Variables
    ),

    callable(Simbolico),

    functor(
        Simbolico,
        Nombre,
        Aridad
    ),

    !.


% =========================================================
% UNIFICACION DIDACTICA
% =========================================================

mostrar_unificacion_didactica(
    Frame,
    Goal,
    TerminoFuente
) :-
    (
        simbolico_del_frame(
            Frame,
            Simbolico,
            VariablesSimbolicas
        ),

        es_hecho(
            TerminoFuente,
            Hecho
        ),

        mismo_predicado(
            Simbolico,
            Hecho
        )
    ->
        copy_term(
            Simbolico-VariablesSimbolicas,
            SimbolicoCopia-VariablesCopia
        ),

        copy_term(
            Hecho,
            HechoCopia
        ),

        format('~nUNIFICACION~n'),

        format('  '),

        escribir_con_nombres(
            SimbolicoCopia,
            VariablesCopia
        ),

        format(
            '~n= ~q~n',
            [HechoCopia]
        ),

        (
            SimbolicoCopia = HechoCopia
        ->
            format('~nSUSTITUCION~n'),

            mostrar_sustituciones(
                VariablesCopia
            )
        ;
            format(
                '~n  NO UNIFICA~n'
            )
        )

    ;
        (
            TerminoFuente = (_ :- _)
        ->
            true
        ;
            format(
                '~nUNIFICACION   ~q~n',
                [Goal]
            )
        )
    ).


% =========================================================
% HECHOS / PREDICADOS
% =========================================================

es_hecho(Termino, Termino) :-
    Termino \= (_ :- _).


mismo_predicado(A, B) :-
    callable(A),
    callable(B),

    functor(A, Nombre, Aridad),
    functor(B, Nombre, Aridad).


% =========================================================
% SUSTITUCIONES
% =========================================================

mostrar_sustituciones([]) :-
    format('  {}~n').

mostrar_sustituciones(Variables) :-
    Variables \== [],

    format('  { '),

    mostrar_pares_sustitucion(
        Variables
    ),

    format(' }~n').


mostrar_pares_sustitucion(
    [Nombre=Valor]
) :-
    !,

    format(
        '~w = ~q',
        [Nombre, Valor]
    ).


mostrar_pares_sustitucion(
    [Nombre=Valor | Resto]
) :-
    format(
        '~w = ~q, ',
        [Nombre, Valor]
    ),

    mostrar_pares_sustitucion(
        Resto
    ).


% =========================================================
% EXITO / FALLO / BACKTRACKING
% =========================================================

mostrar_exito(Goal) :-
    es_comparacion(Goal),
    !,

    format(
        '  EXITO       ~q  [SI]~n',
        [Goal]
    ).

mostrar_exito(_).


mostrar_fallo(Goal) :-
    format(
        '  FALLO       ~q  [NO]~n',
        [Goal]
    ).


mostrar_backtracking(Frame, Goal) :-
    obtener_level(Frame, Level),

    format(
        '~n  <--- BACKTRACKING desde ~q',
        [Goal]
    ),

    format(
        '  [nivel ~w]~n',
        [Level]
    ).


es_comparacion(Goal) :-
    callable(Goal),

    functor(
        Goal,
        Op,
        2
    ),

    member(
        Op,
        [>=, =<, >, <, =:=, =\=]
    ).


% =========================================================
% INFORMACION DE CLAUSULA DESDE EL FRAME
% =========================================================

obtener_info_clausula(
    Frame,
    Clausula,
    Archivo,
    Linea
) :-
    prolog_frame_attribute(
        Frame,
        clause,
        ClauseRef
    ),
    !,

    recuperar_clausula(
        ClauseRef,
        Clausula
    ),

    (
        clause_property(
            ClauseRef,
            file(Archivo)
        )
    ->
        true
    ;
        Archivo = no_disponible
    ),

    (
        clause_property(
            ClauseRef,
            line_count(Linea)
        )
    ->
        true
    ;
        Linea = no_disponible
    ).

obtener_info_clausula(
    _,
    no_disponible,
    no_disponible,
    no_disponible
).


recuperar_clausula(
    ClauseRef,
    Clausula
) :-
    catch(
        clause(
            Head,
            Body,
            ClauseRef
        ),
        _,
        fail
    ),
    !,

    copy_term(
        (Head :- Body),
        Clausula
    ).

recuperar_clausula(
    _,
    no_disponible
).


% =========================================================
% LEER FUENTE CONSERVANDO NOMBRES X, E, ETC.
% =========================================================

leer_clausula_fuente(
    no_disponible,
    _,
    _,
    _
) :-
    !,
    fail.

leer_clausula_fuente(
    _,
    no_disponible,
    _,
    _
) :-
    !,
    fail.

leer_clausula_fuente(
    Archivo,
    LineaBuscada,
    Termino,
    Variables
) :-
    setup_call_cleanup(
        open(
            Archivo,
            read,
            Stream,
            [encoding(utf8)]
        ),

        buscar_termino_fuente(
            Stream,
            LineaBuscada,
            Termino,
            Variables
        ),

        close(Stream)
    ).


buscar_termino_fuente(
    Stream,
    LineaBuscada,
    Termino,
    Variables
) :-
    stream_property(
        Stream,
        position(PosAntes)
    ),

    read_term(
        Stream,
        TerminoLeido,
        [
            variable_names(VarsLeidas),
            syntax_errors(error)
        ]
    ),

    TerminoLeido \== end_of_file,

    stream_property(
        Stream,
        position(PosDespues)
    ),

    stream_position_data(
        line_count,
        PosAntes,
        InicioRaw
    ),

    stream_position_data(
        line_count,
        PosDespues,
        FinRaw
    ),

    Inicio is InicioRaw + 1,
    Fin is FinRaw + 1,

    (
        LineaBuscada >= Inicio,
        LineaBuscada < Fin
    ->
        Termino = TerminoLeido,
        Variables = VarsLeidas

    ;
        buscar_termino_fuente(
            Stream,
            LineaBuscada,
            Termino,
            Variables
        )
    ).


% =========================================================
% ESCRIBIR CON NOMBRES ORIGINALES
% =========================================================

escribir_con_nombres(
    Termino,
    Variables
) :-
    write_term(
        Termino,
        [
            quoted(true),
            variable_names(Variables),
            numbervars(false)
        ]
    ).


% =========================================================
% MOSTRAR INFORMACION ESTRUCTURAL
%
% Este predicado nos permite inspeccionar los frames
% DESPUES de terminar la consulta.
% =========================================================

mostrar_frames :-
    format(
        '~n========================================~n'
    ),

    format(
        ' ESTRUCTURA DE FRAMES CAPTURADA~n'
    ),

    format(
        '========================================~n'
    ),

    forall(
        evento_frame(
            Frame,
            Parent,
            Level,
            Port,
            Goal,
            _Choice
        ),

        (
            format(
                'Frame: ~w | Parent: ~w | Nivel: ~w | ',
                [Frame, Parent, Level]
            ),

            format(
                '~q | ~q~n',
                [Port, Goal]
            )
        )
    ).


% =========================================================
% FILTRO
% =========================================================

evento_interesante(Goal) :-
    callable(Goal),

    functor(
        Goal,
        Nombre,
        _
    ),

    \+ predicado_visualizador(
        Nombre
    ).


predicado_visualizador(visualizar).
predicado_visualizador(ejecutar_todas).
predicado_visualizador(activar).
predicado_visualizador(desactivar).

predicado_visualizador(registrar_evento_frame).
predicado_visualizador(obtener_parent).
predicado_visualizador(obtener_level).

predicado_visualizador(procesar_evento).

predicado_visualizador(asociar_frame_simbolico).
predicado_visualizador(simbolico_del_frame).
predicado_visualizador(mostrar_call_didactico).

predicado_visualizador(procesar_unificacion).
predicado_visualizador(registrar_regla_si_corresponde).

predicado_visualizador(cuerpo_a_lista).
predicado_visualizador(registrar_objetivos).
predicado_visualizador(mostrar_objetivos_regla).
predicado_visualizador(objetivo_simbolico_para).

predicado_visualizador(mostrar_unificacion_didactica).
predicado_visualizador(es_hecho).
predicado_visualizador(mismo_predicado).

predicado_visualizador(mostrar_sustituciones).
predicado_visualizador(mostrar_pares_sustitucion).

predicado_visualizador(mostrar_exito).
predicado_visualizador(mostrar_fallo).
predicado_visualizador(mostrar_backtracking).
predicado_visualizador(es_comparacion).

predicado_visualizador(obtener_info_clausula).
predicado_visualizador(recuperar_clausula).

predicado_visualizador(leer_clausula_fuente).
predicado_visualizador(buscar_termino_fuente).
predicado_visualizador(escribir_con_nombres).

predicado_visualizador(mostrar_frames).

predicado_visualizador(evento_interesante).
predicado_visualizador(predicado_visualizador).

predicado_visualizador(evento_guardado).
predicado_visualizador(objetivo_simbolico).
predicado_visualizador(evento_frame).
predicado_visualizador(frame_simbolico).
predicado_visualizador(invocacion_logica).
predicado_visualizador(invocacion_activa).
predicado_visualizador(contador_invocacion).
predicado_visualizador(evento_invocacion).
predicado_visualizador(registrar_invocacion_call).
predicado_visualizador(siguiente_id_invocacion).
predicado_visualizador(objetivo_simbolico_de_call).
predicado_visualizador(registrar_evento_invocacion_activa).
predicado_visualizador(mostrar_invocaciones).

predicado_visualizador(format).
predicado_visualizador(fail).
predicado_visualizador(nb_setval).
predicado_visualizador(nb_current).
predicado_visualizador(visible).
predicado_visualizador(notrace).
predicado_visualizador(trace).
predicado_visualizador(nodebug).
predicado_visualizador(assertz).
predicado_visualizador(retractall).
predicado_visualizador(copy_term).
predicado_visualizador(clause).
predicado_visualizador(clause_property).
predicado_visualizador(catch).
predicado_visualizador(open).
predicado_visualizador(close).
predicado_visualizador(read_term).
predicado_visualizador(stream_property).
predicado_visualizador(stream_position_data).
predicado_visualizador(write_term).
predicado_visualizador(setup_call_cleanup).
predicado_visualizador(append).
predicado_visualizador(member).
predicado_visualizador(functor).
predicado_visualizador(callable).
predicado_visualizador(forall).


% =========================================================
% CONSULTA PRINCIPAL
% =========================================================

visualizar(Consulta) :-
    retractall(
        evento_guardado(_, _, _)
    ),

    retractall(
        objetivo_simbolico(_, _, _)
    ),

    retractall(
        evento_frame(_, _, _, _, _, _)
    ),

    retractall(
        frame_simbolico(_, _, _)
    ),

    retractall(regla_por_frame(_, _, _, _)),
    retractall(objetivo_por_frame(_, _, _, _)),

    retractall(
        invocacion_logica(_, _, _, _, _, _, _)
    ),

    retractall(
        invocacion_activa(_, _)
    ),

    retractall(
        contador_invocacion(_)
    ),

    retractall(
        evento_invocacion(_, _, _, _)
    ),

    assertz(contador_invocacion(0)),

    format(
        '~n========================================~n'
    ),

    format(
        ' RESOLUCION PROLOG~n'
    ),

    format(
        '========================================~n'
    ),

    format(
        'Consulta: ~q~n',
        [Consulta]
    ),

    setup_call_cleanup(
        activar,
        ejecutar_todas(Consulta),
        desactivar
    ).


% =========================================================
% ACTIVAR / DESACTIVAR TRACER
% =========================================================

activar :-
    nb_setval(
        visualizando,
        true
    ),

    visible(+unify),

    trace.


desactivar :-
    nb_setval(
        visualizando,
        false
    ),

    notrace,
    nodebug.


% =========================================================
% TODAS LAS SOLUCIONES
% =========================================================

ejecutar_todas(Consulta) :-
    (
        call(Consulta),

        format(
            '~n========================================~n'
        ),

        format(
            ' SOLUCION: ~q~n',
            [Consulta]
        ),

        format(
            '========================================~n'
        ),

        fail

    ;

        format(
            '~n========================================~n'
        ),

        format(
            ' FIN DE LA BUSQUEDA~n'
        ),

        format(
            '========================================~n'
        )
    ).

% =========================================================
% ARBOL DIDACTICO DE BUSQUEDA / BACKTRACKING - VERSION 2
%
% No interpreta Prolog por su cuenta: reorganiza los eventos reales
% capturados del tracer de SWI-Prolog para mostrarlos como ramas.
% =========================================================

:- dynamic contexto_rama_arbol/3.

mostrar_arbol :-
    retractall(contexto_rama_arbol(_,_,_)),
    format('~n========================================~n'),
    format(' ARBOL DE BUSQUEDA / BACKTRACKING~n'),
    format('========================================~n'),
    nivel_base_arbol(Base),
    mostrar_eventos_arbol(Base),
    format('========================================~n'),
    format(' LEYENDA: [OK] exito | [X] fallo | <--- backtracking~n'),
    format('========================================~n').

nivel_base_arbol(Base) :-
    evento_frame(_, _, Base, call, _, _), !.
nivel_base_arbol(0).

mostrar_eventos_arbol(Base) :-
    forall(
        evento_frame(Frame, Parent, Level, Port, Goal, _Choice),
        mostrar_evento_arbol(Base, Frame, Parent, Level, Port, Goal)
    ).

% CALL: el objetivo raiz se muestra como raiz. Los objetivos hermanos que
% aparecen despues de una unificacion se dibujan dentro de esa rama.
mostrar_evento_arbol(Base, Frame, Parent, Level, call, Goal) :- !,
    profundidad_visual(Base, Parent, Level, Prof),
    sangria_arbol(Prof),
    objetivo_arbol(Frame, Goal, Texto),
    format('|-- OBJETIVO: '),
    escribir_texto_arbol(Texto), nl.

% UNIFY: una unificacion por debajo de la raiz abre/actualiza una rama.
mostrar_evento_arbol(Base, Frame, Parent, Level, unify, Goal) :- !,
    profundidad_arbol(Base, Level, Prof0),
    ( Level > Base ->
        retractall(contexto_rama_arbol(Parent, Level, _)),
        assertz(contexto_rama_arbol(Parent, Level, Frame)),
        Prof is Prof0,
        sangria_arbol(Prof),
        format('|-- ALTERNATIVA: ~q', [Goal]),
        mostrar_sustitucion_arbol(Frame, Goal), nl
    ;
        % La unificacion de la consulta/regla raiz no es una alternativa
        true
    ).

% EXIT de comparacion = exito de una condicion.
mostrar_evento_arbol(Base, _Frame, Parent, Level, exit, Goal) :-
    es_comparacion(Goal), !,
    profundidad_visual(Base, Parent, Level, Prof0),
    Prof is Prof0 + 1,
    sangria_arbol(Prof),
    format('[OK] ~q~n', [Goal]).

% EXIT del objetivo raiz = solucion encontrada.
mostrar_evento_arbol(Base, _Frame, _Parent, Level, exit, Goal) :-
    Level =:= Base, !,
    sangria_arbol(2),
    format('[OK] SOLUCION: ~q~n', [Goal]).

mostrar_evento_arbol(_, _, _, _, exit, _) :- !.

% FAIL: se mantiene dentro de la rama activa cuando corresponde.
mostrar_evento_arbol(Base, _Frame, Parent, Level, fail, Goal) :- !,
    profundidad_visual(Base, Parent, Level, Prof0),
    Prof is Prof0 + 1,
    sangria_arbol(Prof),
    format('[X] FALLO: ~q~n', [Goal]).

% REDO: es el regreso al punto de eleccion real informado por SWI.
mostrar_evento_arbol(Base, Frame, Parent, Level, redo(_), Goal) :- !,
    profundidad_arbol(Base, Level, Prof0),
    Prof is Prof0 + 1,
    sangria_arbol(Prof),
    format('<--- BACKTRACKING: volver a '),
    escribir_objetivo_backtracking(Frame, Goal), nl,
    retractall(contexto_rama_arbol(Parent, Level, Frame)).

mostrar_evento_arbol(_, _, _, _, _, _).

% Si existe una alternativa activa para el mismo Parent y nivel, los
% objetivos siguientes pertenecen visualmente a esa rama.
profundidad_visual(Base, Parent, Level, Prof) :-
    profundidad_arbol(Base, Level, P0),
    ( contexto_rama_arbol(Parent, Level, _) -> Prof is P0 + 1 ; Prof = P0 ).

profundidad_arbol(Base, Level, Profundidad) :-
    integer(Base), integer(Level), !,
    Diferencia is Level - Base,
    ( Diferencia >= 0 -> Profundidad = Diferencia ; Profundidad = 0 ).
profundidad_arbol(_, _, 0).

sangria_arbol(0) :- !.
sangria_arbol(N) :-
    N > 0,
    format('|   '),
    N1 is N - 1,
    sangria_arbol(N1).

% Si el Frame tiene una invocacion que corresponde al Goal actual,
% usamos su version simbolica. El ID logico evita confundir frames
% reutilizados por SWI-Prolog.
objetivo_arbol(Frame, Goal, simbolico(Simbolico, Variables)) :-
    invocacion_logica(_Id, Frame, _Parent, _Level, GoalGuardado, Simbolico, Variables),
    GoalGuardado =@= Goal, !.
objetivo_arbol(_, Goal, real(Goal)).

escribir_texto_arbol(simbolico(Simbolico, Variables)) :- !,
    escribir_con_nombres(Simbolico, Variables).
escribir_texto_arbol(real(Goal)) :-
    write_term(Goal, [quoted(true), numbervars(false)]).

% Sustitucion legible obtenida de la unificacion real capturada.
mostrar_sustitucion_arbol(Frame, Hecho) :-
    invocacion_logica(_Id, Frame, _Parent, _Level, _GoalReal, Simbolico, Variables),
    Variables \== [],
    mismo_predicado(Simbolico, Hecho),
    copy_term(Simbolico-Variables-Hecho, SimbolicoCopia-VariablesCopia-HechoCopia),
    SimbolicoCopia = HechoCopia, !,
    format('  '),
    mostrar_sustitucion_inline(VariablesCopia).
mostrar_sustitucion_arbol(_, _).

mostrar_sustitucion_inline([]) :- format('{}').
mostrar_sustitucion_inline(Variables) :-
    Variables \== [],
    format('{ '),
    mostrar_pares_sustitucion_inline(Variables),
    format(' }').

mostrar_pares_sustitucion_inline([Nombre=Valor]) :- !,
    format('~w = ~q', [Nombre, Valor]).
mostrar_pares_sustitucion_inline([Nombre=Valor | Resto]) :-
    format('~w = ~q, ', [Nombre, Valor]),
    mostrar_pares_sustitucion_inline(Resto).


% =========================================================
% VISTA DEFINITIVA PARA COPIAR A HOJA (ASCII PURO)
%
% No usa caracteres Unicode para evitar problemas de
% codificacion en terminales de Windows/VS Code.
% =========================================================

mostrar_arbol_hoja :-
    format('~n========================================~n'),
    format(' ARBOL PARA COPIAR A HOJA~n'),
    format('========================================~n'),
    mostrar_cabecera_hoja,
    nivel_base_arbol(Base),
    mostrar_eventos_hoja(Base),
    format('~n========================================~n'),
    format(' [EXITO] correcto | [FALLO] no cumple~n'),
    format(' BACKTRACKING -> vuelve al punto de eleccion~n'),
    format('========================================~n').

% Cabecera simbolica: evita variables internas como _10936.
mostrar_cabecera_hoja :-
    invocacion_logica(1, FrameRaiz, _Parent, _Level, _Real, _Sim, _Vars),
    ( regla_por_frame(FrameRaiz, Cabeza, Cuerpo, VarsRegla) ->
        format('OBJETIVO: '),
        escribir_con_nombres(Cabeza, VarsRegla),
        nl,
        format('REGLA:    '),
        escribir_con_nombres((Cabeza :- Cuerpo), VarsRegla),
        format('.~n~n')
    ;
        objetivo_raiz_hoja(Raiz, VarsRaiz),
        format('OBJETIVO: '),
        escribir_con_nombres(Raiz, VarsRaiz),
        nl, nl
    ).

% Construye la raiz usando los nombres de variables recuperados
% de la regla fuente (por ejemplo X y E).
objetivo_raiz_hoja(Raiz, VarsRaiz) :-
    invocacion_logica(1, _Frame, _Parent, _Level, Real, _Sim, _Vars),
    functor(Real, Nombre, Aridad),
    variables_regla_hoja(VarsRegla),
    tomar_variables_raiz(VarsRegla, Aridad, Args, VarsRaiz),
    length(Args, Aridad),
    !,
    Raiz =.. [Nombre|Args].
objetivo_raiz_hoja(Raiz, []) :-
    invocacion_logica(1, _Frame, _Parent, _Level, Raiz, _Sim, _Vars),
    !.

variables_regla_hoja(Vars) :-
    invocacion_logica(1, Frame, _P, _L, _R, _S, _V),
    regla_por_frame(Frame, _Cabeza, _Cuerpo, Vars),
    !.
variables_regla_hoja(Vars) :-
    objetivo_simbolico(1, _Obj, Vars), !.
variables_regla_hoja([]).

% Para una cabeza de aridad N toma las primeras N variables distintas
% de la lista de nombres de la regla. En obtenerLicencia/1 toma X.
tomar_variables_raiz(Vars, N, Args, VarsRaiz) :-
    tomar_variables_raiz_(Vars, N, [], Args, VarsRaiz).

tomar_variables_raiz_(_, 0, _Vistos, [], []) :- !.
tomar_variables_raiz_([Nombre=Valor|R], N, Vistos, Args, VarsRaiz) :-
    N > 0,
    ( miembro_identico(Valor, Vistos) ->
        tomar_variables_raiz_(R, N, Vistos, Args, VarsRaiz)
    ;
        Args = [Valor|ArgsR],
        VarsRaiz = [Nombre=Valor|VarsR],
        N1 is N - 1,
        tomar_variables_raiz_(R, N1, [Valor|Vistos], ArgsR, VarsR)
    ).
tomar_variables_raiz_([], _, _, [], []).

miembro_identico(X, [Y|_]) :- X == Y, !.
miembro_identico(X, [_|R]) :- miembro_identico(X, R).

objetivos_regla_hoja(Objetivos) :-
    findall(N-Obj-Vars, objetivo_simbolico(N, Obj, Vars), Triples),
    keysort(Triples, Ordenados),
    findall(Obj-Vars, member(_-Obj-Vars, Ordenados), Objetivos).

mostrar_conjuncion_hoja([Obj-Vars]) :- !,
    escribir_con_nombres(Obj, Vars).
mostrar_conjuncion_hoja([Obj-Vars|R]) :-
    escribir_con_nombres(Obj, Vars),
    format(', '),
    mostrar_conjuncion_hoja(R).

mostrar_eventos_hoja(Base) :-
    forall(
        evento_frame(Frame, Parent, Level, Port, Goal, _),
        mostrar_evento_hoja(Base, Frame, Parent, Level, Port, Goal)
    ).

% =========================================================
% ARBOL DE HOJA JERARQUICO
%
% La profundidad se obtiene de los niveles reales del tracer, pero
% distinguimos tres cosas didacticas:
%   - CALL de un objetivo: nodo del objetivo.
%   - UNIFY con un hecho: alternativa debajo de ese objetivo.
%   - EXIT/FAIL de comparacion: condicion debajo de la alternativa.
%
% Las unificaciones que corresponden a la cabeza de una REGLA no se
% imprimen como alternativas. De este modo adulto(X) y
% obtenerLicencia(X) quedan como subobjetivos y edad(...) como las
% alternativas que realmente se prueban.
% =========================================================

% La raiz ya aparece en la cabecera.
mostrar_evento_hoja(Base, _Frame, _Parent, Level, call, _Goal) :-
    Level =:= Base,
    !.

% CALL de comparaciones: se muestran cuando llega EXIT/FAIL, para no
% duplicarlas.
mostrar_evento_hoja(_, _, _, _, call, Goal) :-
    es_comparacion(Goal),
    !.

% CALL de un subobjetivo logico.
mostrar_evento_hoja(Base, Frame, _Parent, Level, call, Goal) :-
    Level > Base,
    !,
    profundidad_call_hoja(Base, Level, Prof),
    nl,
    sangria_hoja(Prof),
    format('+-- OBJETIVO: '),
    escribir_call_hoja(Frame, Goal),
    nl,
    mostrar_regla_call_hoja(Frame, Prof).

% UNIFY de la cabeza de una regla: el nodo ya fue mostrado por CALL.
mostrar_evento_hoja(_, Frame, _, _, unify, Goal) :-
    regla_por_frame(Frame, Cabeza, _Cuerpo, _Vars),
    mismo_predicado(Cabeza, Goal),
    !.

% UNIFY con un hecho: alternativa real del objetivo que se esta
% resolviendo.
mostrar_evento_hoja(Base, Frame, _Parent, Level, unify, Goal) :-
    Level > Base,
    !,
    profundidad_alternativa_hoja(Base, Level, Prof),
    sangria_hoja(Prof),
    format('+-- ALTERNATIVA: '),
    escribir_objetivo_hoja(Goal),
    mostrar_sustitucion_ascii(Frame, Goal),
    nl.
mostrar_evento_hoja(_, _, _, _, unify, _) :- !.

% Comparacion que tuvo exito. Se dibuja un nivel por debajo de la
% alternativa que la hizo alcanzable.
mostrar_evento_hoja(Base, _Frame, _Parent, Level, exit, Goal) :-
    es_comparacion(Goal),
    Level > Base,
    !,
    profundidad_condicion_hoja(Base, Level, Prof),
    sangria_hoja(Prof),
    format('+-- '),
    escribir_objetivo_hoja(Goal),
    format('  [EXITO]~n').

% EXIT de la raiz = solucion completa de la consulta.
mostrar_evento_hoja(Base, _Frame, _Parent, Level, exit, Goal) :-
    Level =:= Base,
    !,
    format('~n'),
    sangria_hoja(1),
    format('+-- SOLUCION: '),
    escribir_solucion_hoja(Goal),
    format('  [EXITO]~n').

% EXIT de una regla/subobjetivo. No hace falta repetirlo: sus hijos ya
% muestran por que tuvo exito.
mostrar_evento_hoja(_, _, _, _, exit, _) :- !.

% Comparacion que fallo.
mostrar_evento_hoja(Base, _Frame, _Parent, Level, fail, Goal) :-
    es_comparacion(Goal),
    Level > Base,
    !,
    profundidad_condicion_hoja(Base, Level, Prof),
    sangria_hoja(Prof),
    format('+-- '),
    escribir_objetivo_hoja(Goal),
    format('  [FALLO]~n').

% FAIL de un subobjetivo no comparativo. Solo se muestra si no es la
% raiz, para que quede visible donde se agoto una rama completa.
mostrar_evento_hoja(Base, Frame, _Parent, Level, fail, Goal) :-
    Level > Base,
    !,
    profundidad_call_hoja(Base, Level, Prof),
    sangria_hoja(Prof),
    format('`-- AGOTADO: '),
    escribir_call_hoja(Frame, Goal),
    format('  [sin mas alternativas]~n').
mostrar_evento_hoja(_, _, _, _, fail, _) :- !.

% REDO = regreso al punto de eleccion real de SWI-Prolog.
mostrar_evento_hoja(Base, Frame, _Parent, Level, redo(_), Goal) :-
    !,
    profundidad_alternativa_hoja(Base, Level, Prof),
    sangria_hoja(Prof),
    format('`-- BACKTRACKING -> '),
    escribir_objetivo_backtracking(Frame, Goal),
    nl.
mostrar_evento_hoja(_, _, _, _, _, _).

% Profundidades ASCII. Se mantienen separadas para que la presentacion
% no dependa de numeros de Frame concretos ni de un ejercicio concreto.
profundidad_call_hoja(Base, Level, Prof) :-
    D is Level - Base,
    ( D > 0 -> Prof = D ; Prof = 1 ).

profundidad_alternativa_hoja(Base, Level, Prof) :-
    profundidad_call_hoja(Base, Level, P0),
    Prof is P0 + 1.

profundidad_condicion_hoja(Base, Level, Prof) :-
    profundidad_call_hoja(Base, Level, P0),
    Prof is P0 + 2.

sangria_hoja(0) :- !.
sangria_hoja(N) :-
    N > 0,
    format('|   '),
    N1 is N - 1,
    sangria_hoja(N1).

% Escribe el objetivo con nombres simbolicos cuando la invocacion
% capturada permite recuperarlos.
escribir_call_hoja(Frame, Goal) :-
    objetivo_arbol(Frame, Goal, Texto),
    !,
    escribir_texto_arbol(Texto).
escribir_call_hoja(_, Goal) :-
    escribir_objetivo_hoja(Goal).

% Si el CALL corresponde a una regla de usuario, mostramos tambien la
% regla concreta asociada a ESE frame. Esto evita mezclar adulto/1 con
% obtenerLicencia/1 en consultas anidadas.
mostrar_regla_call_hoja(Frame, Prof) :-
    regla_por_frame(Frame, Cabeza, Cuerpo, Variables),
    !,
    ProfRegla is Prof + 1,
    sangria_hoja(ProfRegla),
    format('REGLA: '),
    escribir_con_nombres((Cabeza :- Cuerpo), Variables),
    nl.
mostrar_regla_call_hoja(_, _).

% Sustitucion en ASCII: { X = micaela, E = 27 }
mostrar_sustitucion_ascii(Frame, Hecho) :-
    invocacion_logica(_Id, Frame, _Parent, _Level, _Real, Simbolico, Variables),
    Variables \== [],
    mismo_predicado(Simbolico, Hecho),
    copy_term(Simbolico-Variables-Hecho, SC-VC-HC),
    SC = HC,
    !,
    format('   Sustitucion = '),
    mostrar_sustitucion_inline(VC).
mostrar_sustitucion_ascii(_, _).

% Muestra solo las variables de la consulta en la solucion.
% Ejemplo: X = micaela.
escribir_solucion_hoja(Goal) :-
    objetivo_raiz_hoja(Raiz, VarsRaiz),
    copy_term(Raiz-VarsRaiz-Goal, RC-VC-GC),
    RC = GC,
    !,
    escribir_asignaciones_solucion(VC).
escribir_solucion_hoja(Goal) :-
    escribir_objetivo_hoja(Goal).

escribir_asignaciones_solucion([]) :- format('true').
escribir_asignaciones_solucion([Nombre=Valor]) :- !,
    format('~w = ~q', [Nombre, Valor]).
escribir_asignaciones_solucion([Nombre=Valor|R]) :-
    format('~w = ~q, ', [Nombre, Valor]),
    escribir_asignaciones_solucion(R).

escribir_objetivo_hoja(Goal) :-
    write_term(Goal, [quoted(true), numbervars(false)]).

% Para REDO usamos la invocacion simbolica original del frame
% (por ejemplo edad(X,E)), no las variables internas de SWI.
escribir_objetivo_backtracking(Frame, _Goal) :-
    findall(
        Id-Sim-Vars,
        invocacion_logica(Id, Frame, _P, _L, _Real, Sim, Vars),
        Candidatos
    ),
    Candidatos \== [],
    !,
    keysort(Candidatos, [_-Simbolico-Variables|_]),
    escribir_con_nombres(Simbolico, Variables).
escribir_objetivo_backtracking(_, Goal) :-
    escribir_objetivo_hoja(Goal).

% =========================================================
% EXPORTACION GRAPHVIZ (SVG)
% =========================================================
% Usa exclusivamente los eventos que ya capturo visualizar/1.
% No modifica el tracer ni la logica del visualizador.

:- use_module(library(process)).

% Uso normal despues de visualizar/1:
%   ?- generar_grafico.
% Tambien puede hacerse todo de una vez:
%   ?- visualizar_grafico(Consulta).

visualizar_grafico(Consulta) :-
    visualizar(Consulta),
    generar_grafico.

generar_grafico :-
    carpeta_visualizador(Dir),
    directory_file_path(Dir, 'arbol_prolog.dot', Dot),
    directory_file_path(Dir, 'arbol_prolog.svg', Svg),
    generar_dot(Dot),
    convertir_dot_a_svg(Dot, Svg),
    format('~n========================================~n'),
    format(' GRAFICO GRAPHVIZ GENERADO~n'),
    format('========================================~n'),
    format('DOT: ~w~n', [Dot]),
    format('SVG: ~w~n', [Svg]),
    format('Abrilo desde el explorador de VS Code.~n'),
    format('========================================~n').

carpeta_visualizador(Dir) :-
    source_file(generar_grafico, Archivo),
    !,
    file_directory_name(Archivo, Dir).
carpeta_visualizador(Dir) :-
    working_directory(Dir, Dir).

generar_dot(Archivo) :-
    setup_call_cleanup(
        open(Archivo, write, S, [encoding(utf8)]),
        escribir_dot(S),
        close(S)
    ).

escribir_dot(S) :-
    format(S, 'digraph prolog {~n', []),
    format(S, '  graph [rankdir=TB, bgcolor="white", pad="0.35", nodesep="0.30", ranksep="0.55"];~n', []),
    format(S, '  node [shape=box, style="rounded,filled", fontname="Arial", fontsize=11, color="#455A64", fillcolor="#ECEFF1", margin="0.12,0.08"];~n', []),
    format(S, '  edge [fontname="Arial", fontsize=9, color="#607D8B", arrowsize=0.7];~n', []),
    findall(ev(Frame,Parent,Level,Port,Goal),
            evento_frame(Frame,Parent,Level,Port,Goal,_),
            Eventos),
    escribir_eventos_dot(Eventos, S, 1, ninguno),
    format(S, '}~n', []).

escribir_eventos_dot([], _, _, _).
escribir_eventos_dot([ev(Frame,Parent,Level,Port,Goal)|R], S, N, Anterior) :-
    ( evento_graphviz_interesante(Frame, Port, Goal) ->
        etiqueta_evento_graphviz(Frame, Port, Goal, Etiqueta, Tipo),
        dot_escape(Etiqueta, Esc),
        estilo_graphviz(Tipo, Atributos),
        format(S, '  n~d [label="~w", ~w];~n', [N, Esc, Atributos]),
        ( Anterior == ninguno -> true
        ; arista_graphviz(S, Anterior, N, Port, Frame, Parent, Level)
        ),
        N1 is N + 1,
        escribir_eventos_dot(R, S, N1, N)
    ;
        escribir_eventos_dot(R, S, N, Anterior)
    ).

% Quitamos ruido: CALL de comparaciones y UNIFY de cabezas de reglas.
evento_graphviz_interesante(_, call, Goal) :- \+ es_comparacion(Goal), !.
evento_graphviz_interesante(Frame, unify, Goal) :-
    \+ (regla_por_frame(Frame, Cabeza, _, _), mismo_predicado(Cabeza, Goal)), !.
evento_graphviz_interesante(_, exit, Goal) :- es_comparacion(Goal), !.
evento_graphviz_interesante(_, exit, Goal) :- es_objetivo_raiz_graphviz(Goal), !.
evento_graphviz_interesante(_, fail, Goal) :- es_comparacion(Goal), !.
evento_graphviz_interesante(_, redo(_), _) :- !.
evento_graphviz_interesante(_, _, _) :- fail.

es_objetivo_raiz_graphviz(Goal) :-
    invocacion_logica(1, _, _, _, Real, _, _),
    mismo_predicado(Real, Goal).

etiqueta_evento_graphviz(Frame, call, Goal, Etiqueta, objetivo) :- !,
    texto_objetivo_graphviz(Frame, Goal, T),
    format(string(Etiqueta), 'OBJETIVO\\n~w', [T]).
etiqueta_evento_graphviz(Frame, unify, Goal, Etiqueta, alternativa) :- !,
    texto_termino_graphviz(Goal, T),
    sustitucion_graphviz(Frame, Goal, Sust),
    ( Sust == '' -> format(string(Etiqueta), 'ALTERNATIVA\\n~w', [T])
    ; format(string(Etiqueta), 'ALTERNATIVA\\n~w\\n~w', [T,Sust]) ).
etiqueta_evento_graphviz(_, exit, Goal, Etiqueta, exito) :-
    es_comparacion(Goal), !,
    texto_termino_graphviz(Goal, T),
    format(string(Etiqueta), '~w\\nEXITO', [T]).
etiqueta_evento_graphviz(_, exit, Goal, Etiqueta, solucion) :- !,
    solucion_graphviz(Goal, T),
    format(string(Etiqueta), 'SOLUCION\\n~w', [T]).
etiqueta_evento_graphviz(_, fail, Goal, Etiqueta, fallo) :- !,
    texto_termino_graphviz(Goal, T),
    format(string(Etiqueta), '~w\\nFALLO', [T]).
etiqueta_evento_graphviz(Frame, redo(_), Goal, Etiqueta, backtracking) :- !,
    objetivo_backtracking_string(Frame, Goal, T),
    format(string(Etiqueta), 'BACKTRACKING\\nvolver a ~w', [T]).

texto_objetivo_graphviz(Frame, Goal, Texto) :-
    with_output_to(string(Texto), escribir_call_hoja(Frame, Goal)).
texto_termino_graphviz(Goal, Texto) :-
    with_output_to(string(Texto), escribir_objetivo_hoja(Goal)).
objetivo_backtracking_string(Frame, Goal, Texto) :-
    with_output_to(string(Texto), escribir_objetivo_backtracking(Frame, Goal)).
solucion_graphviz(Goal, Texto) :-
    with_output_to(string(Texto), escribir_solucion_hoja(Goal)).

sustitucion_graphviz(Frame, Hecho, Texto) :-
    with_output_to(string(T0), mostrar_sustitucion_ascii(Frame, Hecho)),
    normalize_space(string(Texto), T0).

estilo_graphviz(objetivo, 'fillcolor="#E3F2FD", color="#1976D2"').
estilo_graphviz(alternativa, 'shape=diamond, fillcolor="#FFF8E1", color="#F9A825"').
estilo_graphviz(exito, 'fillcolor="#E8F5E9", color="#2E7D32"').
estilo_graphviz(fallo, 'fillcolor="#FFEBEE", color="#C62828"').
estilo_graphviz(solucion, 'shape=doubleoctagon, fillcolor="#E8F5E9", color="#1B5E20", penwidth=2').
estilo_graphviz(backtracking, 'shape=ellipse, style="dashed,filled", fillcolor="#F3E5F5", color="#7B1FA2"').

arista_graphviz(S, A, B, redo(_), _, _, _) :- !,
    format(S, '  n~d -> n~d [style=dashed, color="#7B1FA2", label="backtracking"];~n', [A,B]).
arista_graphviz(S, A, B, _, _, _, _) :-
    format(S, '  n~d -> n~d;~n', [A,B]).

dot_escape(In, Out) :-
    string_codes(In, Cs),
    phrase(dot_codes(Cs), Ds),
    string_codes(Out, Ds).

dot_codes([]) --> [].
dot_codes([0'\\|R]) --> "\\\\", dot_codes(R).
dot_codes([0'\"|R]) --> "\\\"", dot_codes(R).
dot_codes([10|R]) --> "\\n", dot_codes(R).
dot_codes([13|R]) --> [], dot_codes(R).
dot_codes([C|R]) --> [C], dot_codes(R).

convertir_dot_a_svg(Dot, Svg) :-
    catch(
        process_create(path(dot), ['-Tsvg', Dot, '-o', Svg], [process(PID)]),
        Error,
        error_graphviz(Error)
    ),
    process_wait(PID, Status),
    ( Status == exit(0) -> true
    ; format('ERROR: Graphviz termino con estado ~q.~n', [Status]), fail ).

error_graphviz(Error) :-
    format('~nERROR: no pude ejecutar Graphviz (comando dot).~n'),
    format('Detalle: ~q~n', [Error]),
    format('Instala Graphviz y asegurate de que dot.exe este en el PATH.~n'),
    throw(Error).
