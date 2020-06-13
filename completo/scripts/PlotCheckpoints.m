% Script that takes the checkpoints computed in "initCheckpoints.m" and plot
% all of them in a 3D plot

figure(1)
plot3(M100(1:4,1),M100(1:4,2),-M100(1:4,3),'oblack');
grid;
axis equal
xlabel('x');
ylabel('y');
zlabel('- Depth');
hold on;

plot3(M100(4,5),M100(4,6),-M100(4,7),'ob');

if length(inspectionDirection) == length('vertical')
    for i=1:(counter_max-1)
       plot3(M201(i,1),M201(i,2),-M201(i,3),'or');
       plot3(M202(i,1),M202(i,2),-M202(i,3),'or');
    end
    plot3(M201(counter_max-1,5),M201(counter_max-1,6),-M201(counter_max-1,7),'or');
    plot3(M202(counter_max-1,5),M202(counter_max-1,6),-M202(counter_max-1,7),'or');
    plot3(M201(counter_max,5),M201(counter_max,6),-M201(counter_max,7),'or');
elseif length(inspectionDirection) == length('horizontal')
    for i=1:(counter_max-1)
       plot3(M202(i,1),M202(i,2),-M202(i,3),'or');
       plot3(M201(i,1),M201(i,2),-M201(i,3),'or');
    end
    plot3(M202(counter_max-1,5),M202(counter_max-1,6),-M202(counter_max-1,7),'or');
    plot3(M201(counter_max-1,5),M201(counter_max-1,6),-M201(counter_max-1,7),'or');
    plot3(M202(counter_max,5),M202(counter_max,6),-M202(counter_max,7),'or');
end

plot3(M100(5,5),M100(5,6),-M100(5,7),'og');
f = @(x,y,z) x.^2+y.^2-10.^2
interval = [-35 35 -35 35 -40 0]
fimplicit3(f,interval)
hold off

figure(2)
hold on
axis equal
grid
f = @(x,y,z) x.^2+y.^2-10.^2
interval = [-35 35 -35 35 -40 0]
fimplicit3(f,interval)

x1 = @(t) M(1,1)+t*(M(2,5)-M(1,1))
y1 = @(t) M(1,2)+t*(M(2,6)-M(1,2))
z1 = @(t) 0
fplot3(x1,y1,z1, [0 1],'r', 'LineWidth', 2)

x2 = @(t) (pylonRadius+distance)*cos(t)
y2 = @(t) (pylonRadius+distance)*sin(t)
z2 = @(t) 0
fplot3(x2,y2,z2, [7.2/5*pi 2/0.8*pi], 'b', 'LineWidth', 2)

























