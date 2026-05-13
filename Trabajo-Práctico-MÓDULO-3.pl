% ESTADO INICIAL (Caso 1)
% state(pos(0,0), on-floor, pos(2,2), pos(1,1), hasnot)

% ESTADO FINAL OBJETIVO
% state(pos(1,1), on-box, pos(1,1), pos(1,1), has)

% Hecho inicial: Dimensión de la habitación
dimension(5).

% Lógica de coordenadas
direction(east,  X, Y, X_new, Y) :- X_new is X + 1.
direction(south, X, Y, X, Y_new) :- Y_new is Y + 1.
direction(north, X, Y, X, Y_new) :- Y_new is Y - 1.
direction(west,  X, Y, X_new, Y) :- X_new is X - 1.

% Comprobación para no salir de los límites de la habitación N x N
valid_pos(X, Y) :-
    dimension(N),
    X >= 0, X < N,
    Y >= 0, Y < N.

% Agarrar el plátano (grasp)
move(state(pos(X,Y), on-box, pos(X,Y), pos(X,Y), hasnot), grasp, 
     state(pos(X,Y), on-box, pos(X,Y), pos(X,Y), has)).

% Subir a la caja (climb)
move(state(pos(X,Y), on-floor, pos(X,Y), PosB, Has), climb, 
     state(pos(X,Y), on-box, pos(X,Y), PosB, Has)).

% Bajar de la caja (get_down)
move(state(pos(X,Y), on-box, pos(X,Y), PosB, Has), get_down, 
     state(pos(X,Y), on-floor, pos(X,Y), PosB, Has)).

% Empujar la caja (push)
move(state(pos(X,Y), on-floor, pos(X,Y), PosB, Has), push(Dir), 
     state(pos(NX,NY), on-floor, pos(NX,NY), PosB, Has)) :-
    direction(Dir, X, Y, NX, NY),
    valid_pos(NX, NY).

% Caminar (walk)
move(state(pos(X,Y), on-floor, PosC, PosB, Has), walk(Dir), 
     state(pos(NX,NY), on-floor, PosC, PosB, Has)) :-
    direction(Dir, X, Y, NX, NY),
    valid_pos(NX, NY).

% Utilidad estándar de listas
member(X, [X|_]).
member(X, [_|Tail]) :- member(X, Tail).

% Predicado principal genérico (Recibe el estado inicial por parámetro)
solve(InitState, Plan) :-
    bfs( [ [InitState, []] ], [InitState], RevPlan ),
    reverse(RevPlan, Plan).

% Le pasamos el estado inicial a run/1 para que formatee la salida
% Por el Caso 1: run(state(pos(0,0), on-floor, pos(2,2), pos(1,1), hasnot)).
run(InitState) :-
    solve(InitState, Plan),
    format('True, ~w.~n', [Plan]).

% Caso Base BFS
bfs( [ [state(_, _, _, _, has), Plan] | _ ], _, Plan).

% Caso Recursivo BFS 
bfs( [ [State, Path] | RestQueue ], Visited, FinalPlan) :-
    findall(
        [NextState, [Action | Path]],
        (
            move(State, Action, NextState),
            \+ member(NextState, Visited) 
        ),
        NewNodes
    ),
    extract_states(NewNodes, NewStates),
    append(Visited, NewStates, NewVisited), 
    append(RestQueue, NewNodes, NewQueue),  
    bfs(NewQueue, NewVisited, FinalPlan).

% Limpia la lista: se queda el estado y tira lo demás.
extract_states([], []).
extract_states([[S, _]|T], [S|T2]) :- extract_states(T, T2).
