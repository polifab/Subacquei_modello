function [s,son]  = Sonar_id(xNorth,yEast,zDown,roll,pitch,yaw,pylonRadius,s_data)
%SONAR_ID
%     [s] = Sonar_id(xNorth,yEast,zDown,roll,pitch,yaw,pylonRadius,s_data)
%
% Returns the ideal sonar sensors outputs. Considers the emission cone
% angle
%
% s is a vector of the ideal sonar measurements from left to right (top view)


global x_pyl y_pyl t_son a_1 a_2 b_1 b_2

%% Pylon definition

%syms x_pyl y_pyl t_son real

eq1 = x_pyl^2 + y_pyl^2 == pylonRadius^2;           % The cylinder center is in the origin [0,0,0] 


%% Sonars

% Rotation matrix of the body reference system
%rot = rotz(yaw) * roty(pitch) * rotx(roll);
rotaz = [cos(yaw),-sin(yaw),0;sin(yaw),cos(yaw),0;0,0,1];
rotay = [cos(pitch),0,sin(pitch);0,1,0;-sin(pitch),0,cos(pitch)];
rotax = [1,0,0;0,cos(roll),-sin(roll);0,sin(roll),cos(roll)];
rot = rotaz * rotay * rotax;

% Rotations to take into account the cone extension
rotaz3 = [cos(s_data.cang),-sin(s_data.cang),0;sin(s_data.cang),cos(s_data.cang),0;0,0,1];
rotay3 = [cos(s_data.cang),0,sin(s_data.cang);0,1,0;-sin(s_data.cang),0,cos(s_data.cang)];

% Rotation to resample an additional point
ang = s_data.cang/2;
rotaz4 = [cos(ang),-sin(ang),0;sin(ang),cos(ang),0;0,0,1];
rotay4 = [cos(ang),0,sin(ang);0,1,0;-sin(ang),0,cos(ang)];
ang = s_data.cang/4;
rotaz5 = [cos(ang),-sin(ang),0;sin(ang),cos(ang),0;0,0,1];
rotay5 = [cos(ang),0,sin(ang);0,1,0;-sin(ang),0,cos(ang)];

s_data.num = 5;

son = zeros(s_data.num,5);                                      % Initialization of the array of the sonar cone sample measurements
s = zeros(s_data.num,1);                                        % Initialization of the array of the final sonar measurements (ideal output)

j = (s_data.num+1)/2;

