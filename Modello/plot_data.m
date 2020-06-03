function plot_data(simout)

    signal = simout.Data;
    time   = simout.Time;
   
    figure;
    axis equal;
    hold on;
    subplot(time, signal(:,1));
    subplot(time, signal(:,2));
    subplot(time, signal(:,3));
    subplot(time, signal(:,4));
    subplot(time, signal(:,5));
    subplot(time, signal(:,6));
    
    legend('x','y','z','fi','theta','psi')
    
    
end