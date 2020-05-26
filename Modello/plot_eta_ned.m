function plot_eta_ned(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    
    subplot(2,3,1)
    plot(time, signal(:,1));
    xlabel('Tempo (secondi)')
    ylabel('x (metri)')
    title('x')
    
    subplot(2,3,2)
    plot(time, signal(:,2));
    xlabel('Tempo (secondi)')
    ylabel('y (metri)')
    title('y')
    
    subplot(2,3,3)
    plot(time, signal(:,3));
    xlabel('Tempo (secondi)')
    ylabel('Profondità (gradi)')
    title('Profondità z')
    
    subplot(2,3,4)
    plot(time, signal(:,4));
    xlabel('Tempo (secondi)')
    ylabel('Roll (rad)')
    title('Roll')
    
    subplot(2,3,5)
    plot(time, signal(:,5));
    xlabel('Tempo (secondi)')
    ylabel('Pitch (rad)')
    title('Pitch')
    
    subplot(2,3,6)
    plot(time, signal(:,6));
    xlabel('Tempo (secondi)')
    ylabel('Yaw (rad)')
    title('Yaw')
    
    sgtitle('Eta (terna NED)')
end