%% Mission Supervisor initialization file
% take the mission's parameters and calculates the trajectory points

% model of the earth
wgs84 = wgs84Ellipsoid('meter');

% Matrix database
M100 = []; % 7 x 12
M201 = [];
M202 = [];

%% Sample Time Mission Supervisor
misu_Ts = 1/10;


%% Common:
global vel speed_z speed_yaw lat_pylon lon_pylon h_pylon;
vel = speed;
speed_z = 0.2; % [m/s]
speed_yaw = pi/6; % [rad/s] % not used anymore

% NED origin (sea level in the center of the pylon)
lat_pylon = pylonCenter(1);
lon_pylon = pylonCenter(2);
h_pylon = 0;


% initial point coordinates in NED
lat_init = initPoint(1);
lon_init = initPoint(2);
h_init = initPoint(3);

[xn_init,yn_init,zn_init] = geodetic2ned(lat_init,lon_init,h_init,lat_pylon,lon_pylon,h_pylon,wgs84);

initPoint_NED = [xn_init; 
                 yn_init;
                 zn_init];


%% Approach transepts
% Yaw rotation in order to point the pylon
V101i = [initPoint_NED;
         0];
V101f = [initPoint_NED;
         wrapTo2Pi(atan2(-initPoint_NED(2),-initPoint_NED(1)))]; % - point to the NED origin (pylonCenter) atan2_2_360NED
S101 = [0, 0, 0, s_yaw(0,V101f(4))];
M100(1,1:4)=V101i';
M100(1,5:8)=V101f';
M100(1,9:12)=S101;

% Approaching the pylon with constant surge velocity and yaw pointing the center of the pylon 
V102i = V101f;
V102f = [V102i(1:3)/norm(V102i(1:3))*(pylonRadius+distance);
         V101f(4)];
if norm(V102f(1:2)-V102i(1:2)) > 100
    disp('Wajò! più? di cento metri, vado comunque ma sappi che le batterie non basteranno, mi dovresti portare con la barchetta!')
end
S102 = [s_xy(V102i(1:2),V102f(1:2)), 0, 0];
M100(2,1:4)=V102i';
M100(2,5:8)=V102f';
M100(2,9:12)=S102;

% Rotation around the pylon in order to reach the initial inspection position
V103i = V102f;
V103f_xy = [cos(deg2rad(initInspectionDirection)); sin(deg2rad(initInspectionDirection))]*(pylonRadius+distance);
V103f = [V103f_xy;
         0;...
         wrapTo2Pi(deg2rad(initInspectionDirection)+pi)];
S103 = [s_xy(V103i(1:2),V103f(1:2)), 0, s_yaw(V103i(4),V103f(4))]; % NO, for circonferential trajectory the ramps are variable
M100(3,1:4)=V103i';
M100(3,5:8)=V103f';
M100(3,9:12)=S103;

% Reaching the initial depth for the ispection
V104i = V103f;
V104f = [V104i(1:2);...
         initDepth;
         V104i(4)];
S104 = [0, 0, s_z(V104i(3),V104f(3)), 0];
M100(4,1:4)=V104i';
M100(4,5:8)=V104f';
M100(4,9:12)=S104;

% Estimate times for transepts
if abs(M100(1,8)) <= abs(2*pi-M100(1,8))
    T_101 = abs(M100(1,8))/speed_yaw;
else
    T_101 = abs(2*pi-M100(1,8))/speed_yaw;
end
T_102 = norm(V102f(1:2)-V102i(1:2))/vel;
if abs(M100(3,8)-M100(3,4)) <= (2*pi-abs(M100(3,8)-M100(3,4)))
    T_103 = (pylonRadius+distance)*abs(M100(3,8)-M100(3,4))/vel;
else
    T_103 = (pylonRadius+distance)*(2*pi-abs(M100(3,8)-M100(3,4)))/vel;
end
T_104 = M100(4,7)/speed_z;


%% Inspection (while loops simulate the entire inspection in order to calculate right points)
% Loop variables initialization
p_temp = V104f;
p_fin = p_temp;
counter = 1;
counter1 = 1;
change = 0;
if (initDepth-finalDepth) > 0
    dir = 1;
elseif (initDepth-finalDepth) < 0
    dir = -1;
end
f = 0;
f1 = 0;
f2 = 0;
pylonRot = 0;

% 201: change in depth at fixed position
% 202: relative rotation about the center of the pylon

% Horizontal inspection (first 202 then 201)
if length(inspectionDirection) == length('horizontal')
    bool_inspection = 0;
    T_201 = horizontalTranseptsDistance/speed_z;
    T_202 = 2*pi*(pylonRadius+distance)/vel;
    while f == 0
        if (mod(counter1,2) ~= 0) && (change == 0)
            change = 1;
            counter1 = counter1 + 1;
            M202(counter,1:4) = p_temp';
            M202(counter,5:8) = p_temp';
            M202(counter,9:12) = [0,0,0,0];
            if f1 == 1
                f = 1;
            else
                continue;
            end
        elseif (mod(counter1,2) == 0) && (change == 1)
            change = 0;
            counter1 = counter1 + 1;
            M201(counter,1:4) = p_temp';
            
            if f2 == 0
                if abs( (p_temp(3)-dir*horizontalTranseptsDistance)-finalDepth ) >= horizontalTranseptsDistance
                    p_fin = [p_temp(1:2); p_temp(3)-dir*horizontalTranseptsDistance; p_temp(4)];
                elseif abs( (p_temp(3)-dir*horizontalTranseptsDistance)-finalDepth ) == 0
                    p_fin = [p_temp(1:2); p_temp(3)-dir*horizontalTranseptsDistance; p_temp(4)];
                    f1 = 1;
                else
                    p_fin = [p_temp(1:2); p_temp(3)-dir*horizontalTranseptsDistance; p_temp(4)];
                    f2 = 1;
                end
            else
                p_fin = [p_temp(1:2); finalDepth; p_temp(4)];
                f1 = 1;
            end
                
            M201(counter,5:8) = p_fin';
            M201(counter,9:12) = [0,0,s_z(p_temp(3),p_fin(3)),0];
            p_temp = p_fin;
            counter = counter + 1;
        end
    end
