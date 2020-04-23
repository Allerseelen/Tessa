% Christopher Apfelbach


function plotBox(axes, input_filename)
    
    % Loads relevant variables
    load(input_filename);
    
    % Creates box plot of pitch and duration data
    box_plot = boxplot(axes, boxplot_subdiv, 'Orientation', 'horizontal');
    
    % Overlay mean F0
    hold on
    plot(F0_mean, 1, 'dg');
    hold off
    
    grid(axes, 'on');
    axes.XLabel.String = 'Fundamental Frequency (Hz)';
end