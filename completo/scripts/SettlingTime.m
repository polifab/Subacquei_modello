
function out = SettlingTime(in)

readytoswitchFlag = in(1);
ErrorFlag = in(2);
reset_time = in(3);
T_101 = in(4);
T_102 = in(5);
T_103 = in(6);
T_104 = in(7);
T_201 = in(8);
T_202 = in(9);
current_state = in(10);


if current_state == 101
    time_max = T_101*4;
elseif current_state == 102
    time_max = T_102;
elseif current_state == 103
    time_max = T_103;
elseif current_state == 104
    time_max = T_104;
elseif current_state == 201
    time_max = T_201;
elseif current_state == 202
    time_max = T_202;
else
    time_max = 10000;
end 





if (reset_time > (time_max * 2)) && ErrorFlag == 0
    readytoswitchFlag = 0;
    ErrorFlag = 4;
    disp('Tempo massimo per il raggiungimento del waypoint trascorso! Annullamento della missione in atto')
elseif current_state == 500
    ErrorFlag = in(11);
elseif (reset_time <= time_max * 2) && ErrorFlag == 0
    ErrorFlag = 0;   
elseif ErrorFlag == 1 && current_state ~= 500
    disp('Sensore in avaria! Annullamento della missione in atto') 
elseif ErrorFlag == 2 && current_state ~= 500
    disp('Correnti troppo forti! Annullamento della missione in atto')

end


out = [readytoswitchFlag, ErrorFlag];
end