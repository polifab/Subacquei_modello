function [init, P0] = init_position(store_gps, store_depth, N)

% La funzione si occupa di valutare i valori iniziali dello stato e della varianza dell'errore di stima

%% GPS

somma = zeros(2,1);
if N > 1
    init_pos = (sum(store_gps') / N)';
    for i=1:N
        somma(1) = somma(1) + (store_gps(1,i) - init_pos(1))^2;
        somma(2) = somma(2) + (store_gps(2,i) - init_pos(2))^2;
    end
    variance_pos = somma/(N-1);
else
    init_pos = store_gps;
    variance_pos = zeros(2,1);
end
%% Profondimetro
%media
init_depth = sum(store_depth)/N;

% varianza campionaria
temp = 0;
for i=1:N
    temp = temp + (store_depth(i) - init_depth)^2;    
end

if N > 1
    P0_depth = temp/(N-1);
else 
    P0_depth = 0;
end

%% Uscita
init = [init_pos(1); init_pos(2); init_depth];
P0 = [variance_pos(1)    0               0;
        0             variance_pos(2)      0;
        0                    0          P0_depth];
end