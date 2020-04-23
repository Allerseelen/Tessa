% Christopher Apfelbach


function summaryStats(input_filename)

    % Loads relevant variables
    load(input_filename);

    % Displays F0 descriptive statistics and voicing duration
    disp(join(['Minimum Frequency:', string(F0_min), 'Hz']));
    disp(join(['25th Percentile Frequency:', string(F0_25th_Percentile), 'Hz']));
    disp(join(['Mean Frequency:', string(F0_mean), 'Hz']));
    disp(join(['Median Frequency:', string(F0_median), 'Hz']));
    disp(join(['75th Percentile Frequency:', string(F0_75th_Percentile), 'Hz']));
    disp(join(['Maximum Frequency:', string(F0_max), 'Hz']));
    disp(join(['Total Duration:', string(total_duration), 'seconds']));
    disp(join(['Total Voicing Duration:', string(total_voicing_duration), 'seconds']));
    disp(join(['Total Rest Duration:', string(total_rest_duration), 'seconds']));
    disp(join(['Percent Time Spent Voicing:', string(percent_voicing), '%']));
    disp(join(['Estimated Vocal Fold Cycles:', string(total_vf_cycles)]));
    
end