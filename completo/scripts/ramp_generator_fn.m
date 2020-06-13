function new_value = ramp_generator_fn(in)
init_value = in(1);
final_value = in(2);
slope = in(3);
reset = in(4);
dt = in(5);
last_value = in(6);

if reset
    new_value = init_value;
else
    new_value = last_value + dt*slope;
end

if slope > 0 && new_value > final_value
    new_value = final_value;
elseif slope < 0 && new_value < final_value
    new_value = final_value;
end

end


