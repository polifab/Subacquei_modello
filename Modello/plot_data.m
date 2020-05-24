function plot_data(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    hold on;
    plot(time, signal(:,1));
    plot(time, signal(:,2));
    plot(time, signal(:,3));
    plot(time, signal(:,4));
    plot(time, signal(:,5));
    plot(time, signal(:,6));
    
    legend('x','y','z','fi','theta','psi')
    
    
end