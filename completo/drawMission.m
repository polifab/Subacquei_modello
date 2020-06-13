function drawMission(pylonRadius,pylonCenter,areaDepth,out,s_data)
%SONAR_ID
%     [s] = Sonar_id(xNorth,yEast,zDown,roll,pitch,yaw,pylonRadius,s_data)
%
% Returns the ideal sonar sensors outputs
% s is a vector of the ideal sonar measurements from left to right (top view)

%% Initialization

close all

disp('Wait bro, Im doin my job...');

global mov_plot pos_plot son_plot

son_plot = scatter3(0,0,0);
mov_plot = scatter3(0,0,0);
pos_plot = scatter3(0,0,0);

est_coord = NaN(length(out.est_coord),3);
for i=1:length(out.est_coord)
    est_coord(i,:) = conv_geo2ned(pylonCenter,out.est_coord(i,:));
end

dir = zeros(length(out.real_coord)*3, 25);
for i=1:length(out.real_coord)
    dir((3*i-2):3*i,:) = sonardir(out.real_coord(i,4),out.real_coord(i,5),out.real_coord(i,6),s_data);
end    

draw_env(pylonRadius,areaDepth)


%% Plot

for i=1:length(out.real_coord)
    draw_movement(out.real_coord(i,1:3), 'g');
    
    draw_movement(est_coord(i,:), 'm');
    
    drawSonar(out.real_coord(i,1:3),dir(3*i-2:3*i,:),out.sonar_meas(i,:),out.sonar_meas1(:,:,i),s_data);
    
    draw_position(out.real_coord(i,1:3), 'k');
    
    drawnow
end

end


%% Plot the environment (the pylon)
function draw_env(pylonRadius,areaDepth)

cyl_res = 24;
[X,Y,Z] = cylinder(pylonRadius, cyl_res);
hCylinder = areaDepth;
Z = Z * hCylinder;

% Plot
figure(1)
set(gcf, 'Position', get(0, 'Screensize'));
grid on
hold on
axis equal
surf(Y,X,Z);
set(gca, 'ZDir','reverse');

xlabel('Y-East [m]');
ylabel('X-North [m]'); 
zlabel('Depth [m]');

% Limits of the plot (xmin, xmax, ymin, ymax, hmin, hmax)
axis([-50 50 -50 50 -10 40]);

view(-37.5,30)
rotate3d on

end


%% Convert coordinates from geodetic to NED (the origin is in the center of the pylon)
function [out] = conv_geo2ned(pylonCenter,auv_coord)

latOrigin = pylonCenter(1);         % [°]
lonOrigin = pylonCenter(2);         % [°]
hOrigin   = 0;                    	% [m]

lat = auv_coord(1);                 % [°]
lon = auv_coord(2);                 % [°]
h   = - auv_coord(3);               % [m]

[xNorth, yEast, zDown] = geodetic2nedS(lat, lon, h, latOrigin, lonOrigin, hOrigin);
out = [xNorth, yEast, zDown];

end


%% Plot a point in the given coordinate
function draw_movement(auv_coord,color)
global mov_plot

% To speed up the simulation the AUV is assumed pointlike
% AUV center
%xc = auv_coord(1);
%yc = auv_coord(2);
%zc = auv_coord(3);

% AUV ellipsoid definition
%xr = 0.35;
%yr = 0.35;
%zr = 0.19;
%auvResolution = 40;
%[x,y,z] = ellipsoid(xc, yc, zc, xr, yr, zr, auvResolution);


%Plot
figure(1)
scatter_size = 7;
mov_plot = scatter3(auv_coord(1),auv_coord(2),auv_coord(3),scatter_size,color,'filled');
end


%% Plot a point in the given coordinate
function draw_position(auv_coord,color)
global pos_plot

% To speed up the simulation the AUV is assumed pointlike
% AUV center
%xc = auv_coord(1);
%yc = auv_coord(2);
%zc = auv_coord(3);

