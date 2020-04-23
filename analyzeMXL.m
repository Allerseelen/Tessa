function analyzeMXL(input_filename, ...
                  output_filename, ...
                  input_tempo, ...
                  input_part_id)

%==========================================================================
                 
        % Loads MatLab Structure file specified by user
        loaded_data = load(output_filename);
        
        % Navigates to correct "level" of MatLab Structure file
        main_struct = loaded_data.temporary_struct;

%==========================================================================
        
    % INITIALIZES FIRST VARIABLES
    
        % duration_multiplier
        duration_multiplier = 60 / input_tempo;

        % full_pitch
        full_pitch = cell(1, 9);
        
        % full_hertz
        full_hertz = {'Pitch' 'Frequency (Hz)'; ...
                       'C0' 16.3516; ...
                       'C#0' 17.32391; ...
                       'D0' 18.35405; ...
                       'D#0' 19.44544; ...
                       'E0' 20.60172; ...
                       'F0' 21.82676; ...
                       'F#0' 23.12465; ...
                       'G0' 24.49971; ...
                       'G#0' 25.95654; ...
                       'A0' 27.5000; ...
                       'A#0' 29.13524; ...
                       'B0' 30.86771};

%==========================================================================
        
    % PLACES RELEVANT .XML INFORMATION INTO FULL_SCORE ARRAY
                   
        % loops through scores
        n_scores = size(main_struct, 2);
        for i_score = 1:n_scores
            this_score = main_struct(i_score);

            % loops through part list
            n_parts = size(this_score.Children, 2);
            for i_part = 1:n_parts
                this_partlist = this_score.Children(i_part);

                % loops through child nodes that are parts
                if strcmp(this_partlist.Name, 'part')
                    this_part = this_partlist.Attributes.Value;

                    % loops through part specified in GUI
                    if strcmp(this_part, input_part_id) == 1
                        this_partlist_children = this_partlist.Children;
                        full_score = importPart(this_partlist_children);
                    end
                end
            end
        end

        % Clears variables used only to create full_score
        clearvars i_part i_score loaded_data main_struct n_parts n_scores ...
                  this_part this_partlist this_partlist_children this_score
        
%==========================================================================
            
    % REORGANIZES FULL_SCORE ARRAY INTO PITCHES AND RESTS
    
        % Full_Pitch: consolidates pitches into a single array
        for i = 1:length(full_score)
            if isempty(full_score{i, 9}) == 1
                full_pitch = [full_pitch; full_score(i, 1:9)];
            end
        end
        
        % Full_Pitch: deletes empty first row
        full_pitch(1, :) = [];
        
        clearvars i
        
%==========================================================================
    
    % CALCULATES DURATION
    
        % Loads beat_duration, used in duration calculations
        load('0.0. Beat Duration.mat')

        % Full_Pitch: calculates duration values in seconds
        for i = 1:length(full_pitch)
            full_pitch(i, 2) = {(cell2mat(full_pitch(i, 1)) / beat_duration) * duration_multiplier};
        end
        
        % Full_Score: calculates duration values in seconds
        for i = 1:length(full_score)
            full_score(i, 2) = {(cell2mat(full_score(i, 1)) / beat_duration) * duration_multiplier};
        end
        
        clearvars i duration_multiplier
    
