%% Vettori posizionamento thrusters in terna Body

p1 = [0 -0.25 0]';
p2 = [0 0.25 0]';
p3 = [-0.25 0 0]';
p4 = [0.25 0 0]';
p5 = [-0.15 -0.15 0]';
p6 = [-0.15 0.15 -0]';
p7 = [0.15 0 0]';

%% Versori degli assi di ciascun thrusters  in terna Body

t1 = [1 0 0]';
t2 = t1;
t3 = [0 1 0]';
t4 = -t3;
t5 = [0 0 1]';
t6 = t5;
t7 = t5;

%% Mappa tra le spinte di ciascun thruster e le forze/momenti totali che il veicolo subisce 

B1 = [t1; cross(p1,t1)];
B2 = [t2; cross(p2,t2)];
B3 = [t3; cross(p3,t3)];
B4 = [t4; cross(p4,t4)];
B5 = [t5; cross(p5,t5)];
B6 = [t6; cross(p6,t6)];
B7 = [t7; cross(p7,t7)];

TAM = [B1 B2 B3 B4 B5 B6 B7]; % Matrice di Allocazione dei Thrusters complessiva