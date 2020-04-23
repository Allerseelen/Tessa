% Christopher Apfelbach


function plotBar(axes, input_filename)

    % Loads relevant variables
    load(input_filename);

    % Creates bar graph of pitch and duration data
    bar_chart = bar(axes, unique_F0(1:end, 1), unique_F0(1:end, 3));
    grid(axes, 'on')
    axes.XLabel.String = 'Fundamental Frequency (Hz)';
    axes.YLabel.String = 'Total Voiced Duration (s)';
    
end