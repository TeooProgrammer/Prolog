iniciar_historial(Archivo) :-
    protocola(Archivo),
    configurar_historial_sin_buffer(Archivo),
    at_halt(cerrar_historial).

configurar_historial_sin_buffer(Archivo) :-
    absolute_file_name(Archivo, Absoluto),
    stream_property(Stream, file_name(Nombre)),
    stream_property(Stream, mode(append)),
    same_file(Nombre, Absoluto),
    !,
    set_stream(Stream, buffer(false)).

configurar_historial_sin_buffer(_).

cerrar_historial :-
    ( protocolling(_) ->
        noprotocol
    ;
        true
    ).