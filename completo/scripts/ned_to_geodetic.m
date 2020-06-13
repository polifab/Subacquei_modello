function output = ned_to_geodetic(input)
  
ned_origin = input(1:3);
x = input(4);
y = input(5);

[lat, long, ~] = ned2geodetic(x, y, 0, ...
    ned_origin(1), ned_origin(2), ned_origin(3), wgs84Ellipsoid);

output = [lat; long];
end