clear all
close all
clc


%% LOAD Mission File
% file 'mission.m' is executed to load mission parameters (uncomment the right one)
run missionB.m;


disp('Loading System parameters...')
%% Environmental data

rho = 1030;                 % [kg/m^3] Sea Water Density

seaCurrent = [ 0.1;
              0.05;
                 0];        % [m/s] Sea current speed, values can be modified


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
run Masse         % code for mass matrix computation
run TAM_matrice   % code for Thrust Allocation Matrix computation
current = [seaCurrent; 0; 0; 0];

initial = [];
pylonCenter(3) = 0;
wgs84 = wgs84Ellipsoid('meter'); %TODO verificare che esprima le coordinate nello stesso modo dell'ECEF dato in missionB.m
[initial(1), initial(2), initial(3)] = geodetic2ned(initPoint(1), initPoint(2), -initPoint(3), ...
    pylonCenter(1), pylonCenter(2), pylonCenter(3), wgs84, 'degrees');
%initial(3)=0.2;
initial(4:6) = 0;
%initial(6)   = initInspectionDirection*pi/180;

%% Environment Model & Sensor Model parameters
% here, the Environment Model & Sensor Model parameters parameters are included
% Sonar
global x_pyl y_pyl t_son a_1 a_2 b_1 b_2
syms x_pyl y_pyl t_son a_1 a_2 b_1 b_2 real

s_data.num = 5;                                                  % Total number of sonars. TO BE EDITED IN THE 2 FUNCTIONS SONAR_ID AND SONAR_LIM!
s_data.delta = 0.25;                                             % [rad] Relative angular displacement of the sonars
s_data.pos(1:3,1:s_data.num) = ([a;0;0]*ones(1,s_data.num));     % [m] Position of the all the sonars in body frame
s_data.bias = 0;                                                 % [m]
s_data.noise = 0.05;                                             % [m] Standard deviation
s_data.res = 0.02;                                               % [m] Sonar resolution
s_data.maxdpt = 300;                                             % [m] Sonar max operating depth
s_data.minrng = 0.5;                                             % [m] Sonar min detectable range
s_data.maxrng = 50;                                              % [m] Sonar max detectable range
s_data.smpl = 0.5;                                               % [s] Sampling time of the sonar
s_data.cang = 5*pi/180;                                          % [°] Sonar cone semi-angle

%Pressure sensor
ps_var = (5000/3)^2;                                             % [Pa]
ps_sample_t = 0.02;                                         
ps_resol = 157;

%DVL
DVL_var1 = 0.005^2;                                              % Varianza valida per 0<=vel<=2, con vel modulo di una componente della velocità lineare
DVL_var2 = 0.015^2;                                              % Varianza valida per 2<vel<=4
DVL_var3 = 0.023^2;                                              % Varianza valida per vel>4
DVL_resol = 10^(-5);
DVL_sample_t = 1/12;

% AHRS
seed = rng('shuffle');                                           % Accelerometer/Gyroscope Bias Seed:
acc_seed = rand(1,3);
gyro_seed = rand(1,3);
acc_noise = (0.14*(10)^(-3)*9.81)^2;                             % Noise Density:                    da 0.14 m[g/√Hz]        -> a  [m/(s^2 √Hz)]
acc_bias = acc_seed*0.08*(10)^(-3)*9.81 - 0.04*(10)^(-3)*9.81;   % Accelerometer Bias                da 0.04 m[g]            -> a  [m/s^2] 
Resolution_acc = 0.5 * 10^(-3) * 9.81;                           % Accelerometer' s Resolution:      da 0.5 m[g]             -> a  [m/s^2]
gyro_noise = (0.0035*(pi/180))^2;                                % Noise Density:                    da 0.0035 [°/(s √Hz)]   -> a  [rad/(s √Hz)]
gyro_bias = gyro_seed*20*(pi/180)/3600 - 10*(pi/180)/3600;       % Gyroscope Bias                    da 10 [°/hr]            -> a  [rad/s]
Resolution_gyro = 0.02 * (pi/180);                               % Gyroscope' s Resolution:          da 0.02 [°/s]           -> a  [rad/s]
magn_noise = (140*(10)^(-6))^2;                                  % Noise Density:                    da 140 μ[Gauss/√Hz]     -> a  [Gauss/√Hz]
Resolution_magn = 1.15 * 10^(-3);                                % Magnetometer' s Resolution:       da 1.5 m[Gauss]         -> a   [Gauss]
%IMU_sample_time = 1/800;                                        % Output Rate (IMU Data):              800 [Hz]             
IMU_sample_time = 1/100;                                         % Reduced to optimaze           
AHRS_bias = [0 0 0];                            
AHRS_var = ([1 1 2] * pi/180).^2;                                % AHRS Dynamic Accuracy:            da (1 1 2) [°] RMS      -> a   [rad] RMS
%AHRS_sample_time = 1/400;                                       % Output Rate (Attitude Data):         400 [Hz]             
AHRS_sample_time = 1/50;                                         % Reduced to optimaze
Resolution_AHRS = 0.05 * (pi/180);                               % AHRS' s Resolution:               da 0.05[°]

%GPS
gps_sample_t = 1;                                                % [s] GPS sample time
gpsThreshold = 0.25;                                              % [m]
gps_noise = (4/3)^2;
pylonCenter(3) = 0;

% Mission graphical representation
plot_smpl = 0.1;                                                % [s] Sample time of the ToWorkspace used for the graphical representation

% Function
% Call it POST simulink simulation
%drawMission(pylonRadius, pylonCenter, areaDepth, out, s_data)
%drawMissionLine(pylonCenter, initPoint, out)


%% Mission Supervisor & Reference Generator parameters
% here, the Mission Supervisor & Reference Generator parameters parameters are included
run initCheckpoints.m;
addpath('scripts','subsystems');


%% Controller parameters
% here, the Vehicle Model parameters are included
p1 = [0 -0.25 0]';
p2 = [0 0.25 0]';
p3 = [-0.25 0 0]';
p4 = [0.25 0 0]';
p5 = [-0.15 -0.15 0]';
p6 = [-0.15 0.15 -0]';
p7 = [0.15 0 0]';
P=[p1;p2;p3;p4;p5;p6;p7];

t1 = [1 0 0]';
t2 = t1;
t3 = [0 1 0]';
t4 = -t3;
t5 = [0 0 1]';
t6 = t5;
t7 = t5;
t=[t1;t2;t3;t4;t5;t6;t7];

INSP = unicode2native(inspectionDirection);
run parametri_PID.m

%% Navigation System parameters
% here, the Navigation System parameters are included
% Definition of noise covariances
n_gps   =   1.7778;                                    % variance of GPS 
n_depth =   ((5000/3)/(rho*9.81))^2;                            % variance of pressure sensor
n_dvl   =   0.005^2;                                        % variance of DVL     
n_ahrs  =   ([1 1 2] * pi/180).^2;                             % variance of AHRS

% EKF Initialization
diagonal    =  [n_ahrs(1), n_ahrs(2), n_ahrs(3), ...
                n_dvl, n_dvl, n_dvl];
Q           =   diag(diagonal);                             % covariance matrix of model noise

diagonal    =   [n_gps, n_gps, n_depth];        
R           =   diag(diagonal);                             % covariance matrix of measure noise

H           =   eye(3);

% number of samples needed to initialize the filter: 1 to initialize with the first received value 
num_cycle   =   5;                                      


%% System parameters loaded
disp('Done')


%run modello_completo_simulink2019b
