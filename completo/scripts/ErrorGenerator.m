function out = ErrorGenerator(in)

global lat_pylon lon_pylon h_pylon;
persistent wgs84;
wgs84 = wgs84Ellipsoid('meter');
%--------- estimated bus -------------

estDepth = in(1); % [m]
%estAbsPos = in(2:3); % lat lon [deg]
estAbsRP = in(4:5); %roll pitch
estAbsYaw = in(6); % yaw [rad]
estSurgeVel = in(7); % v_x [m/s]
estSwayVel = in(8); % v_y [m/s]
estRelDis = in(13); % [m]
estRelYaw = in(14); % [rad]

%--------- desired bus -------------
desDepth = in(15);
desRP = in(16:17);
%desAbsPos = in(18:19);
desAbsYaw = in(20);
desRelDis = in(21);
desRelYaw = in(22);
desSwayVel = in(23);
desSurgeVel = in(24);

navErrFlag = in(25);
current_state = in(26); 
refMode = in(27);

% [est_x_ned, est_y_ned, est_z_ned] = geodetic2ned(estAbsPos(1),estAbsPos(2),estDepth, lat_pylon, lon_pylon, h_pylon, wgs84);
% [des_x_ned, des_y_ned, des_z_ned] = geodetic2ned(desAbsPos(1),desAbsPos(2),desDepth, lat_pylon, lon_pylon, h_pylon, wgs84);
% distAbsPos = norm( [est_x_ned, est_y_ned, est_z_ned]-[des_x_ned, des_y_ned, des_z_ned]);
    
%tolleranze

errAngle = 3000*pi/180; %[rad]
errDepth = 2; %[m]
errRelDis = 3; %[m]
errVel = 0.4; %[rad/s]
Yaw = min(2*pi-abs(estAbsYaw-desAbsYaw),abs(estAbsYaw-desAbsYaw)); 
ErrorFlag = 0;

if navErrFlag == 1 
    ErrorFlag = 1; %errore dei snesori -> annullo la missione
elseif navErrFlag == 0 && (any(abs(estAbsRP - desRP) > errAngle) || abs(desDepth - estDepth)> errDepth)
    ErrorFlag = 2;
elseif navErrFlag == 0 && refMode == 0 && abs(desSurgeVel - estSurgeVel) > errVel
    ErrorFlag = 2; 
elseif navErrFlag == 0 && refMode == 1 && (abs(estRelYaw-desRelYaw) > errAngle || ...
       abs(desSwayVel - estSwayVel) > errVel || abs(estRelDis - desRelDis ) > errRelDis )
   ErrorFlag = 2; 
elseif navErrFlag == 0 && current_state == 102 && Yaw > errAngle
    ErrorFlag = 2;
    
elseif navErrFlag == 0 && refMode == -1 && current_state ~= 500
    ErrorFlag = 0; 
end

out = ErrorFlag;
end
