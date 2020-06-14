function plot_velocity_ned(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1));
    xlabel('Tempo (secondi)')
    ylabel('vx (m/s)', 'Fontsize',18)
    title('Velocità lineare lungo N')
    
    subplot(2,3,2)
    plot(time, signal(:,2));
    xlabel('Tempo (secondi)')
    ylabel('vy (m/s)', 'Fontsize',18)
    title('Velocità lineare lungo E')
    
    subplot(2,3,3)
    plot(time, signal(:,3));
    xlabel('Tempo (secondi)')
    ylabel('vz (m/s)', 'Fontsize',18)
    title('Velocità lineare lungo D')
    
    subplot(2,3,4)
    plot(time, signal(:,4));
    xlabel('Tempo (secondi)')
    ylabel('wx (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse N')
    
    subplot(2,3,5)
    plot(time, signal(:,5));
    xlabel('Tempo (secondi)')
    ylabel('wy (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse E')
    
    subplot(2,3,6)
    plot(time, signal(:,6));
    xlabel('Tempo (secondi)')
    ylabel('wz (rad/s)', 'Fontsize',18)
    title('Vel. angolare asse D')
    
    sgtitle('Derivata di Eta (terna NED)', 'Fontsize',24)
end