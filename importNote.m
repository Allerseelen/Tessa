function this_note = importNote(note)
    
    % initialize placeholder variables
    this_note = {0,0,'',0,0,0,0,'',''};
    
    % go through children of this part
    number_of_children = size(note.Children, 2);
    
    for i_child = 1 : number_of_children
        this_child = note.Children(i_child);
        if strcmp(this_child.Name, 'duration')
            this_note(1, 1) = {str2double(this_child.Children.Data)};
        end
        if strcmp(this_child.Name, 'pitch')
            [this_pitch_step, this_pitch_alter, this_pitch_octave] = importPitch(this_child);
            this_note(1, 3) = cellstr(this_pitch_step);
            this_note(1, 4) = {this_pitch_alter};
            this_note(1, 5) = {this_pitch_octave};
        end
        if strcmp(this_child.Name, 'lyric')
            this_note(1, 8) = cellstr(importLyric(this_child));
        end
            if strcmp(this_child.Name, 'rest')
            this_note(1, 9) = {'rest'};
        end
    end 
end