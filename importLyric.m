function this_pitch_lyric = importLyric(lyric)
    
    % initialize placeholder variables
    this_pitch_lyric = {''};
    
    % go through children of this part
    number_of_children = size(lyric.Children, 2);
    this_lyric_list = cell(1, 1);
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