%==========================================================================
    
    % CALCULATES PITCH FREQUENCY

        % Assigns frequency values in Hertz to pitches in full_pitch array
        for i = 1:length(full_pitch)

            % C
            % If Step = 'C' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'C') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply C0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(2, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % C-sharp
            % If Step = 'C' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'C') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply C#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(3, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % D-flat
            % If Step = 'D' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'D') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply C#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(3, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % D
            % If Step = 'D' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'D') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply D0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(4, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % D-sharp
            % If Step = 'D' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'D') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply D#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(5, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % E-flat
            % If Step = 'E' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'E') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply D#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(5, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % E
            % If Step = 'E' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'E') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply E0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(6, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % E-sharp
            % If Step = 'E' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'E') && cell2mat(full_pitch(i, 4)) == 1
                % Mulitply F0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(7, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end
            
            % F-flat
            % If Step = 'F' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'F') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply E0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(5, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end
            
            % F
            % If Step = 'F' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'F') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply F0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(7, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % F-sharp
            % If Step = 'F' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'F') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply F#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(8, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % G-flat
            % If Step = 'G' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'G') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply F#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(8, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % G
            % If Step = 'G' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'G') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply G0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(9, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % G-sharp
            % If Step = 'G' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'G') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply G#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(10, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % A-flat
            % If Step = 'A' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'A') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply G#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(10, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % A
            % If Step = 'A' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'A') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply A0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(11, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % A-sharp
            % If Step = 'A' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'A') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply A#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(12, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % B-flat
            % If Step = 'B' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'B') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply A#0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(12, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % B
            % If Step = 'B' AND Alter = 0
            if strcmp(full_pitch(i, 3), 'B') && cell2mat(full_pitch(i, 4)) == 0
                % Multiply B0 frequency by 2^Octave
                this_hertz = cell2mat(full_hertz(13, 2)) * 2 ^ cell2mat(full_pitch(i, 5));
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % C-flat
            % If Step = 'C' AND Alter = -1
            if strcmp(full_pitch(i, 3), 'C') && cell2mat(full_pitch(i, 4)) == -1
                % Multiply B0 frequency by (2^Octave - 1)
                this_hertz = cell2mat(full_hertz(13, 2)) * 2 ^ (cell2mat(full_pitch(i, 5)) - 1);
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end

            % B-sharp
            % If Step = 'B' AND Alter = 1
            if strcmp(full_pitch(i, 3), 'B') && cell2mat(full_pitch(i, 4)) == 1
                % Multiply C0 frequency by (2^Octave + 1)
                this_hertz = cell2mat(full_hertz(2, 2)) * 2 ^ (cell2mat(full_pitch(i, 5)) + 1);
                % Assign frequency value to full_pitch array
                full_pitch(i, 6) = {this_hertz};
            end
        end
        
        clearvars i this_hertz
        
%==========================================================================
    
    % CALCULATES VOCAL FOLD CYCLES
    
        % Full_Pitch: adds VF cycles
        for i = 1:length(full_pitch)
            full_pitch(i, 7) = {cell2mat(full_pitch(i, 2)) * cell2mat(full_pitch(i, 6))};
        end
        
        clearvars i
    
%==========================================================================
    
    % CREATES DURATION ARRAYS NECESSARY FOR BOX PLOTS
        
        % Full_Pitch: sorts by frequency
        full_pitch_sort = sortrows(full_pitch, 6);
        
        % Full_Pitch_Sort: eliminates zero values caused by grace notes, etc.
        while cell2mat(full_pitch_sort(1, 6)) == 0
            full_pitch_sort(1, :) = [];
        end
        
        % Boxplot_Subdiv: tallies number of subdivisions per frequency
        boxplot_subdiv = zeros(1,1);
        for i = 1:length(full_pitch_sort)
            subdiv = repelem(cell2mat(full_pitch_sort(i,6)), cell2mat(full_pitch_sort(i,1)), 1);
            boxplot_subdiv = [boxplot_subdiv; subdiv];
        end
        
        % Deletes empty first row of boxplot_subdiv
        boxplot_subdiv(1,:) = [];
        
        clearvars i subdiv
        
%==========================================================================        
        
    % CREATES DURATION ARRAYS NECESSARY FOR BAR CHARTS

        % Unique_Frequency: creates array
        unique_F0 = zeros(length(unique(cell2mat(full_pitch_sort(:, 6)))), 3);
        unique_F0(:, 1) = unique(cell2mat(full_pitch_sort(:, 6)));
        
        % Unique_Frequency: combines duration data at each unique frequency
        n = 1;
        for i = 1:length(full_pitch_sort)
            subdiv = cell2mat(full_pitch_sort(i, 1));
            sec = cell2mat(full_pitch_sort(i, 2));
                if cell2mat(full_pitch_sort(i, 6)) == unique_F0(n, 1)
                    unique_F0(n, 2) = unique_F0(n, 2) + subdiv;
                    unique_F0(n, 3) = unique_F0(n, 3) + sec;
                else
                    n = n + 1;
                    unique_F0(n, 2) = unique_F0(n, 2) + subdiv;
                    unique_F0(n, 3) = unique_F0(n, 3) + sec;
                end
        end
        
        clearvars n i subdiv sec

