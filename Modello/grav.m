function F_g = grav(eta2)
    g = 9.81;
    W = massa*g;
    B = rho*V*g;
    J = Jac(eta2);
    J1 = J(1:3,1:3);
    J2 = J(4:6,4:6);
    f_g = inv(J1)*[0; 0; W];
    f_b = inv(J1)*[0; 0; -B];
    r_g = [0; 0; 0];
    r_b = [0; 0; -c/2];
    F_g = -[f_g + f_b; cross(r_g,f_g) + cross(r_b,f_b)];
end