% Vertical inspection (first 201 then 202)
elseif length(inspectionDirection) == length('vertical')
    bool_inspection = 1;
    T_201 = abs(initDepth-finalDepth)/speed_z;
    T_202 = deg2rad(verticalTranseptsDistance)*(pylonRadius+distance)/vel;
    while f == 0
        if (mod(counter1,2) ~= 0) && (change == 0)
            change = 1;
            counter1 = counter1 + 1;
            M201(counter,1:4) = p_temp';
            if f2 == 0
                p_fin = [p_temp(1:2); finalDepth; p_temp(4)];
                f2 = 1;
            else
                p_fin = [p_temp(1:2); initDepth; p_temp(4)];
                f2 = 0;
            end
            M201(counter,5:8) = p_fin';
            M201(counter,9:12) = [0,0,s_z(p_temp(3),p_fin(3)),0];
            p_temp = p_fin;
            if f1 == 1
                f = 1;
            end
        elseif (mod(counter1,2) == 0) && (change == 1)
            change = 0;
            counter1 = counter1 + 1;
            M202(counter,1:4) = p_temp';
            if p_temp(4)-deg2rad(verticalTranseptsDistance) >= 0
                p_fin = [rot_z(p_temp(1:2),-deg2rad(verticalTranseptsDistance)); p_temp(3); p_temp(4)-deg2rad(verticalTranseptsDistance)]; % - => from above is ccw
            else
                p_fin = [rot_z(p_temp(1:2),-deg2rad(verticalTranseptsDistance)); p_temp(3); 2*pi+(p_temp(4)-deg2rad(verticalTranseptsDistance))];
            end
            M202(counter,5:8) = p_fin';
            M202(counter,9:12) = [0,0,0,0]; % RAMPS FOR CIRCULAR TRAJECTORY ON SIMULINK OR HERE WITH Ts?
            p_temp = p_fin;
            pylonRot = pylonRot + verticalTranseptsDistance;
            if pylonRot >= (360-verticalTranseptsDistance)
                f1 = 1;
            end
            counter = counter + 1;
        end
    end
else
    disp('ERROR: inspectionDirection not recognised !')
end


%% Return to home
% Return at sea level
M100(5,1:4)=p_temp';
M100(5,5:8)=[p_temp(1:2); 0; p_temp(4)]';
M100(5,9:12)=[0,0,s_z(p_temp(3),0),0];
T_401 = M100(5,3)/speed_z;


%% Final values
checkpoints = [M100; M201; M202];
lenght_fixed = size(M100,1);
counter_max = max(size(M201,1),size(M202,1));
length_201 = size(M201, 1);


%% Utilities function
function out = atan2_2_360NED(var_ang)
    
    if (var_ang >= pi/2) && (var_ang <= pi)
        var_ang = var_ang - pi/2;
        out = 2*pi-var_ang;
    elseif (var_ang >= -pi) && (var_ang < pi/2)
        var_ang = var_ang + 3*pi/2;
        out = 2*pi-var_ang;
    else
        disp('atan2_2_360NED error: the var_ang must be in [-pi, +pi] as output of atan2()')
        disp(var_ang)
    end
end

function s = s_xy(v_start,v_stop)
    
    global vel;
    if norm(v_stop-v_start) > 1e-3
        s = vel*(v_stop-v_start)/norm(v_stop-v_start);
        s = s';
    else
        s = [0, 0];
    end
end

function s = s_z(start,stop)

    global speed_z;
    s = sign(stop-start)*speed_z;
end

function s = s_yaw(start,stop)
    
    global speed_yaw;
    if (stop-start) > 0
        if (stop-start) <= (start+2*pi-stop)
            s = speed_yaw;
        else
            s = -speed_yaw;
        end
    elseif (stop-start) < 0
        if (start-stop) < (stop+2*pi-start)
            s = speed_yaw;
        else
            s = speed_yaw;
        end
    else
       s = 0;
    end
end

function v = rot_z(vect,var_ang)
% var_ang must be positive in NED 
    R_z = [cos(var_ang), -sin(var_ang);... 
           sin(var_ang),  cos(var_ang)];
    v = R_z*vect;
end

function theta = angle_betw(vect1,vect2)
% Returns the angle between 2 2D vectors in [-pi pi]
% positive (cartesian plane) if it goes from vect1 to vect2
    
    if cross(vect1,vect2) > 0
        theta = atan2(norm(cross(vect1,vect2)),dot(vect1,vect2));
    elseif cross(vect1,vect2) < 0
        theta = -atan2(norm(cross(vect1,vect2)),dot(vect1,vect2));
    else
        theta = 0;
    end
end

























    
    
    
    
    
    


        
       