%==========================================================================
    
    % DERIVES LAST VARIABLES NEEDED FOR ANALYSIS

        % Calculates frequency data
        F0_min = min(boxplot_subdiv);
        F0_25th_Percentile = quantile(boxplot_subdiv, 0.25);
        F0_mean = mean(boxplot_subdiv);
        F0_median = median(boxplot_subdiv);
        F0_75th_Percentile = quantile(boxplot_subdiv, 0.75);
        F0_max = max(boxplot_subdiv);
    
        % Calculates total rest time (s), phonation time (s), VF cycles,
        % and percent time spent voicing
        total_duration = sum(cell2mat(full_score(:,2)), 'all');
        total_voicing_duration = sum(cell2mat(full_pitch(:,2)), 'all');
        total_rest_duration = total_duration - total_voicing_duration;
        percent_voicing = (total_voicing_duration / total_duration) * 100;
        total_vf_cycles = sum(cell2mat(full_pitch(:,7)), 'all');
        
        % Summary_Statistics: creates variable containing relevant
        % stats on F0, voicing time, vocal fold cycles, etc.
        summary_statistics = ...
        {'Minimum F0 (Hz)' ...
         '25th Percentile F0 (Hz)' ...
         'Mean F0 (Hz)' ...
         'Median F0 (Hz)' ...
         '75th Percentile F0 (Hz)' ...
         'Maximum F0 (Hz)' ...
         '' ...
         'Total Duration (s)' ...
         'Phonation Time (s)' ...
         'Rest Time (s)' ...
         'Percent Voicing (%)' ...
         'Estimated VF Cycles'; ...
          F0_min ...
          F0_25th_Percentile ...
          F0_mean ...
          F0_median ...
          F0_75th_Percentile ...
          F0_max ...
          '' ...
          total_duration ...
          total_voicing_duration ...
          total_rest_duration ...
          percent_voicing ...
          total_vf_cycles};
    
%==========================================================================
     
    % TIDIES ARRAYS AND VARIABLES
    
        % Converts subdivisions to beats, adds array headings
        
            % Heading
            heading = {'Duration (Beats)' ...
                       'Duration (s)' ...
                       'Pitch Class' ...
                       'Accidental' ...
                       'Octave' ...
                       'F0 (Hz)' ...
                       'VF Cycles' ...
                       'Lyric' ...
                       'Rest?'};
            
            % Full_Score
            for i = 1:length(full_score)
                full_score(i,1) = {cell2mat(full_score(i,1)) / beat_duration};
            end
            full_score(1+1:end+1,:) = full_score(1:end,:);
            full_score(1,:) = heading;
            
            % Full_Pitch
            for i = 1:length(full_pitch)
                full_pitch(i,1) = {cell2mat(full_pitch(i,1)) / beat_duration};
            end
            full_pitch(1+1:end+1,:) = full_pitch(1:end,:);
            full_pitch(1,:) = heading;
        
            % Full_Pitch_Sort
            for i = 1:length(full_pitch_sort)
                full_pitch_sort(i,1) = {cell2mat(full_pitch_sort(i,1)) / beat_duration};
            end
            full_pitch_sort(1+1:end+1,:) = full_pitch_sort(1:end,:);
            full_pitch_sort(1,:) = heading;
            
            % Unique_F0
            unique_F0(:,2) = unique_F0(:,2) / beat_duration;
            
        clearvars i heading

%==========================================================================
     
     % SAVES VARIABLES
        
        % Creates file suffix
        filename = strcat(output_filename, '--', input_part_id, '--', string(input_tempo), ' BPM.mat');
    
        % Saves ALL relevant variables for accuracy verification
        save(filename);
         
end