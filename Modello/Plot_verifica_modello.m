%% VERIFICA BONTA' MODELLO (SIMULINK)

initial = [0 0 0 0 0 0]';
current_switch = 1;         % mettere a 1 per includere la corrente, 0 per escluderla
VEL_THRUSTER = [0 0 0 0 0 0 0]; % velocità desiderata in ingresso ai 7 thruster
TAU = [0 0 0 0 0 0]';

simout = sim('modello_simulink')

plot_eta_ned(simout.eta_ned)
%plot_eta_ecef(simout.eta_ecef)
%plot_velocity_ned(simout.velocity_ned)
plot_velocity_body(simout.velocity_body)
%plot_acceleration_ned(simout.acceleration_ned)
% plot_acceleration_body(simout.acceleration_body)

%%

load('simout')
%%
%plot_eta_ned(simout.eta_ned_heave)
%plot_velocity_body(simout.velocity_body_heave)