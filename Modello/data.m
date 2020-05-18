clear all
close all
clc

disp('Loading System parameters...')

%% Environmental data

rho = 1030;                 % [kg/m^3] Sea Water Density

%% Data for thrusters [Inspired to Bluerobotics model T200]

D = 0.076;                  % [m] Propeller Diameter
n_max = 340;                % [rad/s] Maximum propeller rotational speed
dead_zone_limit = 31.5;     % [rad/s] Corresponding to about 350RPM
omega = 0.1;                % []  Wake Fraction Number

% kT(J0) function characterisation
alpha1 =  0.0113;          % [Ns^2/m/kg/rad^2]
alpha2 = -0.0091;          % [Ns^2/m/kg/rad]

a1 =  rho * D^4 * alpha1;
a2 = -rho * D^3 * alpha2 * (1 - omega);

%% Vehicle Model parameters
% here, the Vehicle Model parameters are included
a = 0.35;
b = 0.35;
c = 0.19;
V = 4/3*pi*a*b*c;
massa = 100;
Masse         % code for mass matrix computation
TAM_matrice   % code for Thrust Allocation Matrix computation
current = [0;0;0;0;0;0];
rho = 1030
%% Environment Model & Sensor Model parameters
% here, the Environment Model & Sensor Model parameters parameters are included


%% Mission Supervisor & Reference Generator parameters
% here, the Mission Supervisor & Reference Generator parameters parameters are included


%% Controller parameters
% here, the Controller parameters are included


%% Navigation System parameters
% here, the Navigation System parameters are included


%% System parameters loaded
disp('Done')

%% LOAD Mission File
% file 'mission.m' is executed to load mission parameters (uncomment the right one)
% run missionA.m;
run missionB.m;

pylonCenter(3) = 0;
wgs84 = wgs84Ellipsoid('kilometer'); %TODO verificare che esprima le coordinate nello stesso modo dell'ECEF dato in missionB.m
[initial(1), initial(2), initial(3)] = geodetic2ned(initPoint(1), initPoint(2), initPoint(3), pylonCenter(1), pylonCenter(2), pylonCenter(3), wgs84, 'degrees');
initial(4:5) = 0;
initial(6)   = initInspectionDirection*pi/180;


% run missionC.m;


%% RUN
%simout = sim('modello_simulink')

%eta = simout.eta;
%eta = eta.Data;

%size_eta = length(eta);

%figure;
%hold on;

%for i=1:size_eta
%    plot3(eta(i,1), eta(i,2), eta(i,3), '.')
%end    
    

