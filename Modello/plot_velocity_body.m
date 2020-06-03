function plot_velocity_body(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('u (metri/s)')
    title('Surge')
    
    subplot(2,3,2)
    plot(time, signal(:,2), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('v (metri/s)')
    title('Sway')
    
    subplot(2,3,3)
    plot(time, signal(:,3), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('w (m/s)')
    title('Heave')
    
    subplot(2,3,4)
    plot(time, signal(:,4), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('p (rad/s)')
    title('Vel. angolare asse x')
    
    subplot(2,3,5)
    plot(time, signal(:,5), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('q (rad/s)')
    title('Vel. angolare asse y')
    
    subplot(2,3,6)
    plot(time, signal(:,6), 'LineWidth',1);
    xlabel('Tempo (secondi)')
    ylabel('r (rad/s)')
    title('Vel. angolare asse z')
    
    sgtitle('Ni (terna body)')
end