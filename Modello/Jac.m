function J = Jac(eta2)
    phi = eta2(1);
    theta = eta2(2);
    psi = eta2(3);
    Rx = [1 0 0; 0 cos(phi) sin(phi); 0 -sin(phi) cos(phi)];
    Ry = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
    Rz = [cos(psi) sin(psi) 0; -sin(psi) cos(psi) 0; 0 0 1];
    J1 = Rz'*Ry'*Rx';
    J2 = [1 sin(phi)*tan(theta) cos(phi)*tan(theta); ...
        0 cos(phi) -sin(phi); ...
        0 sin(phi)/cos(theta) cos(phi)/cos(theta)];
    J = blkdiag(J1, J2);
end