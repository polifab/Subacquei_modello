function plot_eta_ned(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1), 'LineWidth',1);
    xlabel('Tempo (secondi)','LineWidth',1, 'Fontsize',16)
    ylabel('x (metri)','LineWidth',2, 'Fontsize',18)
    title('x', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,2)
    plot(time, signal(:,2),'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('y (metri)', 'Fontsize',18)
    title('y', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,3)
    plot(time, signal(:,3),'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('Profondità (metri)', 'Fontsize',18)
    title('Profondità z', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,4)
    plot(time, signal(:,4),'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('Roll (rad)', 'Fontsize',18)
    title('Roll', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    subplot(2,3,5)
    plot(time, signal(:,5),'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('Pitch (rad)', 'Fontsize',18)
    title('Pitch', 'Fontsize',16)
    set(gca,'FontSize',13)
   
    subplot(2,3,6)
    plot(time, signal(:,6),'LineWidth',1);
    xlabel('Tempo (secondi)', 'Fontsize',16)
    ylabel('Yaw (rad)', 'Fontsize',18)
    title('Yaw', 'Fontsize',16)
    set(gca,'FontSize',13)
    
    sgtitle('Eta (terna NED)', 'LineWidth',1, 'Fontsize',24)
end