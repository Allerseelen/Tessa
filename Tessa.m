classdef Tessa < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        FigureTessa            matlab.ui.Figure
        PanelPartwise          matlab.ui.container.Panel
        ButtonPartwise         matlab.ui.control.Button
        PanelConvert           matlab.ui.container.Panel
        FieldOutputName        matlab.ui.control.EditField
        LabelOutputName        matlab.ui.control.Label
        ButtonConvert          matlab.ui.control.Button
        PanelCompile           matlab.ui.container.Panel
        FieldPartID            matlab.ui.control.EditField
        LabelPartID            matlab.ui.control.Label
        LabelTempo             matlab.ui.control.Label
        ButtonCompile          matlab.ui.control.Button
        FieldTempo             matlab.ui.control.NumericEditField
        PanelDisplay           matlab.ui.container.Panel
        ButtonDisplay          matlab.ui.control.Button
        TabGroup               matlab.ui.container.TabGroup
        TabGlobal              matlab.ui.container.Tab
        AxesBoxPlot            matlab.ui.control.UIAxes
        AxesHistogram          matlab.ui.control.UIAxes
        TabNoteByNote          matlab.ui.container.Tab
        AxesMovingAverage      matlab.ui.control.UIAxes
        SliderMovingAverage    matlab.ui.control.Slider
        LabelMovingAverage     matlab.ui.control.Label
        DropDownNaN            matlab.ui.control.DropDown
        TabVocalDemandMetrics  matlab.ui.container.Tab
        AxesPercentVoicing     matlab.ui.control.UIAxes
        AxesTotalCycles        matlab.ui.control.UIAxes
        AxesMeanCycles         matlab.ui.control.UIAxes
        SummaryStatisticsTab   matlab.ui.container.Tab
        TablePitchDurations    matlab.ui.control.Table
        TableSummaryStats      matlab.ui.control.Table
        SelectvoicetypePanel   matlab.ui.container.Panel
        VoiceTypeDropDown      matlab.ui.control.DropDown
    end

    
    properties (Access = private)
        beat_duration       % The length of one musical beat, calculated in the subdivisions used by the score
    end
    
    properties (Access = public)
        moving_average      % Array containing all f0 values in the piece; used to dynamically update the moving average graph
        input_filename      % The user-selected input filename, chosen in the file explorer; shared between multiple functions
        input_filepath      % The user-selected input filepath, chosen in the file explorer
        output_filename     % The user-selected output filename, chosen in an editable text field
    end
    
    
    methods (Access = private)
        
        
        function analyzeMXL(app)
            
            % Loads Matlab structure array specified by user
            loaded_data = load(app.input_filename);
            
            % Navigates to correct "level" of Matlab structure array
            main_struct = loaded_data.temporary_struct;
                   
            
            % INITIALIZES FIRST VARIABLES
        
                % partID
                partID = app.FieldPartID.Value;
                
                % tempo
                tempo = app.FieldTempo.Value;
            
                % full_pitch
                full_pitch = cell(1, 9);
                
                % full_hertz
                full_hertz = {'Pitch'   'Frequency (Hz)'; ...
                              'Cbb0'    14.56762; ...
                              'Cb0'     15.43385; ...
                              'C0'      16.35160; ...
                              'C#0'     17.32391; ...
                              'D0'      18.35405; ...
                              'D#0'     19.44544; ...
                              'E0'      20.60172; ...
                              'F0'      21.82676; ...
                              'F#0'     23.12465; ...
                              'G0'      24.49971; ...
                              'G#0'     25.95654; ...
                              'A0'      27.50000; ...
                              'A#0'     29.13524; ...
                              'B0'      30.86771; ...
                              'C1'      32.70320; ...
                              'C#1'     34.64782};
                    
                          
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
                            if strcmp(this_part, app.FieldPartID.Value) == 1
                                this_partlist_children = this_partlist.Children;
                                full_score = importPart(app, this_partlist_children);
                            end
                        end
                    end
                end
        
                % Clears variables used only to create full_score
                clearvars i_part i_score loaded_data main_struct n_parts n_scores ...
                          this_part this_partlist this_partlist_children this_score
                      
            
            % CALCULATES DURATION
                
                % Full_Score: calculates duration values in seconds
                for i = 1:length(full_score)
                    full_score(i, 2) = {(cell2mat(full_score(i, 1)) / app.beat_duration) * (60 / app.FieldTempo.Value)};
                end
                
                clearvars i
        
                
            % CALCULATES PITCH FREQUENCY

                for i = 1:length(full_score)
                    note = cell2mat(full_score(i,3));
                    if isempty(note) == 0
                        if strcmp(note, 'C')
                            pitch = 4;
                        elseif strcmp(note, 'D')
                            pitch = 6;
                        elseif strcmp(note, 'E')
                            pitch = 8;
                        elseif strcmp(note, 'F')
                            pitch = 9;
                        elseif strcmp(note, 'G')
                            pitch = 11;
                        elseif strcmp(note, 'A')
                            pitch = 13;
                        elseif strcmp(note, 'B')
                            pitch = 15;
                        end
                        pitch = pitch + cell2mat(full_score(i, 4));
                        this_hertz = cell2mat(full_hertz(pitch, 2)) * 2^cell2mat(full_score(i, 5));
                        full_score(i, 6) = {this_hertz};
                    end
                end
                
                clearvars i this_hertz
                
                
            % CALCULATES VOCAL FOLD CYCLES
    
                % full_score: adds VF cycles
                for i = 1:length(full_score)
                    full_score(i, 7) = {cell2mat(full_score(i, 2)) * cell2mat(full_score(i, 6))};
                end
                
                clearvars i
                
                
            % CREATES full_pitch ARRAY
    
                % full_pitch: consolidates pitches into a single array
                for i = 1:length(full_score)
                    if isempty(full_score{i, 9}) == 1
                        full_pitch = [full_pitch; full_score(i, 1:9)];
                    end
                end
                
                % full_pitch: deletes empty first row
                full_pitch(1, :) = [];
                
                clearvars i
                
                
            % CREATES DURATION ARRAYS NECESSARY FOR BOX PLOTS AND MOVING AVERAGES
        
                % full_pitch: sorts by frequency
                full_pitch_sort = sortrows(full_pitch, 6);
                
                % full_pitch_sort: eliminates zero values caused by grace notes, etc.
                while cell2mat(full_pitch_sort(1, 6)) == 0
                    full_pitch_sort(1, :) = [];
                end
                
                % Moving_Average: tallies number of subdivisions per note, whether rest or pitch
                moving_average = nan(1,1);
                for i = 1:length(full_score)
                    if gt(cell2mat(full_score(i,6)), 0) && isempty(cell2mat(full_score(i,9))) == 1
                        subdiv = repelem(cell2mat(full_score(i,6)), cell2mat(full_score(i,1)), 1);
                    else
                        subdiv = repelem(moving_average(1,1), cell2mat(full_score(i,1)), 1);
                    end
                    moving_average = [moving_average; subdiv];
                end
                
                % Deletes empty first row of moving_average
                moving_average(1,:) = [];
                
                % Boxplot_Subdiv: tallies number of subdivisions per frequency
                boxplot_subdiv = zeros(1,1);
                for i = 1:length(full_pitch_sort)
                    subdiv = repelem(cell2mat(full_pitch_sort(i,6)), cell2mat(full_pitch_sort(i,1)), 1);
                    boxplot_subdiv = [boxplot_subdiv; subdiv];
                end
                
                % Deletes empty first row of boxplot_subdiv
                boxplot_subdiv(1,:) = [];
                
                clearvars i subdiv
                
                
            % CREATES DURATION ARRAYS NECESSARY FOR BAR CHARTS

                % Unique_F0: creates array
                unique_F0 = zeros(length(unique(cell2mat(full_pitch_sort(:, 6)))), 3);
                unique_F0(:, 1) = unique(cell2mat(full_pitch_sort(:, 6)));
                
                % Unique_F0: combines duration data at each unique frequency
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
                cycles_per_second = total_vf_cycles / total_duration;
                
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
                 'Estimated VF Cycles' ...
                 'VF Cycles Per Second'; ...
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
                  total_vf_cycles ...
                  cycles_per_second};
              
              
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
                
                % full_score
                for i = 1:length(full_score)
                    full_score(i,1) = {cell2mat(full_score(i,1)) / app.beat_duration};
                end
                full_score(1+1:end+1,:) = full_score(1:end,:);
                full_score(1,:) = heading;
                
                % full_pitch
                for i = 1:length(full_pitch)
                    full_pitch(i,1) = {cell2mat(full_pitch(i,1)) / app.beat_duration};
                end
                full_pitch(1+1:end+1,:) = full_pitch(1:end,:);
                full_pitch(1,:) = heading;
            
                % full_pitch_sort
                for i = 1:length(full_pitch_sort)
                    full_pitch_sort(i,1) = {cell2mat(full_pitch_sort(i,1)) / app.beat_duration};
                end
                full_pitch_sort(1+1:end+1,:) = full_pitch_sort(1:end,:);
                full_pitch_sort(1,:) = heading;
                
                % unique_F0
                unique_F0(:,2) = unique_F0(:,2) / app.beat_duration;

                
             % SAVES VARIABLES
                
                % Creates file suffix
                output_filename = strcat(app.input_filename, '--', partID, '--', string(tempo), ' BPM.mat');
                
                % Clears intermediate variables
                clearvars app file filename heading i note file filename partID path pitch
            
                % Saves ALL relevant variables for accuracy verification
                save(output_filename);
        end

