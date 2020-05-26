function plot_velocity_ned(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1));
    xlabel('Tempo (secondi)')
    ylabel('vx (metri/s)')
    title('Velocità lineare lungo N')
    
    subplot(2,3,2)
    plot(time, signal(:,2));
    xlabel('Tempo (secondi)')
    ylabel('vy (metri/s)')
    title('Velocità lineare lungo E')
    
    subplot(2,3,3)
    plot(time, signal(:,3));
    xlabel('Tempo (secondi)')
    ylabel('vz (m/s)')
    title('Velocità lineare lungo D')
    
    subplot(2,3,4)
    plot(time, signal(:,4));
    xlabel('Tempo (secondi)')
    ylabel('wx (rad/s)')
    title('Vel. angolare asse N')
    
    subplot(2,3,5)
    plot(time, signal(:,5));
    xlabel('Tempo (secondi)')
    ylabel('wy (rad/s)')
    title('Vel. angolare asse E')
    
    subplot(2,3,6)
    plot(time, signal(:,6));
    xlabel('Tempo (secondi)')
    ylabel('wz (rad/s)')
    title('Vel. angolare asse D')
    
    sgtitle('Derivata di Eta (terna NED)')
end