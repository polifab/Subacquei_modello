%% DrawMissionLine
% Draw cylinder and auv trajectory


%% Usage drawMissionLine
%
% After simulink simulation run: 
% >> drawMissionLine(pylonCenter, initPoint, out)    
% then wait a few seconds
%
function drawMissionLine(pylonCenter,auvCoordinates,out)
realCoordinates = out.real_coord_geodetic;
estimatedCoordinates = out.est_coord;
close all

draw_environment(pylonCenter,auvCoordinates);                              % Draw cylinder and auv in initial point

% Normalize number of points to show. 
resolution=100;                                                            % Show only 'resolution' point

% Compute space between points
delta = min(round(length(realCoordinates)/resolution), round(length(estimatedCoordinates)/resolution));

% Make sure to avoid index out of bounds
point=min(length(realCoordinates), length(estimatedCoordinates));

disp('wait...');
for i=1:delta:point
    draw_movement(realCoordinates(i,:), 'g');                              % The real movement is colored in green
    draw_movement(estimatedCoordinates (i,:), 'b');                        % The estimated movement is colored in blue
end
end

%% draw_environment
%
% Draw environment and auv in your intial point 
%
function draw_environment(pylon_coordinates, auv_coordinates)

% Cylinder is the center of reference system
latOrigin = pylon_coordinates(1);                                          % [°]
lonOrigin = pylon_coordinates(2);                                          % [°]
hOrigin   = 0;                                                             % [m]

% AUV coordinates
latInit = auv_coordinates(1);                                              % [°]
lonInit = auv_coordinates(2);                                              % [°]
hInit   = - auv_coordinates(3);                                            % [m]

% Building AUV
cylinder_resolution = 100;
pylon_radius = 10;
area_depth = 40;
[X,Y,Z] = cylinder(pylon_radius, cylinder_resolution);
h_cylinder = area_depth;
Z = Z * h_cylinder;

% Cast coordinates AUV
[xNorth, yEast, zDown] = geodetic2nedS(latInit, lonInit, hInit, latOrigin, lonOrigin, hOrigin);

% Draw AUV
xc = xNorth;
yc = yEast;
zc = zDown;
xr = 0.35 * 2;                                                             % Auv size
yr = 0.35 * 2;                                                             % Bigger then AUV because it's the initial point
zr = 0.19 * 2;
auv_resolution = cylinder_resolution/4;
[x,y,z] = ellipsoid(xc, yc, zc, xr, yr, zr, auv_resolution);

% Plot
plot3(y,x,z,'r');                                                          % AUV is red
hold on
plot3(Y,X,Z,'k');                                                          % Cylinder is black
set(gca, 'ZDir','reverse');
axis equal

xlabel('Y'); 
ylabel('X');
zlabel('Depth');
grid on;

% Set scene limit (xmin, xmax, ymin, ymax, hmin, hmax)
axis([-50 50 -50 50 -10 40]);
end

%% draw_movement
% 
% Draw movement of auv.
% Just plot other cylinder. Simplistic method
%
function draw_movement(auv_coordinates, color)

% Cylinder is the center of reference system
latOrigin = 43.723046;                                                     %[decimal degrees]
lonOrigin = 10.396635;                                                     %[decimal degrees]
hOrigin   = 0;                                                             %[m]

% AUV coordinates
latInit = auv_coordinates(1);                                             %[decimal degrees]
lonInit = auv_coordinates(2);                                             %[decimal degrees]
hInit   = - auv_coordinates(3);                                           %[m]

% Cast coordinates AUV 
[xNorth, yEast, zDown] = geodetic2nedS(latInit, lonInit, hInit, latOrigin, lonOrigin, hOrigin);

% Building AUV
xc = xNorth;
yc = yEast;
zc = zDown;
xr = 0.35;                                                                 %Auv size
yr = 0.35;
zr = 0.19;
auvResolution = 40;
[x,y,z] = ellipsoid(xc, yc, zc, xr, yr, zr, auvResolution);

%Plot new position/cylinder
plot3(y,x,z,color);
hold on
end