%================================================================================================         

        function importAttribute(app, attributes)
            % Initializes variables
            this_attribute_divisions = 0;
            
            % Goes through children of this part
            number_of_children = size(attributes.Children, 2);
            
            % Extracts the unique beat duration value, then stores it as a private property
            for i_child = 1 : number_of_children
                this_child = attributes.Children(i_child);
                if strcmp(this_child.Name, 'divisions')
                    app.beat_duration = str2double(this_child.Children.Data);
                end
            end
        end
        
%================================================================================================  
        
        function this_pitch_lyric = importLyric(app, lyric)
            % Initializes placeholder variables
            this_pitch_lyric = {''};
            
            % Goes through children of this part
            number_of_children = size(lyric.Children, 2);
            this_lyric_list = cell(1, 1);
            
            % Extracts lyrics and hands up to importNote
            for i_child = 1 : number_of_children
                this_child = lyric.Children(i_child);
                if strcmp(this_child.Name, 'text') && isempty(this_child.Children) == 0
                    this_pitch_lyric = this_child.Children.Data;
                    break;
                else
                    this_pitch_lyric = [''];
                end
            end   
        end

%================================================================================================ 
        
        function this_measure_notes = importMeasure(app, measure)
            % Initializes variables
            this_measure_notes = {};
            
            % Goes through children of this part
            number_of_children = size(measure.Children, 2);
            
            % Collates measure information, then hands up to importPart
            for i_child = 1 : number_of_children
                this_child = measure.Children(i_child);
                if strcmp(this_child.Name, 'note')
                    this_note = importNote(app, this_child);
                    this_measure_notes = [this_measure_notes; this_note];
                elseif strcmp(this_child.Name, 'attributes')
                    importAttribute(app, this_child);
                end
            end
        end
        
