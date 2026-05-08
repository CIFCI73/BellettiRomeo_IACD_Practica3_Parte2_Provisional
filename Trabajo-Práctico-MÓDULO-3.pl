% Define la dimensión N de la habitación (por ejemplo, 5x5)
dimension(5).
% ESTADO INICIAL (Caso 1)
% state(pos(0,0), on-floor, pos(2,2), pos(1,1), hasnot)

% ESTADO FINAL OBJETIVO
% state(pos(1,1), on-box, pos(1,1), pos(1,1), has)

% Hecho inicial: Dimensión de la habitación
dimension(5).

% Lógica de coordenadas según la dirección elegida
direction(north, X, Y, X, Y_new) :- Y_new is Y + 1.
direction(south, X, Y, X, Y_new) :- Y_new is Y - 1.
direction(east,  X, Y, X_new, Y) :- X_new is X + 1.
direction(west,  X, Y, X_new, Y) :- X_new is X - 1.

% Comprobación para no salir de los límites de la habitación N x N
valid_pos(X, Y) :-
    dimension(N),
    X >= 0, X < N,
    Y >= 0, Y < N.

