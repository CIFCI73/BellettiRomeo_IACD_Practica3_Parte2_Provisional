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