%================================================================================================  
        
        function this_note = importNote(app, note)
            % Initializes placeholder variables
            this_note = {0,0,'',0,0,0,0,'',''};
            
            % Goes through children of this part
            number_of_children = size(note.Children, 2);
            
            % Collates pitch and lyric information, then hands up to importMeasure
            for i_child = 1 : number_of_children
                this_child = note.Children(i_child);
                if strcmp(this_child.Name, 'duration')
                    this_note(1, 1) = {str2double(this_child.Children.Data)};
                end
                if strcmp(this_child.Name, 'pitch')
                    [this_pitch_step, this_pitch_alter, this_pitch_octave] = importPitch(app, this_child);
                    this_note(1, 3) = cellstr(this_pitch_step);
                    this_note(1, 4) = {this_pitch_alter};
                    this_note(1, 5) = {this_pitch_octave};
                end
                if strcmp(this_child.Name, 'lyric')
                    this_note(1, 8) = cellstr(importLyric(app, this_child));
                end
                    if strcmp(this_child.Name, 'rest')
                    this_note(1, 9) = {'rest'};
                end
            end 
        end
        
%================================================================================================  
        
        function this_part_notes = importPart(app, part)
            % Initializes variables
            this_part_notes = {};
        
            % Goes through children of this part
            number_of_children = size(part, 2);
            
            % Collates part information, then hands up to analyzeMXL
            for i_child = 1 : number_of_children
                this_child = part(i_child);
                if strcmp(this_child.Name, 'measure')
                    this_measure_notes = importMeasure(app, this_child);
                    this_part_notes = [this_part_notes; this_measure_notes];
                end
            end
        end

%================================================================================================  
        
        function [this_pitch_step, this_pitch_alter, this_pitch_octave] = importPitch(app, pitch)
            % Initializes placeholder variables
            this_pitch_step = {''};
            this_pitch_alter = [0];
            this_pitch_octave = [0];
            
            % Goes through children of this part
            number_of_children = size(pitch.Children, 2);
            this_pitch_list = cell(1, 3);
            
            % Extracts pitches and hands up to importNote
            for i_child = 1 : number_of_children
                this_child = pitch.Children(i_child);
                if strcmp(this_child.Name, 'step')
                    this_pitch_step = this_child.Children.Data;
                end
                if strcmp(this_child.Name, 'alter')
                    this_pitch_alter = str2double(this_child.Children.Data);
                end
                if strcmp(this_child.Name, 'octave')
                    this_pitch_octave = str2double(this_child.Children.Data);
                end
            end
        end

%================================================================================================  
    
        function nodeStruct = makeStructFromNode(app, theNode)
            % Create structure of node info.
            nodeStruct = struct('Name', char(theNode.getNodeName), 'Attributes', parseAttributes(app, theNode), 'Data', '', 'Children', parseChildNodes(app, theNode));
            
            if any(strcmp(methods(theNode), 'getData'))
               nodeStruct.Data = char(theNode.getData); 
            else
               nodeStruct.Data = '';
            end
        end

%================================================================================================  
        
        function attributes = parseAttributes(app, theNode)
            % Create attributes structure.
            attributes = [];
            
            if theNode.hasAttributes
               theAttributes = theNode.getAttributes;
               numAttributes = theAttributes.getLength;
               allocCell = cell(1, numAttributes);
               attributes = struct('Name', allocCell, 'Value', allocCell);
               for count = 1:numAttributes
                  attrib = theAttributes.item(count-1);
                  attributes(count).Name = char(attrib.getName);
                  attributes(count).Value = char(attrib.getValue);
               end
            end
        end
        
