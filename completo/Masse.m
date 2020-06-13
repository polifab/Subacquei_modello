% Script per....

%% MATRICE MASSA CORPO RIGIDO

M_rb = massa*diag([1,1,1,(b^2+c^2)/5,(a^2+c^2)/5,(a^2+b^2)/5]); % Matrice di massa del corpo rigido

%% MATRICE MASSA AGGIUNTA (Formulazione tratta da Imlay(1964) e Lamb(1945))

e = sqrt(1-(c/a)^2); % eccentricità

% calcolo dei coefficienti 
alfa_0 = sqrt(1-e^2)/e^3*asin(e)-(1-e^2)/e^2;
beta_0 = alfa_0;
gamma_0 = 2/e^2*(1-sqrt(1-e^2)*asin(e)/e^2); % da conservare
%gamma_0 = alfa_0;
gamma_0_approx = alfa_0;

% Calcolo dei componenti sulla diagonale
Xu = -alfa_0/(2-alfa_0); 
Yv = -beta_0/(2-beta_0);
% utilizziamo la terza componente lineare Zw uguale alle prime due 
% per ridurre gli accoppiamenti su pitch e roll dovuti a Coriolis
Zw = -gamma_0_approx/(2-gamma_0_approx); 
Kp = -1/5*((b^2-c^2)^2*(gamma_0-beta_0))/(2*(b^2-c^2)+(b^2+c^2)*(beta_0-gamma_0));
Mq = -1/5*((c^2-a^2)^2*(alfa_0-gamma_0))/(2*(c^2-a^2)+(c^2+a^2)*(gamma_0-alfa_0));
Nr = 0;

M_a = massa*diag([Xu,Yv,Zw,Kp,Mq,Nr]); % Matrice di masse aggiunte

%% MATRICE MASSA TOTALE

M = M_rb + M_a; % Matrice di massa totale
M_inv = inv(M); % Matrice di massa totale inversa
