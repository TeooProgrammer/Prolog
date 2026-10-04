:- multifile user:prolog_trace_interception/4.

user:prolog_trace_interception(Port, Frame, _Choice, continue) :-
    prolog_frame_attribute(Frame, goal, Goal),
    format('EVENTO: ~w | META: ~q~n', [Port, Goal]).