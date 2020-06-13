function J = Jac(eta2)
    % Funzione per il calcolo dello Jacobiano per il passaggio da
    % coordinate Body a coordinate NED
    
    % IN: eta2 [3x1] rad angoli di roll, pitch, yaw
    
    % OUT: J [6x6] Jacobiano complessivo

    phi = eta2(1); % roll
    theta = eta2(2); % pitch
    psi = eta2(3); % yaw
    Rx = [1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)]; % Rot elementare attorno a x
    Ry = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)]; % Rot elementare attorno a y
    Rz = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1]; % Rot elementare attorno a z
    J1 = Rz'*Ry'*Rx'; % Jacobiano per il passaggio da Body a NED delle componenti lineari
    J2 = [1 sin(phi)*tan(theta) cos(phi)*tan(theta); ... % Jacobiano per il passaggio da Body a NED delle componenti angolari
        0 cos(phi) -sin(phi); ...
        0 sin(phi)/cos(theta) cos(phi)/cos(theta)];
    J = blkdiag(J1, J2); % Jacobiano complessivo
end