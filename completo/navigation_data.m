disp('Loading Navigation parameters...')
%% Definition of noise covariances

n_gps   =  (0.02)/0.01;

% n_depth =   30*(3/80)^2; % per dati di prova
n_depth =  (3/80)^2;

n_dvl   =  [ 0.005^2;
             0.015^2;
             0.023^2 ];
% n_dvl   =  [ 0.0250; % per dati di prova
%              0.2250;
%              0.5290 ];
             
n_ahrs =   [1; 1; 2] * pi/180;


%% Variable initialization

diagonal = [n_ahrs(1), n_ahrs(2), n_ahrs(3), n_dvl(1), n_dvl(2), n_dvl(3)];
Q = diag(diagonal);

diagonal = [n_gps, n_gps, n_depth];        
R = diag(diagonal);

H = eye(3);
num_cycle = 5;

disp('Done')