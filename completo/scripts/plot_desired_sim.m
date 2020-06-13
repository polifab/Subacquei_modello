figure
plot3(0, 0, 0)
steps = size(out.desired.Depth.Data, 1);
xlim([43.72304, 43.72314]);
ylim([10.39662, 10.39677]);
zlim([0, 12]);
for i=1:steps
    if mod(i, 20) ~= 0
        continue
    end
    disp(i)
    abs_pos = out.desired.Abs_Position.Data(i,:);
    depth = out.desired.Depth.Data(i);
    hold on;
    plot3(abs_pos(1), abs_pos(2), depth, 'r.')
    drawnow
end