function [dist, alpha, flag_sonar] = fcn_sonar(sonar, orientation, pylonRadius, a, s_data)

% Si occupa di calcolate la distanza e l'angolo dell'AUV rispetto al pilone

%% Variabili
flag_sonar  =   1;
num         =   s_data.num;     % numero di sonar
beta        =   s_data.delta;       % angolo tra i sonar in radianti
r           =   pylonRadius;

phi         =   orientation(1);
theta       =   orientation(2);
psi         =   orientation(3);

s           =   zeros(1, num);
input_flags =   zeros(1, num);
error_flag  =   ones(1, num);           % vale 1 se  il corrispondente sonar funzionante, 0 altrimenti
flag        =   ones(1, num);           % vale 1 se  il corrispondente valore utilizzabile, 0 altrimenti

for i = 1:num
    s(i)            =   sonar(i);       % distanze date dai sonar
    input_flags(i)  =   sonar(num+i);   % flag in ingresso
end

%% Sonar non funzionanti
for i = 1:num
    if input_flags(i) == 8              % il  corrispondente sonar non è funzionante
        error_flag(i) = 0;
    end
end

if  sum(error_flag) < 2                 % numero sonar funzionanti < 2
    dist = NaN;
    alpha = NaN;
    flag_sonar = 0;                     % flag di errore da inviare al mission supervisor
    return
end

%% Validita' segnali in ingresso
for i = 1:num                           
    if isnan(s(i)) || error_flag(i) == 0    % se il valore del sonar è NaN o il sonar non è funzionante non lo considero nella stima
        flag(i) = 0;
    end
end

%% Calcolo valori relativi
number_of_valid_signals = sum(flag);
switch number_of_valid_signals
    
    case    0                       % caso in cui tutti i sonar NaN
        dist = NaN;
        alpha = NaN;
        return
        
    case    1                       % caso in cui quattro sonar NaN
        dist = NaN;
        alpha = NaN;
        return   
        
    otherwise
        %% Coordinate punti 
        s1  =   s(1) * [cos(2*beta)    +sin(2*beta)       0];
        s2  =   s(2) * [cos(beta)      +sin(beta)         0];
        s3  =   s(3) * [1              0                  0];
        s4  =   s(4) * [cos(beta)      -sin(beta)         0];
        s5  =   s(5) * [cos(2*beta)    -sin(2*beta)       0];
        A   =   [a 0 0];
        S_init = [s1 + A; s2 + A; s3 + A; s4 + A; s5 + A];  %Coordinate punti in terna body
        % Calcolo coordinate in terna con assi paralleli alla terna NED e
        % centro nell'origine della terna body
        R_z = [ cos(psi),   -sin(psi),  0;
                sin(psi),   cos(psi),   0;
                0,          0,          1];
        R_y = [ cos(theta), 0,          sin(theta);
                0,          1,          0;
                -sin(theta),0,          cos(theta)];           
        R_x = [ 1,          0,          0;
                0,          cos(phi),   -sin(phi);
                0,          sin(phi),   cos(phi)];     
        R_tot = R_z * R_y * R_x;
        S = (R_tot * S_init')' ;
        
        %% Minimizzazione del funzionale
        % J = sum((S(i,1) - x)^2 + (S(i,2) - y)^2 - r^2)^2;
        syms x y 
        vars = [x y];  
        for i = 1:num
            if flag(i) ~= 0
                    Der1(i) = S(i,1) * ((S(i,1) - x)^2 + (S(i,2) - y)^2 - r^2);
                    Der2(i) = S(i,2) * ((S(i,1) - x)^2 + (S(i,2) - y)^2 - r^2);                   
            end
        end
        der1 = sum(Der1);
        der2 = sum(Der2);
        [solx,soly] = solve([der1 == 0, der2 == 0],vars);
        
        if eval(solx(1)) > s(3)
            x_c = eval(solx(1));
            y_c = eval(soly(1));
        else 
            x_c = eval(solx(2));
            y_c = eval(soly(2));
        end
end

%% Calcolo distanza e angolo
dist = sqrt(x_c^2 + y_c^2) - r;     % Distanza dal pilone
alpha = wrapToPi(atan2(y_c, x_c) - psi);      % Angolo

