function output = geodetic_to_ned(input)
  
ned_origin = input(1:3);
lat = input(4);
long = input(5);

[x, y, ~] = geodetic2ned(lat, long, 0, ...
    ned_origin(1), ned_origin(2), ned_origin(3), wgs84Ellipsoid);

output = [x; y];
end