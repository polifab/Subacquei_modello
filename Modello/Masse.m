%% MATRICE MASSA CORPO RIGIDO

M_rb = massa*diag([1,1,1,(b^2+c^2)/5,(a^2+c^2)/5,(a^2+b^2)/5]);

%% MATRICE MASSA AGGIUNTA

e = sqrt(1-(c/a)^2);
alfa_0 = sqrt(1-e^2)/e^3*asin(e)-(1-e^2)/e^2;
beta_0 = alfa_0;
%gamma_0 = 2/e^2*(1-sqrt(1-e^2)*asin(e)/e^2); % da conservare
gamma_0 = alfa_0;
Xu = -alfa_0/(2-alfa_0); %Todo da mettere uguali
Yv = -beta_0/(2-beta_0);
Zw = -gamma_0/(2-gamma_0);
Kp = -1/5*((b^2-c^2)^2*(gamma_0-beta_0))/(2*(b^2-c^2)+(b^2+c^2)*(beta_0-gamma_0));
Mq = -1/5*((c^2-a^2)^2*(alfa_0-gamma_0))/(2*(c^2-a^2)+(c^2+a^2)*(gamma_0-alfa_0));
%Nr = -1/5*((a^2-b^2)^2*(beta_0-alfa_0))/(2*(a^2-b^2)+(a^2+b^2)*(alfa_0-beta_0));
Nr = 0;
M_a = massa*diag([Xu,Yv,Zw,Kp,Mq,Nr]);

%% MATRICE MASSA TOTALE

M = M_rb + M_a;
M_inv = inv(M);
