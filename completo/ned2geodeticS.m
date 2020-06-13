function [lat, lon, h] = ned2geodeticS( ...
    xNorth, yEast, zDown, lat0, lon0, h0, angleUnit)

inDegrees = (nargin < 7 || map.geodesy.isDegree(angleUnit));

[x, y, z] = enu2ecefFormulaS( ...
    yEast, xNorth, -zDown, lat0, lon0, h0, inDegrees);

if inDegrees
    [lat, lon, h] = ecef2geodeticS(x, y, z);
else
    [lat, lon, h] = ecef2geodeticS(x, y, z, 'radian');
end
end

function [x, y, z] = enu2ecefFormulaS( ...
    xEast, yNorth, zUp, lat0, lon0, h0, inDegrees)

% Origin of local system in geocentric coordinates.
[x0, y0, z0] = geodetic2ecefFormulaS(lat0, lon0, h0, inDegrees);

% Offset vector from local system origin, rotated from ENU to ECEF.
if inDegrees
    [dx, dy, dz] = enu2ecefvFormulaS( ...
        xEast, yNorth, zUp, lat0, lon0, @sind, @cosd);
else
    [dx, dy, dz] = enu2ecefvFormulaS( ...
        xEast, yNorth, zUp, lat0, lon0, @sin, @cos);
end

% Origin + offset from origin equals position in ECEF.
x = x0 + dx;
y = y0 + dy;
z = z0 + dz;
end

function [x, y, z] = geodetic2ecefFormulaS(phi, lambda, h, inDegrees)
    
    [rho, z] = geodetic2cylindrical(phi, h, 6378137, 0.003352810664747, inDegrees);

    if inDegrees
        x = rho .* cosd(lambda);
        y = rho .* sind(lambda);
    else
        x = rho .* cos(lambda);
        y = rho .* sin(lambda);
    end
end


function [rho, z] = geodetic2cylindrical(phi, h, a, f, inDegrees)
    if f == 0
        r = h + a;
        if inDegrees
            rho = r .* cosd(phi);
            z = r .* sind(phi);
        else
            rho = r .* cos(phi);
            z = r .* sin(phi);
        end
    else
        [rho, z] = map.geodesy.internal.geodetic2cylindrical(phi, h, a, f, inDegrees);
    end
end

function [u, v, w] ...
    = enu2ecefvFormulaS(uEast, vNorth, wUp, lat0, lon0, sinfun, cosfun)
% Rotate Cartesian 3-vector from ENU to ECEF
%
%   The outputs are the same as in ENU2ECEFV. The inputs are also the same,
%   except that angleUnit string is replaced by a function handles to sine
%   and cosine functions. These are either @sind and @cosd (for origin
%   latitude/longitude in degrees) or @sin and @cos (for origin
%   latitude/longitude in radians).
%
%   See also ENU2ECEFV, NED2ECEFV

% Copyright 2012 The MathWorks, Inc.

cosPhi = cosfun(lat0);
sinPhi = sinfun(lat0);
cosLambda = cosfun(lon0);
sinLambda = sinfun(lon0);

t = cosPhi .* wUp - sinPhi .* vNorth;
w = sinPhi .* wUp + cosPhi .* vNorth;

u = cosLambda .* t - sinLambda .* uEast;
v = sinLambda .* t + cosLambda .* uEast;
end

function [phi, lambda, h] = ecef2geodeticS(x, y, z, varargin)

    [x, y, z, inDegrees] = parseTransformationInputsS( ...
        x, y, z, varargin{:});
    rho = hypot(x,y);

    [phi, h] = cylindrical2geodetic(rho, z, 6378137, 0.003352810664747, inDegrees);

    if inDegrees
        lambda = atan2d(y,x);
    else
        lambda = atan2(y,x);
    end
end


function [phi, h] = cylindrical2geodetic(rho, z, a, f, inDegrees)
    if f == 0
        if inDegrees
            phi = atan2d(z,rho);
        else
            phi = atan2(z,rho);
        end
        h = hypot(z,rho) - a;
    else
        [phi, h] = map.geodesy.internal.cylindrical2geodetic(rho, z, a, f, inDegrees);
    end
end
function [c1, c2, c3, inDegrees] = parseTransformationInputsS( ...
     c1, c2, c3, angleUnit)
% Parse inputs to geodetic2ecef and ecef2geodetic

% Copyright 2019 The MathWorks, Inc.
inDegrees = (nargin < 5 || map.geodesy.isDegree(angleUnit));
%    try
%        if isobject(spheroid)
%            % [X, Y, Z] = geodetic2ecef(SPHEROID, PHI, LAMBDA, H, SPHEROID [, angleUnit])
%            inDegrees = (nargin < 5 || map.geodesy.isDegree(angleUnit));
%        else
            % Older syntax with PHI and LAMBDA defaulting to radians:
            %    [X, Y, Z] = geodetic2ecef(PHI, LAMBDA, H, SPHEROID)
            % Also do the right thing with this undocumented syntax:
            %    [X, Y, Z] = geodetic2ecef(PHI, LAMBDA, H, SPHEROID, angleUnit)
            % SPHEROID can be a spheroid object or an ellipsoid vector.
%            [c1, c2, c3, spheroid] = deal(spheroid, c1, c2, c3);
%            inDegrees = ~(nargin < 5 || ~map.geodesy.isDegree(angleUnit));
%        end
%    catch e
%        throwAsCaller(e)
%    end
end
