% Define la dimensión N de la habitación (por ejemplo, 5x5)
dimension(5).
% ESTADO INICIAL (Caso 1)
% state(pos(0,0), on-floor, pos(2,2), pos(1,1), hasnot)

% ESTADO FINAL OBJETIVO
% state(pos(1,1), on-box, pos(1,1), pos(1,1), has)

% Hecho inicial: Dimensión de la habitación
dimension(5).

% Lógica de coordenadas según la dirección elegida
direction(east,  X, Y, X_new, Y) :- X_new is X + 1.
direction(south, X, Y, X, Y_new) :- Y_new is Y + 1.
direction(north, X, Y, X, Y_new) :- Y_new is Y - 1.
direction(west,  X, Y, X_new, Y) :- X_new is X - 1.

% Comprobación para no salir de los límites de la habitación N x N
valid_pos(X, Y) :-
    dimension(N),
    X >= 0, X < N,
    Y >= 0, Y < N.

% ACCIÓN 1: Agarrar el plátano (grasp)
% Requisito: El mono debe estar sobre la caja, y ambos justo debajo del plátano[cite: 15].
move(state(pos(X,Y), on-box, pos(X,Y), pos(X,Y), hasnot), grasp, 
     state(pos(X,Y), on-box, pos(X,Y), pos(X,Y), has)).

% ACCIÓN 2: Subir a la caja (climb)
% Requisito: El mono y la caja están en la misma posición, y el mono está en el suelo[cite: 14].
move(state(pos(X,Y), on-floor, pos(X,Y), PosB, Has), climb, 
     state(pos(X,Y), on-box, pos(X,Y), PosB, Has)).

% ACCIÓN 3: Empujar la caja (push)
% Requisito: Mono en el suelo y en la misma posición que la caja. Ambos se mueven juntos[cite: 14].
move(state(pos(X,Y), on-floor, pos(X,Y), PosB, Has), push(Dir), 
     state(pos(NX,NY), on-floor, pos(NX,NY), PosB, Has)) :-
    direction(Dir, X, Y, NX, NY),
    valid_pos(NX, NY).

% ACCIÓN 4: Caminar (walk)
% Requisito: Mono en el suelo. Se mueve a una casilla adyacente vacía[cite: 13].
move(state(pos(X,Y), on-floor, PosC, PosB, Has), walk(Dir), 
     state(pos(NX,NY), on-floor, PosC, PosB, Has)) :-
    direction(Dir, X, Y, NX, NY),
    valid_pos(NX, NY).

% ==========================================
% MOTOR DE BÚSQUEDA ÓPTIMA (Búsqueda en Anchura - BFS)
% ==========================================

% Utilidad estándar de listas
member(X, [X|_]).
member(X, [_|Tail]) :- member(X, Tail).

% Predicado principal para resolver encontrando el camino más corto
% CASO 1: Mono en (0,0), Caja en (2,2), Plátano en (1,1)[cite: 31, 32].
solve(Plan) :-
    InitState = state(pos(0,0), on-floor, pos(2,2), pos(1,1), hasnot),
    % La cola (Queue) almacena [EstadoActual, [CaminoDeAccionesHastaAqui]]
    bfs( [ [InitState, []] ], [InitState], RevPlan ),
    reverse(RevPlan, Plan).

% Caso Base BFS: El primer estado de la cola es el final (has). Hemos terminado[cite: 25].
bfs( [ [state(_, _, _, _, has), Plan] | _ ], _, Plan).

% Caso Recursivo BFS: Expandimos el primer estado y añadimos los nuevos al final de la cola.
bfs( [ [State, Path] | RestQueue ], Visited, FinalPlan) :-
    findall(
        [NextState, [Action | Path]],
        (
            move(State, Action, NextState),
            \+ member(NextState, Visited) % Evitamos bucles ignorando estados ya visitados
        ),
        NewNodes
    ),
    extract_states(NewNodes, NewStates),
    append(Visited, NewStates, NewVisited), % Actualizamos la lista de visitados
    append(RestQueue, NewNodes, NewQueue),  % Añadimos al final (comportamiento FIFO para BFS)
    bfs(NewQueue, NewVisited, FinalPlan).

% Auxiliar para extraer solo los estados de los nodos generados
extract_states([], []).
extract_states([[S, _]|T], [S|T2]) :- extract_states(T, T2).

