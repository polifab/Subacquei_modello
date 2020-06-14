function plot_velocity_body(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('u (metri/s)', 'Fontsize',18)
    title('Surge', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,2)
    plot(time, signal(:,2), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('v (metri/s)', 'Fontsize',18)
    title('Sway', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,3)
    plot(time, signal(:,3), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('w (m/s)', 'Fontsize',18)
    title('Heave', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,4)
    plot(time, signal(:,4), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('p (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse x', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,5)
    plot(time, signal(:,5), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('q (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse y', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,6)
    plot(time, signal(:,6), 'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('r (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse z', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    sgtitle('Ni (terna body)', 'Fontsize',24)
end