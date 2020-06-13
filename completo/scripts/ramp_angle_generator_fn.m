function new_value = ramp_angle_generator_fn(in)
init_value = wrapTo2Pi(in(1));
final_value = wrapTo2Pi(in(2));
slope = in(3);
reset = in(4);
dt = in(5);
last_value = in(6);

if reset
    new_value = init_value;
else
    new_value = last_value + dt*slope;
end

new_value = wrapTo2Pi(new_value);

if init_value > final_value
    if slope > 0 && new_value < init_value && new_value >= final_value
        new_value = final_value;
    elseif slope < 0 && new_value <= final_value
        new_value = final_value;
    end
elseif init_value < final_value
    if slope > 0 && new_value >= final_value
        new_value = final_value;
    elseif slope < 0 && new_value > start && new_value <= final_value
        new_value = final_value;
    end
end

end


