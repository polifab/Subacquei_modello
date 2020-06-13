function [xNorth, yEast, zDown] = geodetic2nedS( ...
    lat, lon, h, lat0, lon0, h0, angleUnit)

inDegrees = (nargin < 8 || map.geodesy.isDegree(angleUnit));
[yEast, xNorth, zUp] = geodetic2enuFormulaS( ...
    lat, lon, h, lat0, lon0, h0, inDegrees);
zDown = -zUp;
end

function [xEast, yNorth, zUp] = geodetic2enuFormulaS( ...
    lat, lon, h, lat0, lon0, h0, inDegrees)

% Cartesian offset vector from local origin to (LAT, LON, H).
[dx, dy, dz] = ecefOffsetFormulaS(lat0, lon0, h0, lat, lon, h, inDegrees);

if inDegrees
    % Offset vector from local system origin, rotated from ECEF to ENU.
    [xEast, yNorth, zUp] = ecef2enuvFormulaS(dx, dy, dz, lat0, lon0, @sind, @cosd);
else
    % Offset vector from local system origin, rotated from ECEF to ENU.
    [xEast, yNorth, zUp] = ecef2enuvFormulaS(dx, dy, dz, lat0, lon0, @sin, @cos);
end
end

function [deltaX, deltaY, deltaZ] = ecefOffsetFormulaS( ...
     phi1, lambda1, h1, phi2, lambda2, h2, inDegrees)

    a = 6378137; 
    f = 0.0034;
    
    if inDegrees
        s1 = sind(phi1);
        c1 = cosd(phi1);
        
        s2 = sind(phi2);
        c2 = cosd(phi2);
        
        p1 = c1 .* cosd(lambda1);
        p2 = c2 .* cosd(lambda2);
        
        q1 = c1 .* sind(lambda1);
        q2 = c2 .* sind(lambda2);
    else
        s1 = sin(phi1);
        c1 = cos(phi1);
        
        s2 = sin(phi2);
        c2 = cos(phi2);
        
        p1 = c1 .* cos(lambda1);
        p2 = c2 .* cos(lambda2);
        
        q1 = c1 .* sin(lambda1);
        q2 = c2 .* sin(lambda2);
    end
    
    if f == 0
        % Spherical case
        deltaX = a * (p2 - p1) + (h2 .* p2 - h1 .* p1);
        deltaY = a * (q2 - q1) + (h2 .* q2 - h1 .* q1);
        deltaZ = a * (s2 - s1) + (h2 .* s2 - h1 .* s1);
    else
        % Oblate spheroid case
        e2 = f * (2 - f);
        w1 = 1 ./ sqrt(1 - e2 * s1.^2);
        w2 = 1 ./ sqrt(1 - e2 * s2.^2);
        deltaX =            a * (p2 .* w2 - p1 .* w1) + (h2 .* p2 - h1 .* p1);
        deltaY =            a * (q2 .* w2 - q1 .* w1) + (h2 .* q2 - h1 .* q1);
        deltaZ = (1 - e2) * a * (s2 .* w2 - s1 .* w1) + (h2 .* s2 - h1 .* s1);
    end
    
end

function [uEast, vNorth, wUp] ...
    = ecef2enuvFormulaS(u, v, w, lat0, lon0, sinfun, cosfun)

cosPhi = cosfun(lat0);
sinPhi = sinfun(lat0);
cosLambda = cosfun(lon0);
sinLambda = sinfun(lon0);

t     =  cosLambda .* u + sinLambda .* v;
uEast = -sinLambda .* u + cosLambda .* v;

wUp    =  cosPhi .* t + sinPhi .* w;
vNorth = -sinPhi .* t + cosPhi .* w;
end