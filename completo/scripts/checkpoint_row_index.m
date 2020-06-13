function row_index = checkpoint_row_index(current_state, counter, length_201)
if current_state == 101
    row_index = 1;
elseif current_state == 102
    row_index = 2;
elseif current_state == 103
    row_index = 3;
elseif current_state == 104
    row_index = 4;
elseif current_state == 401
    row_index = 5;
elseif current_state == 201
    row_index = 6 + counter;
elseif current_state == 202
     row_index = 6 + length_201 + counter;
else 
    row_index = -1;
end

