function out = StateTransition(in)

global lat_pylon lon_pylon h_pylon ;
persistent wgs84;
wgs84 = wgs84Ellipsoid('meter');

%--------- estimated bus -------------
estDepth = in(1); % [m]
estPos = in(2:3); % lat lon [deg]
estRP = in(4:5); %roll pitch
estAbsYaw = in(6); % yaw [rad]
estVel = in(7:9); % v_x, v_y, v_z [m/s]
estAngVel = in(10:12); % [rad/s]
estRelDis = in(13); % [m]
estRelYaw = in(14); % [rad]

%--------- desired bus -------------
finalPos = in(15:16); %[deg]
finalDepth = in(17);
finalAbsYaw = in(18);
finalRelYaw = in(19);
finalRelDis = in(20);

%------
time_transition = in(21);
T_202 = in(22);
actual_time = in(23);

%----------- 
mode_inspection = in(24); %1 -> vertical | 0 -> horizontal

%--------- 
ErrorFlag = in(25);
current_state = in(26);

if (actual_time <= time_transition + T_202 * 0.5) && (current_state == 202 && mode_inspection == 0)
    estPos = [0; 0];
end

% --------- calcolo distanza
[est_x_ned, est_y_ned, est_z_ned] = geodetic2ned(estPos(1),estPos(2),0, lat_pylon, lon_pylon, h_pylon, wgs84);
[fin_x_ned, fin_y_ned, fin_z_ned] = geodetic2ned(finalPos(1),finalPos(2),0, lat_pylon, lon_pylon, h_pylon, wgs84);
distPos = norm( [est_x_ned, est_y_ned, est_z_ned]- [fin_x_ned, fin_y_ned, fin_z_ned]);
%     R = 6371e3; % raggio della terra [m]
%     x = (estPos(1)-finalPos(1))*cos((estPos(2)-finalPos(2))/2);
%     y = (estPos(2)-finalPos(2));
%     distPos1 = sqrt(x^2 + y^2) * R;

% ----------- tolleranze
errAngle = pi/180; %[rad]
errPos = 0.5; %[m]
errRelDist = 0.5; %[m]
errVel = 0.10; %[m/s]
errAngVel = 5 * pi/180;
errDepth = 0.2;
%---- da chiedere al navigation di mandare lo yaw abs da 0 a 360
% ----- tutti gli altri angoli da -180 a 180
Yaw = min(2*pi-abs(estAbsYaw-finalAbsYaw),abs(estAbsYaw-finalAbsYaw));

if ErrorFlag == 0  
    if current_state == 401 && estDepth < errDepth
        readytoswitchFlag = 1;
        disp ('INCREDIBILE!!! Missione terminata con successo')
    elseif current_state == 500 && estDepth < errDepth && ErrorFlag>1
        disp('AUV è tornato in superficie')
    elseif (current_state == 101 || current_state == 102) && ...
            ((distPos > errPos) || any(abs(estVel) > errVel) ||...
            any(abs(estRP) > errAngle) ||(Yaw > errAngle) || any(abs(estAngVel)> errAngVel) || ...
            abs(estDepth - finalDepth) > errDepth)
        readytoswitchFlag = 0;
        
    elseif (current_state ~= 101 && current_state ~= 102) && ...
            ((distPos > errPos) || any(abs(estVel) > errVel) ||...
            any(abs(estRP) > errAngle) ||(Yaw > errAngle) || any(abs(estAngVel)> errAngVel) ||...
            abs(estDepth - finalDepth) > errDepth|| (abs(finalRelYaw - estRelYaw) > errAngle) ||...
            (abs(finalRelDis - estRelDis) > errRelDist))
       readytoswitchFlag = 0;
    elseif current_state == 500
        readytoswitchFlag = 0;
    else        
        readytoswitchFlag = 1;
    end  
elseif ErrorFlag > 0
    readytoswitchFlag = 0;
end

out = [readytoswitchFlag, ErrorFlag];
end


