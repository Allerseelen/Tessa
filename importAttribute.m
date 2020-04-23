function importAttribute(attributes)

    % initialize variables
    this_attribute_divisions = 0;
    
    % go through children of this part
    number_of_children = size(attributes.Children, 2);
    
    for i_child = 1 : number_of_children
        this_child = attributes.Children(i_child);
        if strcmp(this_child.Name, 'divisions')
            beat_duration = str2double(this_child.Children.Data);
            save('0.0. Beat Duration.mat', 'beat_duration');
        end
    end
end