%================================================================================================  

        function children = parseChildNodes(app, theNode)
            % Recurse over node children.
            children = [];
            
            if theNode.hasChildNodes
               childNodes = theNode.getChildNodes;
               numChildNodes = childNodes.getLength;
               allocCell = cell(1, numChildNodes);
               children = struct('Name', allocCell, 'Attributes', allocCell, 'Data', allocCell, 'Children', allocCell);
                for count = 1:numChildNodes
                    theChild = childNodes.item(count-1);
                    children(count) = makeStructFromNode(app, theChild);
                end
            end
        end

%================================================================================================   
        
        function theStruct = parseXML(app, filename)
            % PARSEXML Convert XML file to a MATLAB structure.
            try
               tree = xmlread(app.input_filename);
            catch
               error('Failed to read XML file %s.',app.input_filename);
            end
            
            % Recurse over child nodes. This could run into problems with very deeply nested trees.
            try
               theStruct = parseChildNodes(app, tree);
            catch
               error('Unable to parse XML file %s.',filename);
            end
        end
        
%================================================================================================  
        
        function partwise(app)
            % Copies partwise.dtd file path to clipboard
            clipboard('copy', join([app.input_filepath app.input_filename]));
            f = msgbox(['The partwise.dtd file path has now been copied to your clipboard. ' ...
                'Please replace "http://www.musicxml.org/dtds/partwise.dtd" in Line 2 of your ' ...
                'uncompressed MusicXML file (.xml) with the copied filepath. Double-check ' ...
                'that the partwise.dtd file path has quotation marks around it.'], 'Operation completed', 'help');
        end
        
%================================================================================================        
        
        function plotMXL(app)

            % Loads relevant variables
            load(app.input_filename);
            
            % Saves moving_average to public property
            app.moving_average = moving_average;
        
            % GLOBAL TESSITURA METRICS TAB
            
                % Creates box plot of pitch and duration data...
                boxplot(app.AxesBoxPlot, boxplot_subdiv, 'Orientation', 'horizontal');
                
                % ...then plots mean F0 on the same axes
                hold(app.AxesBoxPlot, 'on')
                plot(app.AxesBoxPlot, F0_mean, 1, 'dg');
                hold(app.AxesBoxPlot, 'off')
                
                % Creates bar graph of pitch and duration data
                bar(app.AxesHistogram, unique_F0(1:end, 1), unique_F0(1:end, 3));
                
            % NOTE-BY-NOTE TESSITURA METRICS TAB
            
                % Plots note-by-note F0 plot
                plot(app.AxesMovingAverage, app.moving_average, 'LineWidth', 1.2, 'LineStyle', ':');
                
                % Plots moving average where slider currently is
                hold(app.AxesMovingAverage, 'on');
                moving_plot = movmean(app.moving_average, app.SliderMovingAverage.Value, 'omitnan');
                plot(app.AxesMovingAverage, moving_plot, 'LineWidth', 2.4)
                hold(app.AxesMovingAverage, 'off');
                
                % NOTE: update_callback handles moving average plotting while slider is moving
            
            % VOCAL DEMAND METRICS TAB
            
                % Creates plot of percent voicing time
                bar(app.AxesPercentVoicing, 1, percent_voicing);
                
                % Creates plot of total vocal fold cycles
                bar(app.AxesTotalCycles, 1, total_vf_cycles);
                
                % Creates plot of mean vocal fold cycles per second
                bar(app.AxesMeanCycles, 1, cycles_per_second);
                
            % SUMMARY STATISTICS TAB
            
                % Creates table of all pitch and duration data
                app.TablePitchDurations.Data = unique_F0;

                % Displays F0 descriptive statistics
                descriptiveStats = ...
                    {'Minimum Frequency (Hz)',          F0_min; ...
                     '25th Percentile Frequency (Hz)',  F0_25th_Percentile; ...
                     'Mean Frequency (Hz)',             F0_mean; ...
                     'Median Frequency (Hz)',           F0_median; ...
                     '75th Percentile Frequency (Hz)',  F0_75th_Percentile; ...
                     'Maximum Frequency (Hz)',          F0_max; ...
                     '',                                ''; ...
                     'Total Duration (s)',              total_duration; ...
                     'Total Voicing Duration (s)',      total_voicing_duration; ...
                     'Total Rest Duration(s)',          total_rest_duration; ...
                     '',                                ''; ...
                     'Percent Time Spent Voicing (%)',  percent_voicing; ...
                     'Estimated VF Cycles',             total_vf_cycles; ...
                     'Mean VF Cycles Per Second (Hz)',  cycles_per_second};
                app.TableSummaryStats.Data = descriptiveStats;
        end