% AUV ellipsoid definition
%xr = 0.35;
%yr = 0.35;
%zr = 0.19;
%auvResolution = 40;
%[x,y,z] = ellipsoid(xc, yc, zc, xr, yr, zr, auvResolution);

delete(pos_plot)

%Plot
figure(1)
scatter_size = 35;
pos_plot = scatter3(auv_coord(1),auv_coord(2),auv_coord(3),scatter_size,color,'filled');
end


%% Plot the sonar lines of view (1d to speed up the computation)
function drawSonar(auv_coord,dir,s,son,s_data)
global son_plot

x = zeros(3,2);

delete(son_plot)

for i=1:s_data.num
    for j=1:5
        for k=1:3
            if (j==1 && isnan(s(i)))
                x(k,:) = [auv_coord(k), auv_coord(k) + dir(k,(i-1)*5+j)*s_data.maxrng];
                color = 'r';
            elseif (j==1)
                x(k,:) = [auv_coord(k), auv_coord(k) + dir(k,(i-1)*5+j)*s(i)];
                color = 'c';
            elseif isnan(son(i,j))
                x(k,:) = [auv_coord(k), auv_coord(k) + dir(k,(i-1)*5+j)*s_data.maxrng];
                color = 'r';
            else
                x(k,:) = [auv_coord(k), auv_coord(k) + dir(k,(i-1)*5+j)*son(i,j)];
                color = 'c';
            end
        end
        
        if j==1 && color=='c'
            son_plot((i-1)*5+j) = plot3(x(1,:),x(2,:),x(3,:),'-x','Color',color);
        elseif j==1
            son_plot((i-1)*5+j) = plot3(x(1,:),x(2,:),x(3,:),'Color',color);
        else
            son_plot((i-1)*5+j) = plot3(x(1,:),x(2,:),x(3,:),':','Color',color);
        end
 
    end
end

end

%% Calculate sonar directions
function dir = sonardir(roll,pitch,yaw,s_data)

% Rotation matrix of the body reference system
%rot = rotz(yaw) * roty(pitch) * rotx(roll);
rotaz = [cos(yaw),-sin(yaw),0;sin(yaw),cos(yaw),0;0,0,1];
rotay = [cos(pitch),0,sin(pitch);0,1,0;-sin(pitch),0,cos(pitch)];
rotax = [1,0,0;0,cos(roll),-sin(roll);0,sin(roll),cos(roll)];
rot = rotaz * rotay * rotax;

% Rotations to take into account the cone extension
rotaz3 = [cos(s_data.cang),-sin(s_data.cang),0;sin(s_data.cang),cos(s_data.cang),0;0,0,1];
rotay3 = [cos(s_data.cang),0,sin(s_data.cang);0,1,0;-sin(s_data.cang),0,cos(s_data.cang)];

j = (s_data.num+1)/2;

dir = zeros(3,25);


for i=1:s_data.num
    rotaz2 = [cos((-j+i) * s_data.delta),-sin((-j+i) * s_data.delta),0;sin((-j+i) * s_data.delta),cos((-j+i) * s_data.delta),0;0,0,1];
        
    for k=1:5
    switch k
    % to define the sampling line of the cone
        case 1
            dir(:,k+(i-1)*5) = rot * rotaz2 * [1;0;0];                       % Direction of the central sonar point
        case 2
            dir(:,k+(i-1)*5) = rot * rotaz2 * (rotaz3.') * [1;0;0];          % Direction of the left sonar point
        case 3
            dir(:,k+(i-1)*5) = rot * rotaz2 * rotaz3 * [1;0;0];              % Direction of the right sonar point
        case 4
            dir(:,k+(i-1)*5) = rot * rotaz2 * (rotay3.') * [1;0;0];          % Direction of the bottom sonar point
        case 5
            dir(:,k+(i-1)*5) = rot * rotaz2 * (rotay3) * [1;0;0];            % Direction of the top sonar point
    end
    end
end

end
