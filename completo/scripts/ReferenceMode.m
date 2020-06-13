function out = ReferenceMode(in)
current_state = in(1);
Rel = [103, 104, 201, 202, 401];
Abs = [101, 102];


if any(Rel(:)== current_state)
    reference_mode = 1;
    
elseif any(Abs(:) == current_state)
    reference_mode = 0;
else
    reference_mode = -1;
end 

out = reference_mode;