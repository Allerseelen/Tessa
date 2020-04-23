function [this_pitch_step, this_pitch_alter, this_pitch_octave] = importPitch(pitch)
    
    % initialize placeholder variables
    this_pitch_step = {''};
    this_pitch_alter = [0];
    this_pitch_octave = [0];
    
    % go through children of this part
    number_of_children = size(pitch.Children, 2);
    this_pitch_list = cell(1, 3);
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