%================================================================================================ 
        
        function xml2struct(app)
            % Calls parseXML to transfer .xml data into a structure array
            temporary_struct = parseXML(app, app.input_filename);
            
            % Saves parsed MatLab struct file to filename specified by user
            app.output_filename = strcat(app.FieldOutputName.Value, '.mat');
            save(app.output_filename, 'temporary_struct');
        end
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: ButtonPartwise
        function partwise_callback(app, event)
            % Opens file explorer
            [file,path] = uigetfile({'*.dtd', 'MusicXML Schema Files (*.dtd)'}, 'Select a File', 'partwise.dtd');
            
            % If user selects .dtd file, specifies output file name
            if strcmp(file, 'partwise.dtd') == 1
                app.input_filename = file;
                app.input_filepath = path;
                file_selected = 1;
            else
                file_selected = 0;
            end
            
            % If user selects a file, copies its name and path, then calls partwise; if not, ends the function and informs user
            if file_selected == 1
                partwise(app)
            else
                f = msgbox('User did not select a valid partwise.dtd definition file.', 'Operation canceled', 'warn');
            end
        end

        % Button pushed function: ButtonConvert
        function convert_callback(app, event)
            if isempty(app.FieldOutputName.Value) == 1
                f = msgbox('User has not specified a file output name.', 'Operation canceled', 'warn');
            else
                % Opens file explorer
                [file,path] = uigetfile({'*.xml', 'Uncompressed MusicXML files (*.xml)'}, 'Select a File', 'my_MusicXML_file.xml');
                
                % If user selects .mat file with structure array, specifies output file name
                if file == 0
                    file_selected = 0;
                else
                    app.input_filename = file;
                    app.input_filepath = path;
                    file_selected = 1;
                end
                
                % If user selects a file, copies its name and path, then calls analyzeMXL; if not, ends the function and informs user
                if file_selected == 1
                    xml2struct(app)
                else
                    f = msgbox('User did not select a valid file.', 'Operation canceled', 'warn');
                end
            end
        end

        % Button pushed function: ButtonCompile
        function compile_callback(app, event)
            % Opens file explorer
            [file,path] = uigetfile({'*.mat', 'MATLAB data files (*.mat)'}, 'Select a File', 'my_matlab_file.mat');
            
            % If user selects .mat file with structure array, specifies output file name
            if file == 0
                file_selected = 0;
            else
                app.input_filename = file;
                app.input_filepath = path;
                file_selected = 1;
            end
            
            % If user selects a file, copies its name and path, then calls analyzeMXL; if not, ends the function and informs user
            if file_selected == 1
                analyzeMXL(app)
            else
                f = msgbox('User did not select a valid file.', 'Operation canceled', 'warn');
            end
        end

        % Button pushed function: ButtonDisplay
        function display_callback(app, event)
            % Opens file explorer
            [file,path] = uigetfile({'*.mat', 'MATLAB data files (*.mat)'}, 'Select a File', 'my_matlab_file.mat');
            
            % If user selects .mat file with structure array, specifies output file name
            if file == 0
                file_selected = 0;
            else
                app.input_filename = file;
                app.input_filepath = path;
                file_selected = 1;
            end
            
            % If user selects a file, copies its name and path, then calls plotMXL; if not, ends the function and informs user
            if file_selected == 1
                plotMXL(app)
            else
                f = msgbox('User did not select a valid file.', 'Operation canceled', 'warn');
            end
        end

        % Value changing function: SliderMovingAverage
        function update_callback(app, event)
            % Sets slider value as variable changingValue
            changingValue = event.Value;
            
            % Plots base F0 values
            plot(app.AxesMovingAverage, app.moving_average, 'LineWidth', 1.2, 'LineStyle', ':');
            
            % Plots moving mean, weighted by a changing slider value
            hold(app.AxesMovingAverage, 'on');
            
            % Centered average plots
            if app.DropDownNaN.Value == "Omit NaN values"
                moving_plot = movmean(app.moving_average, changingValue, 'omitnan');
                plot(app.AxesMovingAverage, moving_plot, 'LineWidth', 2.4)
            elseif app.DropDownNaN.Value == "Include NaN values"
                moving_plot = movmean(app.moving_average, changingValue, 'includenan');
                plot(app.AxesMovingAverage, moving_plot, 'LineWidth', 2.4)
            end

            hold(app.AxesMovingAverage, 'off');
        end

        % Value changed function: VoiceTypeDropDown
        function voicetype_callback(app, event)
            value = app.VoiceTypeDropDown.Value;
            if strcmp(value, 'Auto-scaling') == 1
                app.AxesBoxPlot.XLim = [0,1];
                app.AxesBoxPlot.XLimMode = 'auto';
                app.AxesHistogram.XLim = [0,1];
                app.AxesHistogram.XLimMode = 'auto';
                app.AxesMovingAverage.YLim = [0,1];
                app.AxesMovingAverage.YLimMode = 'auto';
            elseif strcmp(value, 'Soprano') == 1
                app.AxesBoxPlot.XLim = [250,1200];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [250,1200];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [250,1200];
                app.AxesMovingAverage.YLimMode = 'manual';
            elseif strcmp(value, 'Mezzo-Soprano') == 1
                app.AxesBoxPlot.XLim = [190,890];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [190,890];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [190,890];
                app.AxesMovingAverage.YLimMode = 'manual';
            elseif strcmp(value, 'Contralto') == 1
                app.AxesBoxPlot.XLim = [160,670];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [160,670];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [160,670];
                app.AxesMovingAverage.YLimMode = 'manual';
            elseif strcmp(value, 'Tenor') == 1
                app.AxesBoxPlot.XLim = [120,530];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [120,530];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [120,530];
                app.AxesMovingAverage.YLimMode = 'manual';
            elseif strcmp(value, 'Baritone') == 1
                app.AxesBoxPlot.XLim = [80,400];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [80,400];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [80,400];
                app.AxesMovingAverage.YLimMode = 'manual';
            elseif strcmp(value, 'Bass') == 1
                app.AxesBoxPlot.XLim = [60,330];
                app.AxesBoxPlot.XLimMode = 'manual';
                app.AxesHistogram.XLim = [60,330];
                app.AxesHistogram.XLimMode = 'manual';
                app.AxesMovingAverage.YLim = [60,330];
                app.AxesMovingAverage.YLimMode = 'manual';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create FigureTessa and hide until all components are created
            app.FigureTessa = uifigure('Visible', 'off');
            app.FigureTessa.Color = [0.0745 0.4314 0.6118];
            app.FigureTessa.Position = [100 100 1430 749];
            app.FigureTessa.Name = 'Tessa: a simpler tessituragram';

            % Create PanelPartwise
            app.PanelPartwise = uipanel(app.FigureTessa);
            app.PanelPartwise.Title = '1. Define location of ''partwise.dtd''';
            app.PanelPartwise.FontAngle = 'italic';
            app.PanelPartwise.Position = [31 630 360 90];

            % Create ButtonPartwise
            app.ButtonPartwise = uibutton(app.PanelPartwise, 'push');
            app.ButtonPartwise.ButtonPushedFcn = createCallbackFcn(app, @partwise_callback, true);
            app.ButtonPartwise.IconAlignment = 'center';
            app.ButtonPartwise.BackgroundColor = [0.9412 0.9412 0.9412];
            app.ButtonPartwise.Tooltip = {'Copies the file path to your ''partwise.dtd'' definition file.'};
            app.ButtonPartwise.Position = [21 20 320 32];
            app.ButtonPartwise.Text = 'Browse';

            % Create PanelConvert
            app.PanelConvert = uipanel(app.FigureTessa);
            app.PanelConvert.Title = '2. Convert .xml file to MATLAB structure array';
            app.PanelConvert.FontAngle = 'italic';
            app.PanelConvert.Position = [31 450 360 150];

            % Create FieldOutputName
            app.FieldOutputName = uieditfield(app.PanelConvert, 'text');
            app.FieldOutputName.Position = [21 88 320 22];

            % Create LabelOutputName
            app.LabelOutputName = uilabel(app.PanelConvert);
            app.LabelOutputName.HorizontalAlignment = 'center';
            app.LabelOutputName.Position = [21 68 320 22];
            app.LabelOutputName.Text = 'Output name for converted MAT file';

            % Create ButtonConvert
            app.ButtonConvert = uibutton(app.PanelConvert, 'push');
            app.ButtonConvert.ButtonPushedFcn = createCallbackFcn(app, @convert_callback, true);
            app.ButtonConvert.IconAlignment = 'center';
            app.ButtonConvert.Tooltip = {'This is by far the longest step in Tessa''s runtime! Enjoy a cup of coffee.'};
            app.ButtonConvert.Position = [21 18 320 32];
            app.ButtonConvert.Text = 'Browse and convert';

            % Create PanelCompile
            app.PanelCompile = uipanel(app.FigureTessa);
            app.PanelCompile.Title = '3. Compile musical data from structure array';
            app.PanelCompile.FontAngle = 'italic';
            app.PanelCompile.Position = [31 270 360 150];

            % Create FieldPartID
            app.FieldPartID = uieditfield(app.PanelCompile, 'text');
            app.FieldPartID.HorizontalAlignment = 'center';
            app.FieldPartID.Position = [21 88 143 22];

            % Create LabelPartID
            app.LabelPartID = uilabel(app.PanelCompile);
            app.LabelPartID.HorizontalAlignment = 'center';
            app.LabelPartID.Position = [21 68 140 22];
            app.LabelPartID.Text = 'Part ID (Ex.: P1, P2)';

            % Create LabelTempo
            app.LabelTempo = uilabel(app.PanelCompile);
            app.LabelTempo.HorizontalAlignment = 'center';
            app.LabelTempo.Position = [191 68 150 22];
            app.LabelTempo.Text = 'Tempo in BPM';

            % Create ButtonCompile
            app.ButtonCompile = uibutton(app.PanelCompile, 'push');
            app.ButtonCompile.ButtonPushedFcn = createCallbackFcn(app, @compile_callback, true);
            app.ButtonCompile.IconAlignment = 'center';
            app.ButtonCompile.Tooltip = {'Your file will be saved in MATLAB''s current folder path.'};
            app.ButtonCompile.Position = [21 18 320 32];
            app.ButtonCompile.Text = 'Browse and compile';

            % Create FieldTempo
            app.FieldTempo = uieditfield(app.PanelCompile, 'numeric');
            app.FieldTempo.Limits = [0 Inf];
            app.FieldTempo.Position = [191 88 149 22];

            % Create PanelDisplay
            app.PanelDisplay = uipanel(app.FigureTessa);
            app.PanelDisplay.Title = '5. Display graphics and metrics';
            app.PanelDisplay.FontAngle = 'italic';
            app.PanelDisplay.Position = [31 30 360 90];

            % Create ButtonDisplay
            app.ButtonDisplay = uibutton(app.PanelDisplay, 'push');
            app.ButtonDisplay.ButtonPushedFcn = createCallbackFcn(app, @display_callback, true);
            app.ButtonDisplay.IconAlignment = 'center';
            app.ButtonDisplay.Position = [21 20 320 32];
            app.ButtonDisplay.Text = 'Browse and display';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.FigureTessa);
            app.TabGroup.Position = [421 30 980 690];

            % Create TabGlobal
            app.TabGlobal = uitab(app.TabGroup);
            app.TabGlobal.Title = 'Global Tessitura Metrics';

            % Create AxesBoxPlot
            app.AxesBoxPlot = uiaxes(app.TabGlobal);
            title(app.AxesBoxPlot, 'Median, range, and interquartile frequencies')
            xlabel(app.AxesBoxPlot, 'Frequency (Hz)')
            ylabel(app.AxesBoxPlot, '')
            app.AxesBoxPlot.YTick = [];
            app.AxesBoxPlot.Position = [41 385 900 259];

            % Create AxesHistogram
            app.AxesHistogram = uiaxes(app.TabGlobal);
            title(app.AxesHistogram, 'Phonation time at each voiced frequency')
            xlabel(app.AxesHistogram, 'Frequency (Hz)')
            ylabel(app.AxesHistogram, 'Duration (s)')
            app.AxesHistogram.XGrid = 'on';
            app.AxesHistogram.YGrid = 'on';
            app.AxesHistogram.Position = [21 24 920 340];

            % Create TabNoteByNote
            app.TabNoteByNote = uitab(app.TabGroup);
            app.TabNoteByNote.Title = 'Note-by-Note Tessitura Metrics';

            % Create AxesMovingAverage
            app.AxesMovingAverage = uiaxes(app.TabNoteByNote);
            title(app.AxesMovingAverage, 'Fundamental frequency and its moving average over time')
            xlabel(app.AxesMovingAverage, 'Time')
            ylabel(app.AxesMovingAverage, 'Fundamental frequency (Hz)')
            app.AxesMovingAverage.ColorOrder = [0 0.451 0.7412;0.851 0.3255 0.098;0.6353 0.0784 0.1843;1 1 1;1 1 1];
            app.AxesMovingAverage.XGrid = 'on';
            app.AxesMovingAverage.YGrid = 'on';
            app.AxesMovingAverage.Position = [31 144 920 491];

            % Create SliderMovingAverage
            app.SliderMovingAverage = uislider(app.TabNoteByNote);
            app.SliderMovingAverage.Limits = [1 150];
            app.SliderMovingAverage.MajorTicks = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150];
            app.SliderMovingAverage.ValueChangingFcn = createCallbackFcn(app, @update_callback, true);
            app.SliderMovingAverage.MinorTicks = [5 15 25 35 45 55 65 75 85 95 105 115 125 135 145];
            app.SliderMovingAverage.Tooltip = {'Determines how heavily the moving average plot is weighted. N=1 will mirror the F0 plot exactly, while higher numbers will smooth the curve.'};
            app.SliderMovingAverage.Position = [71 96 653 3];
            app.SliderMovingAverage.Value = 5;

            % Create LabelMovingAverage
            app.LabelMovingAverage = uilabel(app.TabNoteByNote);
            app.LabelMovingAverage.HorizontalAlignment = 'center';
            app.LabelMovingAverage.FontAngle = 'italic';
            app.LabelMovingAverage.Position = [332 34 132 22];
            app.LabelMovingAverage.Text = 'Moving Average Weight';

            % Create DropDownNaN
            app.DropDownNaN = uidropdown(app.TabNoteByNote);
            app.DropDownNaN.Items = {'Omit NaN values', 'Include NaN values'};
            app.DropDownNaN.Tooltip = {'Omit NaN values if voicing is dense; include if voicing is sparse.'};
            app.DropDownNaN.Position = [765 77 177 22];
            app.DropDownNaN.Value = 'Omit NaN values';

            % Create TabVocalDemandMetrics
            app.TabVocalDemandMetrics = uitab(app.TabGroup);
            app.TabVocalDemandMetrics.Title = 'Vocal Demand Metrics';

            % Create AxesPercentVoicing
            app.AxesPercentVoicing = uiaxes(app.TabVocalDemandMetrics);
            title(app.AxesPercentVoicing, 'Percent time spent voicing')
            xlabel(app.AxesPercentVoicing, '')
            ylabel(app.AxesPercentVoicing, 'Percent time spent voicing (%)')
            app.AxesPercentVoicing.YLim = [0 100];
            app.AxesPercentVoicing.ColorOrder = [0 0.451 0.7412;0.851 0.3255 0.098;0.6353 0.0784 0.1843;1 1 1;1 1 1];
            app.AxesPercentVoicing.XTick = [];
            app.AxesPercentVoicing.XTickLabel = {};
            app.AxesPercentVoicing.YTick = [0 10 20 30 40 50 60 70 80 90 100];
            app.AxesPercentVoicing.YTickLabel = {'0'; '10'; '20'; '30'; '40'; '50'; '60'; '70'; '80'; '90'; '100'};
            app.AxesPercentVoicing.YMinorTick = 'on';
            app.AxesPercentVoicing.YGrid = 'on';
            app.AxesPercentVoicing.Position = [31 35 279 599];

            % Create AxesTotalCycles
            app.AxesTotalCycles = uiaxes(app.TabVocalDemandMetrics);
            title(app.AxesTotalCycles, 'Total vocal fold cycles')
            xlabel(app.AxesTotalCycles, '')
            ylabel(app.AxesTotalCycles, 'Vocal fold cycles')
            app.AxesTotalCycles.YLim = [1000 1000000];
            app.AxesTotalCycles.ColorOrder = [0.851 0.3255 0.098;0.9294 0.6941 0.1255;0.4941 0.1843 0.5569;0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843];
            app.AxesTotalCycles.XTick = [];
            app.AxesTotalCycles.XTickLabel = {};
            app.AxesTotalCycles.YTick = [1000 10000 100000 1000000];
            app.AxesTotalCycles.YTickLabel = {'10^{3}'; '10^{4}'; '10^{5}'; '10^{6}'};
            app.AxesTotalCycles.YMinorTick = 'on';
            app.AxesTotalCycles.YGrid = 'on';
            app.AxesTotalCycles.YScale = 'log';
            app.AxesTotalCycles.Position = [341 35 289 599];

            % Create AxesMeanCycles
            app.AxesMeanCycles = uiaxes(app.TabVocalDemandMetrics);
            title(app.AxesMeanCycles, 'Mean vocal fold cycles per second')
            xlabel(app.AxesMeanCycles, '')
            ylabel(app.AxesMeanCycles, 'Mean vocal fold cycles per second (Hz)')
            app.AxesMeanCycles.YLim = [0 1000];
            app.AxesMeanCycles.ColorOrder = [0.4667 0.6745 0.1882;0.302 0.7451 0.9333;0.6353 0.0784 0.1843];
            app.AxesMeanCycles.XTick = [];
            app.AxesMeanCycles.XTickLabel = {};
            app.AxesMeanCycles.YTick = [0 100 200 300 400 500 600 700 800 900 1000];
            app.AxesMeanCycles.YTickLabel = {'0'; '100'; '200'; '300'; '400'; '500'; '600'; '700'; '800'; '900'; '1000'};
            app.AxesMeanCycles.YMinorTick = 'on';
            app.AxesMeanCycles.YGrid = 'on';
            app.AxesMeanCycles.Position = [661 35 290 599];

            % Create SummaryStatisticsTab
            app.SummaryStatisticsTab = uitab(app.TabGroup);
            app.SummaryStatisticsTab.Title = 'Summary Statistics';

            % Create TablePitchDurations
            app.TablePitchDurations = uitable(app.SummaryStatisticsTab);
            app.TablePitchDurations.ColumnName = {'F0 (Hz)'; 'Duration (Beats)'; 'Duration (Seconds)'};
            app.TablePitchDurations.RowName = {};
            app.TablePitchDurations.ColumnSortable = true;
            app.TablePitchDurations.Position = [491 35 460 600];

            % Create TableSummaryStats
            app.TableSummaryStats = uitable(app.SummaryStatisticsTab);
            app.TableSummaryStats.ColumnName = {'Statistic'; 'Value'};
            app.TableSummaryStats.RowName = {};
            app.TableSummaryStats.Position = [31 35 430 600];

            % Create SelectvoicetypePanel
            app.SelectvoicetypePanel = uipanel(app.FigureTessa);
            app.SelectvoicetypePanel.Title = '4. Select voice type';
            app.SelectvoicetypePanel.FontAngle = 'italic';
            app.SelectvoicetypePanel.Position = [31 150 360 90];

            % Create VoiceTypeDropDown
            app.VoiceTypeDropDown = uidropdown(app.SelectvoicetypePanel);
            app.VoiceTypeDropDown.Items = {'Auto-scaling', 'Soprano', 'Mezzo-Soprano', 'Contralto', 'Tenor', 'Baritone', 'Bass'};
            app.VoiceTypeDropDown.ValueChangedFcn = createCallbackFcn(app, @voicetype_callback, true);
            app.VoiceTypeDropDown.Position = [21 21 319 29];
            app.VoiceTypeDropDown.Value = 'Auto-scaling';

            % Show the figure after all components are created
            app.FigureTessa.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Tessa

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.FigureTessa)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.FigureTessa)
        end
    end
end