for i=1:s_data.num
    dp = rot * s_data.pos(1:3,i);                               % Position of the i_th sensor relative to the AUV center in NED
    
    p = [xNorth + dp(1); yEast + dp(2); zDown + dp(3)];         % Position of the i_th sensor relative to the pylon center in NED
    
    %dir = rot * rotz((-j+i) * s_data.delta) * [1;0;0];       	% Direction of the i_th sonar
    
    % Rotation to take into account the sonar direction relative to the AUV
    rotaz2 = [cos((-j+i) * s_data.delta),-sin((-j+i) * s_data.delta),0;sin((-j+i) * s_data.delta),cos((-j+i) * s_data.delta),0;0,0,1];
    
    counter = 0;            % Number of sample points which intersecate the pylon
    full = [];              % Vector of the indices of the sample points which does intersecate the cone
    void = [];              % Vector of the indices of the sample points which does not intersecate the cone

    for k=1:5
    % Cone sampling cycle
        son(i,k) = son_padremaronn(k,rot,rotaz2,rotaz3,rotay3,eq1,x_pyl,y_pyl,t_son,p);
        if isnan(son(i,k))
            void(end+1) = k;
        else
            counter = counter+1;
            full(end+1) = k;
        end
    end
    
    switch counter
        case 5
        % All sample lines intersecate the pylon
            c = son(i,1);
            eq21 = son(i,2)-son(i,1) == a_1-b_1;
            eq22 = son(i,3)-son(i,1) == a_1+b_1;
                
            eq23 = son(i,4)-son(i,1) == a_2-b_2;
            eq24 = son(i,5)-son(i,1) == a_2+b_2;
                
          	[sa_1, sb_1] = solve([eq21,eq22], [a_1,b_1]);
          	[sa_2, sb_2] = solve([eq23,eq24], [a_2,b_2]);
            
            sa_1 = double(sa_1);
            sa_2 = double(sa_2);
            sb_1 = double(sb_1);
            sb_2 = double(sb_2);
            
         	fun = @(x,y) c + sa_1.*x.^2 + sb_1 .* x + sa_2 .* y.^2 + sb_2 .* y;
         	polarfun = @(theta,r) fun(r.*cos(theta),r.*sin(theta)).*r;
                
           	s(i) = integral2(polarfun,0,2*pi,0,1) / pi;
        case 4
        % One sample line does not intersecate the pylon
            son(i,void) = son_padremaronn(void,rot,rotaz2,rotaz4,rotay4,eq1,x_pyl,y_pyl,t_son,p);
            if isnan(son(i,void))
            % Resampling failed
                switch void
                % Reorder the vector
                    case 2
                        son2 = [son(i,1), son(i,4), son(i,5), son(i,3)];
                    case 3
                        son2 = [son(i,1), son(i,4), son(i,5), son(i,2)];
                    case 4
                        son2 = [son(i,1), son(i,2), son(i,3), son(i,5)];
                    case 5
                        son2 = [son(i,1), son(i,2), son(i,3), son(i,4)];
                end                
                c = son2(1);
                eq21 = son2(2)-son2(1) == a_1-b_1;
                eq22 = son2(3)-son2(1) == a_1+b_1;
                
                sb_2 = ( son2(4)-son2(1) );
                
                [sa_1, sb_1] = solve([eq21,eq22], [a_1,b_1]);
                
                sa_1 = double(sa_1);
                sb_1 = double(sb_1);
                
                fun = @(x,y) c + sa_1.*x.^2 + sb_1 .* x + sb_2 .* y;
                polarfun = @(theta,r) fun(r.*cos(theta),r.*sin(theta)).*r;
                
                s(i) = integral2(polarfun,0,pi,0,1) / (pi/2);
                
            else
            % Resampling successfull
                switch void
                % Reorder the vector
                    case 2
                        son2 = [son(i,1), son(i,4), son(i,5), son(i,3), son(i,2)];
                    case 3
                        son2 = [son(i,1), son(i,4), son(i,5), son(i,2), son(i,3)];
                    case 4
                        son2 = [son(i,1), son(i,2), son(i,3), son(i,5), son(i,4)];
                    case 5
                        son2 = [son(i,1), son(i,2), son(i,3), son(i,4), son(i,5)];
                end

                c = son2(1);
                eq21 = son2(2)-son2(1) == a_1-b_1;
                eq22 = son2(3)-son2(1) == a_1+b_1;
                    
                eq23 = son2(4)-son2(1) == a_2-b_2;
                eq24 = son2(5)-son2(1) == (sin(ang)/sin(s_data.cang))^2 * a_2 + (sin(ang)/sin(s_data.cang)) * b_2;
                    
              	[sa_1, sb_1] = solve([eq21,eq22], [a_1,b_1]);
              	[sa_2, sb_2] = solve([eq23,eq24], [a_2,b_2]);
                
                sa_1 = double(sa_1);
                sa_2 = double(sa_2);
                sb_1 = double(sb_1);
                sb_2 = double(sb_2);
            
                fun = @(x,y) c + sa_1.*x.^2 + sb_1 .* x + sa_2 .* y.^2 + sb_2 .* y;
                ymin = @(x) - sin(acos(x));
                ymax = @(x) + sin(acos(x));
                
                area = (pi - acos(sin(ang)/sin(s_data.cang))) + sin(ang)/sin(s_data.cang) * (1 - (sin(ang)/sin(s_data.cang))^2)^0.5;
                s(i) = integral2(fun,-1,sin(ang)/sin(s_data.cang),ymin,ymax) / area;
            end
        case 3
        % 2 sample lines do not intersecate the pylon
            if isnan(son(i,1))
            % If the central sonar does not intersecate the pylon (should not be happening)
                s(i) = ( son(i,full(1)) + son(i,full(2)) + son(i,full(3)) ) / 3;
            else
            % If the central sonar does not intersecate the pylon
                s(i) = ( son(i,1) + son(i,full(1)) + son(i,full(2)) + son(i,full(3)) ) / 4;         % Central measurement has doubled weight (more important)
            end
        case 2
        % Only 2 salmple lines intersecate the pylon
            if isnan(son(i,1))
            % If the central sonar does not intersecate the pylon
                % Resample
                son(i,1) = son_padremaronn(full(1),rot,rotaz2,rotaz5,rotay5,eq1,x_pyl,y_pyl,t_son,p);
                if isnan(son(i,1))
                % Resampling failed
                    s(i) = NaN;
                else
                % Resampling successfull
                    s(i) = ( son(i,full(1)) + son(i,full(2)) + 2*son(i,1) ) / 4;
                end
            else
            % Central sonar intersecate the pylon
                s(i) = (2*son(i,1) + son(i,full(2)) ) / 3;                                           % Central measurement has doubled weight (more important)
            end
        case 1
        % Only 1 salmple line intersecates the pylon
            if isnan(son(i,1))
                % Resampling
                son(i,1) = son_padremaronn(full,rot,rotaz2,rotaz5,rotay5,eq1,x_pyl,y_pyl,t_son,p);
                if isnan(son(i,1))
                % Resampling failed
                    s(i) = NaN;
                else
                % Resampling successfull
                    s(i) = son(i,1);
                end
            else
            % Central sonar intersecates the pylon and the other sampling
            % lines do not ==> the AUV is far from the pylon and the
            % central sonar is a good enough approximation
                s(i) = son(i,1);
            end
        case 0
        % No salmple line intersecate the pylon
            s(i) = NaN;
    end

end

end


%% Auxiliary Function
function son = son_padremaronn(k,rot,rotaz2,rotaz3,rotay3,eq1,x_pyl,y_pyl,t_son,p)
% Calculate the distance from the pylon along a sampling line

    switch k
    % to define the sampling line of the cone
        case 1
            dir = rot * rotaz2 * [1;0;0];                       % Direction of the central sonar point
        case 2
            dir = rot * rotaz2 * (rotaz3.') * [1;0;0];          % Direction of the left sonar point
        case 3
            dir = rot * rotaz2 * rotaz3 * [1;0;0];              % Direction of the right sonar point
        case 4
            dir = rot * rotaz2 * (rotay3.') * [1;0;0];          % Direction of the bottom sonar point
        case 5
            dir = rot * rotaz2 * (rotay3) * [1;0;0];            % Direction of the top sonar point
    end
                
    % Sensor line parametric equation
    eq2 = x_pyl == p(1) + dir(1) * t_son;
    eq3 = y_pyl == p(2) + dir(2) * t_son;
    %eq4 = z_pyl == p(3) + dir(3) * t; Not necessary! :)

    sol = vpasolve([eq1, eq2, eq3], [x_pyl, y_pyl, t_son]);

    if isempty(sol.t_son)>0
        son = NaN;
    elseif sol.t_son<0
        % It means the pylon is behind
      	son = NaN;
    else
    % To take into account that there are 2 solutions, only the smaller one
    % is relevant (if outside the pylon)
        if (sol.t_son(1) <= sol.t_son(2))
            son = sol.t_son(1);
        else
            son = sol.t_son(2);
        end
    end
end

