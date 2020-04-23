% Christopher Apfelbach


function voicingDuration(input_filename)

    % Loads relevant variables
    load(input_filename);

    % Displays duration data at each F0
    disp(join(['NOTE: The current tempo is', string(input_tempo), 'beats per minute.']));
    disp('Phonation Duration at all Voiced Frequencies (F0, Beats, Seconds):');
    disp([unique_F0]);
    
end